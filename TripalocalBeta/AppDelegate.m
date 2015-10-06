//
//  AppDelegate.m
//  TripalocalBeta
//
//  Created by Charles He on 12/05/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "AppDelegate.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Constant.h"
#import <SecureNSUserDefaults/NSUserDefaults+SecureAdditions.h>
#import "DBManager.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "Utility.h"
#import "IQKeyboardManager.h"
#import "Mixpanel.h"

#define MIXPANEL_TOKEN @"f94e94414c9de0cc38874706d853c400"
#define MIXPANEL_TOKEN_DEV @"c2510512c6cb4c34b4b32bd32a0cf866"

@interface AppDelegate ()
-(void)setupStream;
-(void)goOnline;
-(void)goOffline;
-(BOOL)isConnected;
@property (nonatomic,strong) DBManager *dbManager;
@end

@implementation AppDelegate
@synthesize xmppStream, viewController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[NSUserDefaults standardUserDefaults] setSecret:@"your_secret_goes_here"];
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor clearColor];
    
    int imageSize = 27; //REPLACE WITH YOUR IMAGE WIDTH
    
    UIImage *barBackBtnImg = [[UIImage imageNamed:@"back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, imageSize, 0, 0)];

    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:barBackBtnImg
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
#ifdef DEBUG
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN_DEV];
#else
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
#endif
    
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar :NO];
    
    // Handle launching from a notification
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification) {
        // Set icon badge number to zero
        application.applicationIconBadgeNumber = 0;
    }

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self disconnect];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [self connect];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                  standbyCallback:^(NSDictionary *resultDic) {
#if DEBUG
                                             NSLog(@"reslut = %@",resultDic);
#endif
                                             if ([self paymentSuccess:resultDic]) {
#if DEBUG
                                                 NSLog(@"Payment status = %@", @"success");
#endif
                                                 // parse complex string from alipay
                                                 NSString *resultString = [resultDic objectForKey:@"result"];
                                                 resultString = [resultString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                                                 resultString = [resultString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
                                                 
                                                 for (NSString *pairString in [resultString componentsSeparatedByString:@"&"]) {
                                                     NSArray *pair = [pairString componentsSeparatedByString:@"="];
                                                     
                                                     if ([pair count] == 2) {
                                                         NSString *keyString = (NSString *)[pair objectAtIndex:0];
                                                         if ([keyString containsString:@"out_trade_no"]) {
                                                             NSString *orderNumber = (NSString *)[pair objectAtIndex:1];
                                                             
                                                             NSDictionary *aDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                                                          orderNumber, @"orderNumber",
                                                                                          nil];
                                                             [[NSNotificationCenter defaultCenter] postNotificationName:@"alipayNotification" object:nil userInfo:aDictionary];
                                                         }
                                                     }
                                                 }
                                             } else {
                                                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"payment_failed", nil)
                                                                                                 message:NSLocalizedString(@"payment_failed_msg", nil)
                                                                                                delegate:nil
                                                                                       cancelButtonTitle:NSLocalizedString(@"ok_button", nil)
                                                                                       otherButtonTitles:nil];
                                                 [alert show];
                                             }
                                         }];
        
    }
    
    return YES;
}

- (BOOL)paymentSuccess:(NSDictionary *)resultDict {
    NSDictionary *resultObject = [resultDict objectForKey:@"result"];
    if ([[resultDict objectForKey:@"resultStatus"] intValue] == 9000 && resultObject) {
        if ([[resultDict objectForKey:@"success"] isEqual: @"true"]) {
            return YES;
        }
    }
    
    return NO;
}

-(void)setupStream {
    NSLog(@"Setting up the Stream!>");
    xmppStream = [[XMPPStream alloc] init];
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppStream disconnect];
//    NSLog(@"xmpp Strean is connect? ==== %d", [xmppStream isDisconnected]);
//    self.xmppStream.hostName = @"54.149.42.196";
//    self.xmppStream.hostPort = 9090;
//    NSLog(@"xmpp Strean is connect? ==== %d", [xmppStream isDisconnected]);
}
-(BOOL)connect {
    [self setupStream];
    //setting up the jabber id and password

    NSString *jabberID = [NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"], @"@tripalocal.com"];
    NSString *myPassword = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
#if DEBUG
    NSLog(@"Using JABBERID:%@, PASSWORD:%@", jabberID, myPassword);
#endif
    
    if (![xmppStream isDisconnected]) {
        NSLog(@"connected: %d", [self.xmppStream isConnected]);
        return YES;
    }
    NSLog(@"DISCONNECT YES!!");
    if (jabberID == nil || myPassword == nil) {
        return NO;
    }
#if DEBUG
    NSLog(@"Connecting to openfire server, using: %@",jabberID);
#endif
    
    [xmppStream setMyJID:[XMPPJID jidWithString:jabberID]];
    password = myPassword;

    NSError *error = nil;
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error])
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error connecting"
                                                            message:@"See console for error details."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
        [alertView show];
    	return NO;
    }
    NSLog(@"Is connected: %d", [self.xmppStream isConnected]);
    return YES;
}
-(void)disconnect{
    [self goOffline];
    [xmppStream disconnect];
//    [_chatDelegate didDisconnect];
}
-(void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    NSXMLElement *priority = [NSXMLElement elementWithName:@"Priority" stringValue:@"0"];
    [presence addChild:priority];
#if DEBUG
    NSLog(@"XS Sending:%@",priority);
#endif
    [[self xmppStream] sendElement:presence];
}
-(void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"Unavailable"];
    [[self xmppStream] sendElement:presence];
}
- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket
{
    NSLog(@"SOCKET DID CONNECT$$$$$$$$$$$$$$$$$$$");
}
- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings
{
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    NSString *expectedCertName = [xmppStream.myJID domain];
    NSLog(@"Domain Name: %@", expectedCertName);
    NSLog(@"willSecureWithSettings #####################");
    NSLog(@"Is connected: %d", [self.xmppStream isConnected]);
    if (expectedCertName)
    {
        settings[(NSString *) kCFStreamSSLPeerName] = expectedCertName;
    }
    
//    if (customCertEvaluation)
//    {
//        settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
//    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler
{
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    
    // The delegate method should likely have code similar to this,
    // but will presumably perform some extra security code stuff.
    // For example, allowing a specific self-signed certificate that is known to the app.
    
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{
        
        SecTrustResultType result = kSecTrustResultDeny;
        OSStatus status = SecTrustEvaluate(trust, &result);
        NSLog(@"DID RECEIVE TRUST *********************");
        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
            completionHandler(YES);
        }
        else {
            completionHandler(NO);
        }
    });
}
- (void)xmppStreamDidSecure:(XMPPStream *)sender
{
    NSLog(@"DID SECURE ^^^^^^^^^^^^^^^^^^^^^^");
//    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

-(void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSLog(@"User Connected");
    isOpen = YES;
    NSError *error = nil;
    [[self xmppStream] authenticateWithPassword:password error:nil];
    [self.xmppStream sendElement:[XMPPPresence presence]];
    
}
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"Authenticate!");
    [self goOnline];
}
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    //get the user_id
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *receiver_id = [userDefaults objectForKey:@"user_id"];
    //get current time in UTC
    NSString *timeStamp = [Utility getCurrentUTCTime];
    // here you have new Date with desired format and TimeZone.
#if DEBUG
    NSLog(@"Message received: %@",message);
#endif
    NSString *msg = [[message elementForName:@"body"] stringValue];
    if (msg == (id)[NSNull null] || msg.length == 0)  {
        msg = @"";
    }
    
    NSString *fromWithDeviceID = [[message attributeForName:@"from"] stringValue];
    NSString *from = [[fromWithDeviceID	componentsSeparatedByString:@"@"] objectAtIndex:0];
#if DEBUG
    NSLog(@"Message: %@; from: %@",msg,from);
#endif
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    [m setObject:msg forKey:@"msg"];
    [m setObject:from forKey:@"sender"];
    
    //  save data in core data
    NSManagedObjectContext *context = [self managedObjectContext];
    
    // Create a new managed object
    NSManagedObject *newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    long long local_id = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    [newMessage setValue:[NSString stringWithFormat:@"%lld", local_id] forKey:@"local_id"];
    [newMessage setValue:[NSString stringWithFormat:@"%@", receiver_id] forKey:@"receiver_id"];
    [newMessage setValue:[m objectForKey:@"sender"] forKey:@"sender_id"];
    [newMessage setValue:nil forKey:@"global_id"];
    [newMessage setValue:[m objectForKey:@"msg"] forKey:@"message_content"];
    [newMessage setValue:timeStamp forKey:@"message_time"];
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
//load message in chat detail view
    [_messageDelegate newMessageReceived:m];
#if DEBUG
    NSLog(@"Message received: %@",m);
#endif
    
    
    
    
    
//    //init database object
//    self.dbManager = [[DBManager alloc] initWithDatabaseFileName:@"message.sql"];
//    //execute the sql command
//    NSString *query = [NSString stringWithFormat:@"INSERT INTO message VALUES(null, '%d', '%d', NULL,'%@', '%@')",[receiver_id intValue],[[m objectForKey:@"sender"] intValue],[m objectForKey:@"msg"],timeStamp];
//    
//    // Execute the query.
//    [self.dbManager executeQuery:query];
//    
//    // If the query was successfully executed
//    if (self.dbManager.affectedRows != 0) {
//        NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
//    }
//    else{
//        NSLog(@"Could not execute the query.");
//    }
    
}
-(void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
    NSString *presenceType = [presence type]; //online or offline
    NSString *myUserName = [[sender myJID] user];
    NSString *presenceFromUser = [[presence from] user];
    
    if (![presenceFromUser isEqualToString:myUserName]) {
        if ([presenceType isEqualToString:@"available"]) {
            [_chatDelegate newPeopleOnline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"YOURSERVER"]];
        } else if ([presenceType isEqualToString:@"Unavailable"]) {
            [_chatDelegate peopleWentOffline:[NSString stringWithFormat:@"%@@%@", presenceFromUser, @"YOURSERVER"]];
        }
    }
}
-(BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq{
    return NO;
}
-(BOOL)isConnected{
    return [self.xmppStream isConnected];
}
-(void)dealloc {
    [xmppStream removeDelegate:self];
    [xmppStream disconnect];
}

#pragma mark - Core Data stack

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "student.unimelb.sxue1.Coredata" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Tripalocal" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Tripalocal.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}


#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Notification
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder"
                                                        message:notification.alertBody
                                                       delegate:self cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    // Request to reload table view data
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
    
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}


@end
