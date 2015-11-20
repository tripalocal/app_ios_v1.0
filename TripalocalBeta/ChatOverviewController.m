//
//  ChatOverviewController.h
//  TripalocalBeta
//
//  Created by Song Xue on 4/08/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "ChatOverviewController.h"
#import "ChatOverviewTableViewCell.h"
#import "ChatDetailViewController.h"
#import "URLConfig.h"
#import "Utility.h"
#import <SecureNSUserDefaults/NSUserDefaults+SecureAdditions.h>
#import "XMPP.h"
#import "UnloginViewController.h"
#import "JGProgressHUD.h"
#import "Message.h"

static NSString *customerServiceID = @"5001";
static NSString *customerServiceImgName = @"customerServiceImg";

@interface ChatOverviewController()

@end

@implementation ChatOverviewController  {
    JGProgressHUD *HUD;
    NSInteger _clickedRow;
}
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel= _managedObjectModel;
@synthesize allMessage;

-(AppDelegate *)appDelegate {
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(XMPPStream *)xmppStream {
    return [[self appDelegate] xmppStream];
}
#pragma mark View
- (void)viewDidLoad {
    [super viewDidLoad];
    // Setup tableview delegate and data source
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.title = @"Messages";
    // Set the back button
    // ***********
    // Removable !!
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(dismissChatOverview:)];
    closeButton.tintColor = [Utility themeColor];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:1.0]];
    self.navigationItem.leftBarButtonItem = closeButton;
    // ***********
    //set view controller as a delegate for the chat protocol
    AppDelegate *del = [self appDelegate];
    del._chatDelegate = self;
    // Setup HUD
    HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.HUDView.layer.shadowColor = [UIColor blackColor].CGColor;
    HUD.HUDView.layer.shadowOffset = CGSizeZero;
    HUD.HUDView.layer.shadowOpacity = 0.4f;
    HUD.HUDView.layer.shadowRadius = 8.0f;
    HUD.textLabel.text = NSLocalizedString(@"loading", nil);
    [HUD showInView:self.view];
    [HUD dismissAfterDelay:1.0];
    
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Show chat list
    [self showChatList];
    [self.tableView reloadData];
}
- (IBAction)dismissChatOverview:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// *************
// Can remove because user can't get in this view without login
-(IBAction)showLogin {
    UnloginViewController *unLoginController = [[UnloginViewController alloc] init];
    [self presentViewController:unLoginController animated:YES completion:nil];
}
// *************
#pragma mark Show chat_list
-(void)showChatList {
    //initial the message arraies
    //# Store image urls (user profile images) #
    imgList = [[NSMutableArray alloc] init];
    //# Store usernames #
    nameList = [[NSMutableArray alloc] init];
    //# Store last message content of coresponding conversation #
    messageList = [[NSMutableArray alloc] init];
    //# Store timestamps of those messages #
    timeList = [[NSMutableArray alloc] init];
    //# Store senders' user_id #
    sender_id_list = [[NSMutableArray alloc] init];
    // Get the current user info
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults secretObjectForKey:@"user_token"];
    NSString *user_id = [userDefaults objectForKey:@"user_id"];
    //# Request from service_message_list API
    NSURL *url = [NSURL URLWithString:[URLConfig serviceMessageListURLString]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // GET /service_message_list/
    [request setHTTPMethod:@"GET"];
    [request addValue:[NSString stringWithFormat:@"Token %@", token] forHTTPHeaderField:@"Authorization"];
    NSError *connectionError = nil;
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    NSMutableArray *sender_list = [[NSMutableArray alloc] init];
    NSMutableArray *new_chat_list = [[NSMutableArray alloc] init];
    
    if (connectionError == nil) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSDictionary *messageDetail = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([httpResponse statusCode] == 200)
        {
            for (id message_info in messageDetail) {
                NSString *global_id = [message_info objectForKey:@"id"];
                NSString *sender_id = [message_info objectForKey:@"sender_id"];
                NSString *messageContent = [message_info objectForKey:@"msg_content"];
                NSString *messageDate = [message_info objectForKey:@"msg_date"];
                NSString *senderImageURL = [message_info objectForKey:@"sender_image"];
                NSString *sender_name = [message_info valueForKey:@"sender_name"];
                UIImage *image = [self fetchImage:token :senderImageURL];
                [sender_list addObject:[NSString stringWithFormat:@"%@", sender_id]];
                // Compare the API data with core data
                NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
                // Fetching all message from core data
                self.allMessage = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
                // Sift out irrelevant messsages
                for (NSManagedObject *message in allMessage){
                    // Sift out those messages which are not new
                    if ([[message valueForKey:@"global_id"] integerValue] > [global_id integerValue]){
                        // Sift out those messages which are not belonged to this conversation
                        if ([[message valueForKey:@"receiver_id"] isEqualToString: [NSString stringWithFormat:@"%@",sender_id]]) {
                            // Override the message content and timestamp with latest one
                            messageContent = [message valueForKey:@"message_content"];
                            messageDate = [message valueForKey:@"message_time"];
                        }
                    }
                }
                // Calculate the time difference
                NSString *diff = [Utility showTimeDifference:messageDate];
                NSLog(@"content: %@, date: %@, image: %@, name: %@, sender_id: %@", messageContent, messageDate,senderImageURL, sender_name, sender_id);
                
                //if (!([messageList containsObject:messageContent] && [sender_id_list containsObject:sender_id])) {
                if (image){
                    [imgList addObject:image];
                } else {
                    [imgList addObject:[UIImage imageNamed:@"default_profile_image.png"]];
                }
                [sender_id_list addObject:sender_id];
                [nameList addObject:sender_name];
                [messageList addObject:messageContent];
                [timeList addObject:diff];
            }
            //temp fix
            //*********************
            for (NSManagedObject *message in allMessage){
                NSNumber *tmp = [message valueForKey:@"sender_id"];
                if (![sender_list containsObject:tmp] && ![new_chat_list containsObject:tmp]){
                    NSNumber *senderId = [message valueForKey:@"sender_id"];
                    if ([senderId integerValue] != [user_id integerValue])
                    {
                        [new_chat_list addObject:[message valueForKey:@"sender_id"]];
                    }
                }
            }
            if ([new_chat_list count] != 0)
            {
                for (NSString *new_id in new_chat_list){
                    NSString *url_with_id = [NSString stringWithFormat:@"%@%@%@",[URLConfig servicePublicProfileURLString],@"?user_id=",new_id];
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
                            NSString *otherUserImageURL = [result objectForKey:@"image"];
                            otherUserFirstName = [result objectForKey:@"first_name"];
                            otherUserLastName = [result objectForKey:@"last_name"];
                            
                            if (otherUserImageURL.length != 0) {
                                UIImage *otherUserImage = [self fetchImage:token :otherUserImageURL];
                                [imgList addObject:otherUserImage];
                            }else{
                                UIImage *otherUserImage = [UIImage imageNamed:@"default_profile_image.png"];
                                [imgList addObject:otherUserImage];
                            }
                            [nameList addObject:otherUserFirstName];
                            [sender_id_list addObject:new_id];
                            NSString *messageContent = nil;
                            NSString *messageDate = nil;
                            for (NSManagedObject *message in allMessage){
                                // Sift out those messages which are not new
                                if ([[message valueForKey:@"receiver_id"] isEqualToString: [NSString stringWithFormat:@"%@",new_id]]) {
                                        // Override the message content and timestamp with latest one
                                        messageContent = [message valueForKey:@"message_content"];
                                        messageDate = [message valueForKey:@"message_time"];
                                }
                            }
                            NSString *diff = [Utility showTimeDifference:messageDate];
                            [messageList addObject:messageContent];
                            [timeList addObject:diff];
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
            
            
            // remove user self from list
            // I cannot endure the poor quality of the code anymore
            
//            NSInteger selfIdx = -1;
//            for (NSObject *sender_id in sender_id_list)
//            {
//                if ([sender_id isKindOfClass:[NSNumber class]])
//                {
//                    if ([(NSNumber *)sender_id integerValue] == [user_id integerValue])
//                    {
//                        selfIdx = [sender_id_list indexOfObject:sender_id];
//                        break;
//                    }
//                }
//                else if ([sender_id isKindOfClass:[NSString class]])
//                {
//                    if ([(NSString *)sender_id isEqualToString:user_id])
//                    {
//                        selfIdx = [sender_id_list indexOfObject:sender_id];
//                        break;
//                    }
//                }
//                else
//                {
//                    NSLog(@"what the hell is that?!");
//                    abort();
//                }
//            }
//            if (selfIdx != -1)
//            {
//                [imgList removeObjectAtIndex:selfIdx];
//                [nameList removeObjectAtIndex:selfIdx];
//                [messageList removeObjectAtIndex:selfIdx];
//                [timeList removeObjectAtIndex:selfIdx];
//                [sender_id_list removeObjectAtIndex:selfIdx];
//            }
            
            // add customer service at top
            // Attemption!! Guys, if you are reading the codes and think those
            //  codes are totally shit, do not unleash your anger on me, because
            //  i am also the victim.
            
            NSInteger csIdx = -1;
            for (NSObject *sender_id in sender_id_list)
            {
                if ([sender_id isKindOfClass:[NSNumber class]])
                {
                    if ([(NSNumber *)sender_id integerValue] == [customerServiceID integerValue])
                    {
                        csIdx = [sender_id_list indexOfObject:sender_id];
                        break;
                    }
                }
                else if ([sender_id isKindOfClass:[NSString class]])
                {
                    if ([(NSString *)sender_id isEqualToString:customerServiceID])
                    {
                        csIdx = [sender_id_list indexOfObject:sender_id];
                        break;
                    }
                }
                else
                {
                    NSLog(@"what the hell is that?!");
                    abort();
                }
            }
            if (csIdx == -1)
            {
                // add customer service at top
                [imgList insertObject:[UIImage imageNamed:customerServiceImgName] atIndex:0];
                [nameList insertObject:NSLocalizedString(@"customer_service_name", nil) atIndex:0];
                [messageList insertObject:NSLocalizedString(@"customer_service_placeholder", nil) atIndex:0];
                [timeList insertObject:@"" atIndex:0];
                [sender_id_list insertObject:customerServiceID atIndex:0];
            }
            else
            {
                // move to top
//                [self moveObjectInArray:imgList fromIndex:csIdx toIndex:0];
//                [self moveObjectInArray:nameList fromIndex:csIdx toIndex:0];
                [imgList removeObjectAtIndex:csIdx];
                [imgList insertObject:[UIImage imageNamed:customerServiceImgName] atIndex:0];
                [nameList removeObjectAtIndex:csIdx];
                [nameList insertObject:NSLocalizedString(@"customer_service_name", nil) atIndex:0];
                [self moveObjectInArray:messageList fromIndex:csIdx toIndex:0];
                [self moveObjectInArray:timeList fromIndex:csIdx toIndex:0];
                [self moveObjectInArray:sender_id_list fromIndex:csIdx toIndex:0];
            }
            
            [self.tableView reloadData];
        }
    }
#if DEBUG
    NSString *decodedData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Receiving data = %@", decodedData);
#endif
    
}

- (void) moveObjectInArray:(NSMutableArray *) array fromIndex:(NSInteger) fromIndex toIndex:(NSInteger) toIndex
{
    NSObject *obj = [array objectAtIndex:fromIndex];
    [array removeObjectAtIndex:fromIndex];
    [array insertObject:obj atIndex:toIndex];
}

#pragma mark Tableview

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"ChatOverviewCell";
    
    ChatOverviewTableViewCell *cell = (ChatOverviewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ChatOverviewCell"];
    if(!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"ChatOverviewViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    if ([nameList count]!=0) {
        cell.userImage.image = [imgList objectAtIndex:indexPath.row];
        cell.userName.text = [nameList objectAtIndex:indexPath.row];
        cell.messageContent.text = [messageList objectAtIndex:indexPath.row];
        cell.messageTime.text = [timeList objectAtIndex:indexPath.row];
    }
    else{
        cell.userImage.image = nil;
        cell.userName.text = @"";
        cell.messageContent.text = @"";
        cell.messageTime.text = @"";
    }
    return cell;
}
// Fix table cell height
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [nameList count];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //start a chat
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"showDetail" sender: indexPath];
    _clickedRow = indexPath.row;
#if DEBUG
    NSLog(@"Selected row: %ld", (long)_clickedRow);
#endif
}
//USE WHEN NEED PASS DATA THROUGH SEGUE
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([segue.identifier isEqualToString:@"showDetail"]){
        NSIndexPath *indexPath = (NSIndexPath *)sender;
    	ChatDetailViewController *destViewController = (ChatDetailViewController *)segue.destinationViewController;
        
#if DEBUG
        NSLog(@"passing string: %@",[sender_id_list objectAtIndex:indexPath.row]);
        
#endif
        destViewController.chatWithUser = [sender_id_list objectAtIndex:indexPath.row];
        destViewController.otherUserFirstName = [nameList objectAtIndex:indexPath.row];
    }
}
#pragma mark Helper
- (UIImage *) fetchImage:(NSString *) token :(NSString *) imageURL {
    if (imageURL == nil || [imageURL isEqual:[NSNull null]])
    {
        return nil;
    }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark Core data utility
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

@end
