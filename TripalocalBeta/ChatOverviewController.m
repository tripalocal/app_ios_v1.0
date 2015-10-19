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


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:1.0]];
    NSLog(@"View loading.");
    HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.HUDView.layer.shadowColor = [UIColor blackColor].CGColor;
    HUD.HUDView.layer.shadowOffset = CGSizeZero;
    HUD.HUDView.layer.shadowOpacity = 0.4f;
    HUD.HUDView.layer.shadowRadius = 8.0f;
    HUD.textLabel.text = NSLocalizedString(@"loading", nil);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(dismissChatOverview:)];
    closeButton.tintColor = [Utility themeColor];
    self.navigationItem.leftBarButtonItem = closeButton;
    //loading the message data in here
    //	:load three arraies
    
    //set view controller as a delegate for the chat protocol
    AppDelegate *del = [self appDelegate];
    del._chatDelegate = self;
	//get the user info
    [HUD showInView:self.view];
    [HUD dismissAfterDelay:1.0];
    
}
-(void)viewDidAppear:(BOOL)animated {
//    [[self appDelegate] connect];
    [super viewDidAppear:animated];
    // how to get the user id
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [userDefaults objectForKey:@"user_id"];
    NSLog(@"show chat list");
    
    [self showChatList];
    NSLog(@"chat list shown");
    [self.tableView reloadData];
//	if ([[self appDelegate] connect]) {
//            
//        
//    }else {
//        NSLog(@"show sign in");
//        [self showLogin];
//    }
}


-(IBAction)showLogin {
    UnloginViewController *unLoginController = [[UnloginViewController alloc] init];
    [self presentViewController:unLoginController animated:YES completion:nil];
}

-(void)showChatList {
    //initial the information arraies
    imgList = [[NSMutableArray alloc] init];
    nameList = [[NSMutableArray alloc] init];
    messageList = [[NSMutableArray alloc] init];
    timeList = [[NSMutableArray alloc] init];
    sender_id_list = [[NSMutableArray alloc] init];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults secretObjectForKey:@"user_token"];
    NSString *user_id = [userDefaults objectForKey:@"user_id"];
    NSURL *url = [NSURL URLWithString:[URLConfig serviceMessageListURLString]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod:@"GET"];
    [request addValue:[NSString stringWithFormat:@"Token %@", token] forHTTPHeaderField:@"Authorization"];
    
    NSError *connectionError = nil;
    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    if (connectionError == nil) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSDictionary *messageDetail = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([httpResponse statusCode] == 200) {
            for (id message_info in messageDetail) {
                
                
                NSLog(@"messageInfo loading...");
                
                NSString *global_id = [message_info objectForKey:@"id"];
                NSString *sender_id = [message_info objectForKey:@"sender_id"];
                
                NSString *messageContent = [message_info objectForKey:@"msg_content"];
                
                NSString *messageDate = [message_info objectForKey:@"msg_date"];
                NSString *senderImageURL = [message_info objectForKey:@"sender_image"];
                UIImage *image = [self fetchImage:token :senderImageURL];
                
    //            NSInteger global_id = [[NSString stringWithFormat: @"%@", [messageInfo valueForKeyPath: @"id" ] ] integerValue ];
                NSString *sender_name = [message_info valueForKey:@"sender_name"];
                //compare the api data with core data
				NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
                self.allMessage = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
                for (NSManagedObject *message in allMessage){
                    if ([[message valueForKey:@"global_id"] integerValue] > [global_id integerValue]){
                        if ([[message valueForKey:@"sender_id"] isEqualToString:[NSString stringWithFormat:@"%@", user_id]]) {
                            messageContent = [message valueForKey:@"message_content"];
                            messageDate = [message valueForKey:@"message_time"];
                        }
                    }
                }
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
        	//}
            [self.tableView reloadData];
        }
    }
#if DEBUG
    NSString *decodedData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Receiving data = %@", decodedData);
#endif
    
}
- (IBAction)dismissChatOverview:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"ChatOverviewCell";
    
    ChatOverviewTableViewCell *cell = (ChatOverviewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ChatOverviewCell"];
    if(!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"ChatOverviewViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    //load data
    NSLog(@"Loading cell data!");
    
//    [self showChatList];
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

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //    return [self.imgList count];
    //return 2;
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
        UINavigationController *navController = segue.destinationViewController;
        ChatDetailViewController *destViewController = navController.topViewController;
        
#if DEBUG
        NSLog(@"passing string: %@",[sender_id_list objectAtIndex:indexPath.row]);
        
#endif
        destViewController.chatWithUser = [sender_id_list objectAtIndex:indexPath.row];
    }
}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
