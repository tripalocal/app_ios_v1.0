//
//  ChatDetailViewController.m
//  
//
//  Created by 嵩薛 on 4/08/2015.
//
//

#import "ChatDetailViewController.h"
#import "Utility.h"
#import "ChatDetailFromTableViewCell.h"
#import "ChatDetailToTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SecureNSUserDefaults/NSUserDefaults+SecureAdditions.h>
#import "XMPP.h"
#import "DBManager.h"
#import "URLConfig.h"
#import "JGProgressHUD.h"
#import <Parse/Parse.h>

#define kOFFSET_FOR_KEYBOARD 215.0

@interface ChatDetailViewController ()

@property (nonatomic, strong) DBManager *dbManager;

@end

@implementation ChatDetailViewController{
    JGProgressHUD *HUD;
}
@synthesize sendButton,chatWithUser, sendBarView, allMessage, userImage, otherUserImageURL, otherUserImage;
@synthesize _messageDelegate;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


-(AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
-(XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}
//-(id) initWithUser:(NSString *) userName {
//    if (self = [super init]) {
//        chatWithUser = userName;
//    }
//    return self;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.HUDView.layer.shadowColor = [UIColor blackColor].CGColor;
    HUD.HUDView.layer.shadowOffset = CGSizeZero;
    HUD.HUDView.layer.shadowOpacity = 0.4f;
    HUD.HUDView.layer.shadowRadius = 8.0f;
    HUD.textLabel.text = NSLocalizedString(@"loading", nil);

    //set localized string for send button
    sendButton.titleLabel.text = NSLocalizedString(@"send_button", nil);
    UIView *topBorder = [UIView new];
    topBorder.backgroundColor = [UIColor grayColor];
    topBorder.frame = CGRectMake(-17, 0, sendBarView.frame.size.width, 1.0f);
    [sendBarView addSubview:topBorder];
    //get the time
    currentFlag = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    //allocate a new update array
    updateMessage = [[NSMutableArray alloc] init];
#if DEBUG
    NSLog(@"Current time when entering this view: %lld",currentFlag);
#endif

    //close button
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(dismissChatDetail:)];
    closeButton.tintColor = [Utility themeColor];
    self.navigationItem.leftBarButtonItem = closeButton;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
        AppDelegate *del = [self appDelegate];
    del._messageDelegate = self;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 200.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView reloadData];
    _shouldScrollToLastRow = YES;
    //growing textView
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(10, 15, 260, 40)];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 3;
    // you can also set the maximum height in points with maxHeight
//    textView.maxHeight = 60.0f;
    textView.returnKeyType = UIReturnKeyGo; //just as an example
    textView.layer.borderWidth = 1.0f;
    textView.layer.borderColor = [[UIColor grayColor] CGColor];
    textView.layer.cornerRadius = 5.0f;
    [sendBarView addSubview:textView];
    NSLayoutConstraint *bottomSpaceConstraint = [NSLayoutConstraint constraintWithItem:textView
                                                                             attribute:NSLayoutAttributeBottom
                                                                             relatedBy:0
                                                                                toItem:self.sendBarView
                                                                             attribute:NSLayoutAttributeBottom
                                                                            multiplier:1.0
                                                                              constant:-12.0];
//    NSLayoutConstraint *topSpaceConstraint = [NSLayoutConstraint constraintWithItem:self.tableView
//                                                                             attribute:NSLayoutAttributeBottom
//                                                                             relatedBy:0
//                                                                                toItem:self.sendBarView
//                                                                             attribute:NSLayoutAttributeTop
//                                                                            multiplier:1.0
//                                                                              constant:0.0];

    [self.sendBarView addConstraint:bottomSpaceConstraint];
//    [self.view addConstraint:topSpaceConstraint];
    [textView resignFirstResponder];
	sendBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [HUD showInView:self.view];
    [HUD dismissAfterDelay:1.0];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //get the user avatar
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    userImage = [UIImage imageWithData:[userDefaults objectForKey:@"user_image"]];
    //get the other users_img
    NSString *url_with_id = [NSString stringWithFormat:@"%@%@%@",[URLConfig servicePublicProfileURLString],@"?user_id=",chatWithUser];
    NSURL *url = [NSURL URLWithString:url_with_id];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"GET"];
    NSString *token = [[NSUserDefaults standardUserDefaults] secretObjectForKey:@"user_token"];
    [request setValue:[NSString stringWithFormat:@"token %@",token] forHTTPHeaderField:@"Authorization"];
    NSError *connectionError = nil;
    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    if (connectionError == nil) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
            										options:0
                                                    error:nil];
        
        if ([httpResponse statusCode] == 200) {
            otherUserImageURL = [result objectForKey:@"image"];
            if (otherUserImageURL.length != 0) {
                 otherUserImage = [self fetchImage:token :otherUserImageURL];
            }else{
                otherUserImage = [UIImage imageNamed:@"default_profile_image.png"];
            }
           
        }
#if DEBUG
        NSString *decodedData = [[NSString alloc] initWithData:data
                                                      encoding:NSUTF8StringEncoding];
        NSLog(@"Receiving data = %@", decodedData);
#endif
    	
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_network", nil)
                                                        message:NSLocalizedString(@"no_network_msg", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"ok_button", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }

    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
    self.allMessage = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    allRelevantMessage = [[NSMutableArray alloc] init];
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *sender_id = [userDefault objectForKey:@"user_id"];
    for (NSManagedObject *message in allMessage){
        
        if ([[message valueForKey:@"sender_id"] intValue] == [sender_id intValue] && [[message valueForKey:@"receiver_id"] intValue] == [chatWithUser intValue]) {
            
            [allRelevantMessage addObject:message];
        } else if ([[message valueForKey:@"receiver_id"] intValue] == [sender_id intValue] && [[message valueForKey:@"sender_id"] intValue] == [chatWithUser intValue]){
    
            [allRelevantMessage addObject:message];
        }
    }
    //sort the local arrary
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"local_id"
                                                 ascending:YES];
    NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [[NSArray alloc]init];
    sortedMessage = [[NSMutableArray alloc]init];
    sortedArray = [allRelevantMessage sortedArrayUsingDescriptors:sortDescriptors];
    [sortedMessage addObjectsFromArray:sortedArray];
    
    //get the message from web service if they are missing
    NSManagedObject *lastObject = [sortedArray lastObject];
    NSString *lastGolablID = [lastObject valueForKey:@"global_id"];
    if (lastGolablID.length != 0 || [sortedArray count] == 0) {
        if (lastGolablID.length == 0){
            lastGolablID = @"1";
        }
        NSString *url_with_id_msg = [NSString stringWithFormat:@"%@%@%@%@%@",[URLConfig serviceMessageURLString],@"?last_update_id=",lastGolablID,@"&sender_id=",chatWithUser];
        NSURL *url_msg = [NSURL URLWithString:url_with_id_msg];
        NSMutableURLRequest *request_msg = [NSMutableURLRequest requestWithURL:url_msg];
        [request_msg setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request_msg setHTTPMethod:@"GET"];
        [request_msg setValue:[NSString stringWithFormat:@"token %@",token] forHTTPHeaderField:@"Authorization"];
        NSData *data_msg = [NSURLConnection sendSynchronousRequest:request_msg returningResponse:&response error:&connectionError];
    #if DEBUG
        NSString * decodedData =[[NSString alloc] initWithData:data_msg encoding:NSUTF8StringEncoding];
        NSLog(@"Sending data = %@", decodedData);
    #endif
        if (connectionError == nil) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            
            NSArray *result_msg = [NSJSONSerialization JSONObjectWithData:data_msg
                                                                   options:0
                                                                     error:nil];
            
            if ([httpResponse statusCode] == 200) {
                if ([result_msg count] != 0) {
                    for (NSDictionary *message_info in result_msg){
                        NSNumber *global_id = [message_info objectForKey:@"id"];
                        NSNumber *receiver_id = [message_info objectForKey:@"receiver_id"];
                        NSString *msg_content = [message_info objectForKey:@"msg_content"];
                        NSNumber *sender_id = [message_info objectForKey:@"sender_id"];
                        NSString *msg_date = [message_info objectForKey:@"msg_date"];
                        //save the new data
                        //core data
                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
                        NSManagedObjectContext *context = appDelegate.managedObjectContext;
                        
                        // Create a new managed object
                        NSManagedObject *newMessage = [NSEntityDescription
                                                       insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
                        long long local_id = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
    #if DEBUG
                        NSLog(@"Current time when entering this view: %lld",local_id);
    #endif
                        [newMessage setValue:[NSString stringWithFormat:@"%lld",local_id] forKey:@"local_id"];
                        [newMessage setValue:[NSString stringWithFormat:@"%@",receiver_id] forKey:@"receiver_id"];
                        [newMessage setValue:[NSString stringWithFormat:@"%@",sender_id] forKey:@"sender_id"];
                        [newMessage setValue:[NSString stringWithFormat:@"%@",global_id] forKey:@"global_id"];
                        [newMessage setValue:msg_content forKey:@"message_content"];
                        [newMessage setValue:msg_date forKey:@"message_time"];
    #if DEBUG
                        NSLog(@"new message: %@ \n local_id : %lld", newMessage, local_id);
    #endif
                        NSError *error = nil;
                        // Save the object to persistent store
                        if (![context save:&error]) {
                            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
                        }

                    }
                }
            }
    #if DEBUG
            NSString *decodedData = [[NSString alloc] initWithData:data_msg
                                                          encoding:NSUTF8StringEncoding];
            NSLog(@"Receiving data = %@", decodedData);
    #endif
            NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
            self.allMessage = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
            allRelevantMessage = [[NSMutableArray alloc] init];
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            NSString *sender_id = [userDefault objectForKey:@"user_id"];
            for (NSManagedObject *message in allMessage){
                
                if ([[message valueForKey:@"sender_id"] intValue] == [sender_id intValue] && [[message valueForKey:@"receiver_id"] intValue] == [chatWithUser intValue]) {
                    
                    [allRelevantMessage addObject:message];
                } else if ([[message valueForKey:@"receiver_id"] intValue] == [sender_id intValue] && [[message valueForKey:@"sender_id"] intValue] == [chatWithUser intValue]){
                    
                    [allRelevantMessage addObject:message];
                }
            }
            //sort the local arrary
            NSSortDescriptor *sortDescriptor;
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"local_id"
                                                         ascending:YES];
            NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
            NSArray *sortedArray = [[NSArray alloc]init];
            sortedMessage = [[NSMutableArray alloc]init];
            sortedArray = [allRelevantMessage sortedArrayUsingDescriptors:sortDescriptors];
            [sortedMessage addObjectsFromArray:sortedArray];
        }
    }
    
    [self.tableView reloadData];
    if ([self.tableView numberOfRowsInSection:0] != 0) {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:NO];

    }
    
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Scroll table view to the last row
    if (_shouldScrollToLastRow)
    {
        _shouldScrollToLastRow = NO;
        [self.tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX + self.tableView.frame.size.height)];
    }
}


-(void)dismissKeyboard {
    [textView resignFirstResponder];
}
- (IBAction)dismissChatDetail:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    // unregister for keyboard notifications while not visible.
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIKeyboardWillShowNotification
//                                                  object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIKeyboardWillHideNotification
//                                                  object:nil];
//}


#pragma mark - send message function

- (IBAction)sendMessage:(id)sender {
	//get the user_id
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *sender_id = [userDefault objectForKey:@"user_id"];
    NSString *sender_address = [NSString stringWithFormat:@"%@@tripalocal.com",sender_id];
    
    //get current time in UTC
       NSString *timeStamp = [NSString stringWithFormat:@"%@%@",[[Utility getCurrentUTCTime] stringByReplacingOccurrencesOfString:@"\\" withString:@""],@"/000000"];
    // here you have new Date with desired format and TimeZone.
#if DEBUG
    NSLog(@"Timestamp: %@", timeStamp);
#endif
    
    //get the message string from textfield

    NSString *messageStr = textView.text;
    NSString *receiver_address = [NSString stringWithFormat:@"%@@tripalocal.com",chatWithUser];
#if DEBUG
    NSLog(@"Send msg to: %@", receiver_address);
#endif
    if([messageStr length] > 0){
        //send the message through XMPP
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        [body setStringValue:messageStr];
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"to" stringValue:receiver_address];
        [message addChild:body];
#if DEBUG
        NSLog(@"Sending message: %@",message);
#endif
        [self.xmppStream sendElement:message];
        
        //set the textField to blank after hit the send button
        textView.text = @"";
        //create a new string with sneding format
        //@"you" might need to be changed to senderID
        NSString *m = [NSString stringWithFormat:@"%@:%@",messageStr,sender_address];
#if DEBUG
        NSLog(@"Message with sender address: %@",m);
#endif
        //create a dictionary to contain all the necessary information of sending messages
        NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] init];
        [msgDic setObject:messageStr forKey:@"msg"];
        [msgDic setObject:sender_address forKey:@"sender"];
        //add sending message to the msgListTo

        
        //core data
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        NSManagedObjectContext *context = appDelegate.managedObjectContext;
        
        // Create a new managed object
        NSManagedObject *newMessage = [NSEntityDescription
                                       insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    	long long local_id = (long long)([[NSDate date] timeIntervalSince1970] * 1000.0);
#if DEBUG
        NSLog(@"Current time when entering this view: %lld",local_id);
#endif
        [newMessage setValue:[NSString stringWithFormat:@"%lld",local_id] forKey:@"local_id"];
        [newMessage setValue:[NSString stringWithFormat:@"%@",chatWithUser] forKey:@"receiver_id"];
        [newMessage setValue:[NSString stringWithFormat:@"%@", sender_id] forKey:@"sender_id"];
        [newMessage setValue:nil forKey:@"global_id"];
        [newMessage setValue:[msgDic objectForKey:@"msg"] forKey:@"message_content"];
        [newMessage setValue:timeStamp forKey:@"message_time"];
#if DEBUG
        NSLog(@"new message: %@ \n local_id : %lld", newMessage, local_id);
#endif
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
    allRelevantMessage = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"local_id"
                                                 ascending:YES];
    NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [[NSArray alloc]init];
    sortedMessage = [[NSMutableArray alloc]init];
    sortedArray = [allRelevantMessage sortedArrayUsingDescriptors:sortDescriptors];
    [sortedMessage addObjectsFromArray:sortedArray];
    //Push notification
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"deviceType" equalTo:@"ios"];
    
    // Send push notification to query
    [PFPush sendPushMessageToQueryInBackground:pushQuery
                                   withMessage:[NSString stringWithFormat:@"%@: %@", sender_id, messageStr]];
    [self.tableView reloadData];
    NSIndexPath* ip = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
//    [self.tableView setContentOffset:offset animated:YES];
}
//introducing the custom cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *sender_id = [userDefault objectForKey:@"user_id"];
    

    static NSString *cellFromIdentifier = @"ChatDetailFromCell";
    NSLog(@"Cell enter.");
    static NSString *cellToIdentifier = @"ChatDetailToCell";
    //test data
    NSManagedObject *message = [sortedMessage objectAtIndex:indexPath.row];
    
    //NSLog(@"From Cell loading!!!");
    
    if ([allRelevantMessage count]!=0) {
        if ([[message valueForKey:@"sender_id"] intValue] == [sender_id intValue] && [[message valueForKey:@"receiver_id"] intValue] == [chatWithUser intValue]) {
            //NSLog(@"TO: message Sender: %@ , userid: %@", [message valueForKey:@"sender_id"], sender_id);
            //[messageListTo addObject:message];
            ChatDetailToTableViewCell *cellTo = (ChatDetailToTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ChatDetailToCell"];
            if (!cellTo) {
                [tableView registerNib:[UINib nibWithNibName:@"ChatDetailToViewCell" bundle:nil] forCellReuseIdentifier:cellToIdentifier];
                cellTo = [tableView dequeueReusableCellWithIdentifier:cellToIdentifier];

            }
            cellTo.messageContent.text = [message valueForKey:@"message_content"];
            cellTo.messageTime.text = [Utility showTimeDifference:[message valueForKey:@"message_time"]];
            if (userImage) {
                cellTo.userImage.image = userImage;
            } else {
                cellTo.userImage.image = [UIImage imageNamed: @"default_profile_image.png"];
            }

            
            return cellTo;
        }else if ([[message valueForKey:@"receiver_id"] intValue] == [sender_id intValue] && [[message valueForKey:@"sender_id"] intValue] == [chatWithUser intValue])
        {
            //NSLog(@"FROM: message Sender: %d , userid: %d, equal: %d", [[message valueForKey:@"sender_id"] intValue], [sender_id intValue],[[message valueForKey:@"sender_id"] intValue] == [sender_id intValue]  );
            //[messageListFrom addObject:message];
            ChatDetailFromTableViewCell *cellFrom = (ChatDetailFromTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellFromIdentifier];
            if (!cellFrom) {
                [tableView registerNib:[UINib nibWithNibName:@"ChatDetailFromViewCell" bundle:nil] forCellReuseIdentifier:cellFromIdentifier];
                cellFrom = [tableView dequeueReusableCellWithIdentifier:cellFromIdentifier];
            }
            cellFrom.messageContent.text = [message valueForKey:@"message_content"];
            cellFrom.messageTime.text = [Utility showTimeDifference:[message valueForKey:@"message_time"]];
            cellFrom.otherUserImage.image = otherUserImage;
            
            return cellFrom;
        }
    }else{
        NSLog(@"message list empty, sample data.");
    }
    ChatDetailFromTableViewCell *cellFrom = (ChatDetailFromTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellFromIdentifier];
    if (!cellFrom) {
        [tableView registerNib:[UINib nibWithNibName:@"ChatDetailFromViewCell" bundle:nil] forCellReuseIdentifier:cellFromIdentifier];
        cellFrom = [tableView dequeueReusableCellWithIdentifier:cellFromIdentifier];
    }
    cellFrom.otherUserImage.image = nil;
    cellFrom.messageContent.text = @"";
    cellFrom.messageTime.text = @"";
    return cellFrom;

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    if ([messageListFrom count] != 0 || [messageListTo count] != 0) {
//        return [messageListFrom count] + [messageListTo count];
//    }else{
//        return 10;
//    }
    return [allRelevantMessage count];
}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//     return self.tableView.rowHeight;
//
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 200;
//}

#pragma mark Message received
- (void)newMessageReceived:(NSDictionary *)messageContent {
    
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
    self.allMessage = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
#if DEBUG
    NSLog(@"received in chatview!!");
#endif
    //get the last inserted entry and add it into allRelevantMessage
    [allRelevantMessage addObject:self.allMessage.lastObject];
    //sort the local arrary
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"local_id"
                                                 ascending:YES];
    NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [[NSArray alloc]init];
    sortedMessage = [[NSMutableArray alloc]init];
    sortedArray = [allRelevantMessage sortedArrayUsingDescriptors:sortDescriptors];
    [sortedMessage addObjectsFromArray:sortedArray];

    [self.tableView reloadData];
    NSIndexPath* ip = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];

}


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
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

#pragma mark uploading API
-(void)viewWillDisappear:(BOOL)animated{
    [self uploadingMessage];
}
-(void)uploadingMessage {
    
        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
        allMessage = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
        
        for (id message in allRelevantMessage)
        {
            if ([[message valueForKey:@"local_id"] longLongValue] > currentFlag) {
                NSLog(@"New Message!");
                NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     [NSNumber numberWithInt:[[message valueForKey:@"receiver_id"] intValue]], @"receiver_id",
                                     [message valueForKey:@"message_content"], @"msg_content",
                                     [message valueForKey:@"message_time"], @"msg_date",
                                     [NSNumber numberWithLongLong:[[message valueForKey:@"local_id"] longLongValue]], @"local_id",
                                     nil];
                
                [updateMessage addObject:tmp];
                
            }
        }
        updateDict = [[NSDictionary alloc] initWithObjectsAndKeys:updateMessage, @"messages", nil];
#if DEBUG
        NSLog(@"updated dict: %@",updateDict);
#endif
        //config the api url
        NSURL *url = [NSURL URLWithString:[URLConfig serviceMessageURLString]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];
        NSString *token = [[NSUserDefaults standardUserDefaults] secretObjectForKey:@"user_token"];
#if DEBUG
        NSLog(@"token; %@", token);
#endif
        [request addValue:[NSString stringWithFormat:@"token %@",token]  forHTTPHeaderField:@"Authorization"];
        if ([updateMessage count] != 0) {
            NSData *postdata = [NSJSONSerialization dataWithJSONObject:updateDict options:0 error:nil];
            [request setHTTPBody:postdata];
            
#if DEBUG
            NSString * decodedData =[[NSString alloc] initWithData:postdata encoding:NSUTF8StringEncoding];
            NSLog(@"Sending data = %@", decodedData);
#endif
            NSError *connectionError = nil;
            NSURLResponse *response = nil;
            
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
            
            if (connectionError == nil) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                
                NSMutableArray *result = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:0
                                                                           error:nil];
                
                if ([httpResponse statusCode] == 200) {
                    //update the global_id in core data
                    NSString *old_local_id = nil;
                    NSString *new_global_id = nil;
                    for (NSDictionary *m in result){
                        old_local_id = [NSString stringWithFormat:@"%@",[m objectForKey:@"local_id"]];
                        new_global_id = [NSString stringWithFormat:@"%@",[m objectForKey:@"global_id"]];
                        NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
                        NSFetchRequest * desFetctRequest = [NSFetchRequest fetchRequestWithEntityName:@"Message"];
                        NSPredicate *local_id_Predicate = [NSPredicate predicateWithFormat:@"local_id = %@", old_local_id];
                        [desFetctRequest setPredicate:local_id_Predicate];
                        NSError *error = nil;
                        NSArray *selectedMsgs = [managedObjectContext executeFetchRequest:desFetctRequest error:&error];
                        NSManagedObject* rightMsg = [selectedMsgs objectAtIndex:0];
                        [rightMsg setValue:new_global_id forKey:@"global_id"];
                        NSLog(@"GLOBAL ID: %@",[rightMsg valueForKey:@"global_id"]);
                    }
                }
#if DEBUG
                NSString *decodedData = [[NSString alloc] initWithData:data
                                                              encoding:NSUTF8StringEncoding];
                NSLog(@"Receiving data = %@", decodedData);
#endif
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_network", nil)
                                                                message:NSLocalizedString(@"no_network_msg", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"ok_button", nil)
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
        
}

#pragma mark HPGrowTextVIEW

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = sendBarView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    sendBarView.frame = r;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


#pragma mark Fetch image
- (UIImage *) fetchImage:(NSString *) token :(NSString *) imageURL {
    NSString *absoluteImageURL = [NSString stringWithFormat:@"%@%@", [URLConfig imageServiceURLString], imageURL];
    NSURL *url = [NSURL URLWithString:absoluteImageURL];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    NSError *connectionError = nil;
    NSURLResponse *response = nil;
    UIImage *image = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    if (connectionError == nil) {
        image = [UIImage imageWithData:data];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_network", nil)
                                                        message:NSLocalizedString(@"no_network_msg", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"ok_button", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    return image;
}

@end
