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
#define kOFFSET_FOR_KEYBOARD 215.0

@interface ChatDetailViewController ()

@property (nonatomic, strong) DBManager *dbManager;

@end

@implementation ChatDetailViewController
@synthesize textField,sendButton,chatWithUser, sendBarView, allMessage, userImage, otherUserImageURL;
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
    //set localized string for send button
    sendButton.titleLabel.text = NSLocalizedString(@"send_button", nil);
    UIView *topBorder = [UIView new];
    topBorder.backgroundColor = [UIColor grayColor];
    topBorder.frame = CGRectMake(0, 0, sendBarView.frame.size.width, 1.0f);
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
    textField.layer.borderWidth = 1.0f;
    textField.layer.borderColor = [[UIColor grayColor] CGColor];
    textField.layer.cornerRadius = 5.0f;
    AppDelegate *del = [self appDelegate];
    del._messageDelegate = self;
    [self.textField resignFirstResponder];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = 200.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView reloadData];
    _shouldScrollToLastRow = YES;
    
  }
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //get the user avatar
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    userImage = [UIImage imageWithData:[userDefaults objectForKey:@"user_image"]];
    //get the other users_img
	
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
    self.allMessage = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];

    
    [self.tableView reloadData];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Scroll table view to the last row
    if (_shouldScrollToLastRow)
    {
        _shouldScrollToLastRow = NO;
        [self.tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
    }
}

#pragma mark - dismiss keyboard (buggy)

-(void)dismissKeyboard {
    [textField resignFirstResponder];
}
- (IBAction)dismissChatDetail:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}
-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}
-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    if ([sender isEqual:textField])
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0)
        {
            [self setViewMovedUp:YES];
        }
    }
}
//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - core data
//- (NSManagedObjectContext *)managedObjectContext {
//    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
//    if (_managedObjectContext != nil) {
//        return _managedObjectContext;
//    }
//    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (!coordinator) {
//        return nil;
//    }
//    _managedObjectContext = [[NSManagedObjectContext alloc] init];
//    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
//    id delegate = [[UIApplication sharedApplication] delegate];
//    if ([delegate performSelector:@selector(managedObjectContext)]) {
//        _managedObjectContext = [delegate managedObjectContext];
//    }
//
//    return _managedObjectContext;
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

    NSString *messageStr = self.textField.text;
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
        self.textField.text = @"";
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
    self.allMessage = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];


    [self.tableView reloadData];
    CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
    [self.tableView setContentOffset:offset animated:YES];
}
//introducing the custom cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *sender_id = [userDefault objectForKey:@"user_id"];
    

    static NSString *cellFromIdentifier = @"ChatDetailFromCell";
    NSLog(@"Cell enter.");
    static NSString *cellToIdentifier = @"ChatDetailToCell";
   
    //test data
    NSManagedObject *message = [self.allMessage objectAtIndex:indexPath.row];
    
    //NSLog(@"From Cell loading!!!");
    
    if ([self.allMessage count]!=0) {
        if ([[message valueForKey:@"sender_id"] intValue] == [sender_id intValue] && [[message valueForKey:@"receiver_id"] intValue] == [chatWithUser intValue]) {
            //NSLog(@"TO: message Sender: %@ , userid: %@", [message valueForKey:@"sender_id"], sender_id);
            [messageListTo addObject:message];
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
            [messageListFrom addObject:message];
            ChatDetailFromTableViewCell *cellFrom = (ChatDetailFromTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellFromIdentifier];
            if (!cellFrom) {
                [tableView registerNib:[UINib nibWithNibName:@"ChatDetailFromViewCell" bundle:nil] forCellReuseIdentifier:cellFromIdentifier];
                cellFrom = [tableView dequeueReusableCellWithIdentifier:cellFromIdentifier];
            }
            cellFrom.messageContent.text = [message valueForKey:@"message_content"];
            cellFrom.messageTime.text = [Utility showTimeDifference:[message valueForKey:@"message_time"]];
            [cellFrom.otherUserImage sd_setImageWithURL:[NSURL URLWithString:otherUserImageURL]
                              placeholderImage:[UIImage imageNamed:@"default_profile_image.png"]
                                       options:SDWebImageRefreshCached];
            
            return cellFrom;
        }
    }
    else{
        NSLog(@"message list empty, sample data.");
        
    }
    ChatDetailFromTableViewCell *cellFrom = (ChatDetailFromTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellFromIdentifier];
    if (!cellFrom) {
        [tableView registerNib:[UINib nibWithNibName:@"ChatDetailFromViewCell" bundle:nil] forCellReuseIdentifier:cellFromIdentifier];
        cellFrom = [tableView dequeueReusableCellWithIdentifier:cellFromIdentifier];
    }
    cellFrom.otherUserImage.image = [UIImage imageNamed:@"flash.png"];
    cellFrom.messageContent.text = @"hello!";
    cellFrom.messageTime.text = @"1 mins";
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
    return [allMessage count];
}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//     return self.tableView.rowHeight;
//
//}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 200;
}

#pragma mark Message received
- (void)newMessageReceived:(NSDictionary *)messageContent {
    
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
    self.allMessage = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
#if DEBUG
    NSLog(@"received in chatview!!");
#endif
    [self.tableView reloadData];
    
    CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
    [self.tableView setContentOffset:offset animated:YES];

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
-(void)viewDidDisappear:(BOOL)animated{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
    allMessage = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    for (id message in allMessage)
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

@end
