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
#import "XMPP.h"
#import "DBManager.h"
#define kOFFSET_FOR_KEYBOARD 215.0

@interface ChatDetailViewController ()

@property (nonatomic, strong) DBManager *dbManager;

@end

@implementation ChatDetailViewController
@synthesize textField,detailTableView,sendButton,chatWithUser, sendBarView;
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
    //Init database object
    self.dbManager = [[DBManager alloc] initWithDatabaseFileName:@"message.sql"];
    //set the top border
    UIView *topBorder = [UIView new];
    topBorder.backgroundColor = [UIColor grayColor];
    topBorder.frame = CGRectMake(0, 0, sendBarView.frame.size.width, 1.0f);
    [sendBarView addSubview:topBorder];
    
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



#pragma mark - send message function

- (IBAction)sendMessage:(id)sender {
	//get the user_id
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *sender_id = [userDefault objectForKey:@"user_id"];
    NSString *sender_address = [NSString stringWithFormat:@"%@@tripalocal.com",sender_id];
    
    //get current time in UTC
       NSString *timeStamp = [Utility getCurrentUTCTime];
    // here you have new Date with desired format and TimeZone.

    
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
        NSString *m = [NSString stringWithFormat:@"@%:@%",messageStr,sender_address];
        //create a dictionary to contain all the necessary information of sending messages
        NSMutableDictionary *msgDic = [[NSMutableDictionary alloc] init];
        [msgDic setObject:messageStr forKey:@"msg"];
        [msgDic setObject:sender_address forKey:@"sender"];
        //add sending message to the msgListTo
        [messageListTo addObject:msgDic];
        [self.detailTableView reloadData];
    
        
        //core data
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        
        // Create a new managed object
        NSManagedObject *newMessage = [NSEntityDescription
                                       insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
        NSManagedObjectID *local_id = [newMessage objectID];
        [newMessage setValue:[NSString stringWithFormat:@"%@",local_id] forKey:@"local_id"];
        [newMessage setValue:[NSString stringWithFormat:@"%@",chatWithUser] forKey:@"receiver_id"];
        [newMessage setValue:[NSString stringWithFormat:@"%@", sender_id] forKey:@"sender_id"];
        [newMessage setValue:nil forKey:@"global_id"];
        [newMessage setValue:[msgDic objectForKey:@"msg"] forKey:@"message_content"];
        [newMessage setValue:timeStamp forKey:@"message_time"];
        NSError *error = nil;
        // Save the object to persistent store
        if (![context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }

//        //prepare the sql
//        self.dbManager = [[DBManager alloc] initWithDatabaseFileName:@"message.sql"];
//        //execute the sql command
//        NSString *query = [NSString stringWithFormat:@"INSERT INTO message VALUES(null, '%d', '%d', NULL,'%@', '%@')",[chatWithUser intValue],[sender_id intValue],[msgDic objectForKey:@"msg"],timeStamp];
//        [self.dbManager executeQuery:query];
//        
//        // If the query was successfully executed then pop the view controller.
//        if (self.dbManager.affectedRows != 0) {
//            NSLog(@"Query was executed successfully. Affected rows = %d", self.dbManager.affectedRows);
//            
//            // Pop the view controller.
//            [self.navigationController popViewControllerAnimated:YES];
//        }
//        else{
//            NSLog(@"Could not execute the query.");
//        }

    	}
    
    }
//introducing the custom cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellFromIdentifier = @"ChatDetailFromCell";
    static NSString *cellToIdentifier = @"ChatDetailToCell";
    ChatDetailFromTableViewCell *cellFrom = (ChatDetailFromTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ChatDetailFromCell"];
    ChatDetailToTableViewCell *cellTo = (ChatDetailToTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ChatDetailToCell"];
    if (!cellFrom) {
        [tableView registerNib:[UINib nibWithNibName:cellFromIdentifier bundle:nil] forCellReuseIdentifier:cellFromIdentifier];
    }
    if (!cellTo) {
        [tableView registerNib:[UINib nibWithNibName:cellToIdentifier bundle:nil] forCellReuseIdentifier:cellToIdentifier];
    }
    //test data
    cellFrom.otherUserImage.image = [UIImage imageNamed:@"flash.png"];
    cellFrom.messageContent.text = @"hello!";
    cellFrom.messageTime.text = @"1 mins";
    cellTo.userImage.image = [UIImage imageNamed:@"flash.png"];
    cellTo.messageContent.text = @"Hi, there.";
    cellTo.messageTime.text = @"Just now";
    //read data from array
//    cellFrom.otherUserImage.image = [fix img];
//    cellFrom.messageContent.text = [messageListFrom objectAtIndex:indexPath.row];
//    cellFrom.messageTime.text = [timeListFrom objectAtIndex:indexPath.row];
//    cellTo.userImage.image = [fix img];
//    cellTo.messageContent.text = [messageListTo objectAtIndex:indexPath.row];
//    cellTo.messageTime.text = [timeListTo objectAtIndex:indexPath.row];
    
    return cellFrom;
    return cellTo;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [messageListFrom count] + [messageListTo count];
}

@end
