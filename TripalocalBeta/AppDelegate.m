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

@interface AppDelegate ()
-(void)setupStream;
-(void)goOnline;
-(void)goOffline;
@end

@implementation AppDelegate
@synthesize xmppStream, viewController, _chatDelegate, _messageDelegate;

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
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self connect];
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
    xmppStream = [[XMPPStream alloc] init];
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}
-(void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
}
-(void)goOffline {
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"Unavailabel"];
    [[self xmppStream] sendElement:presence];
}
-(BOOL)connect {
    [self setupStream];
    NSString *jabberID = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"]];
    NSString *myPassword = jabberID;
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    
    if (jabberID == nil || myPassword == nil) {
        return NO;
    }
    
    [xmppStream setMyJID:[XMPPJID jidWithString:jabberID]];
    password = myPassword;
    NSError *error = nil;
    if (![xmppStream isConnected])
    {
        return NO;
    }
    return YES;
}
-(void)disconnect{
    [self goOffline];
    [xmppStream disconnect];
    [_chatDelegate didDisconnect];
}
-(void)xmppStreamDidConnect:(XMPPStream *)sender{
    isOpen = YES;
    NSError *error = nil;
    [[self xmppStream] authenticateWithPassword:password error:&error];
}
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    [self goOnline];
}
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    
    NSMutableDictionary *m = [[NSMutableDictionary alloc] init];
    [m setObject:msg forKey:@"msg"];
    [m setObject:from forKey:@"sender"];
    [_messageDelegate newMessageReceived:m];
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


@end
