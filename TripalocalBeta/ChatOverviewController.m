//
//  ChatOverviewController.h
//  TripalocalBeta
//
//  Created by Song Xue on 4/08/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "ChatOverviewController.h"
#import "ChatOverviewTableViewCell.h"
#import "URLConfig.h"
#import "Utility.h"
#import <SecureNSUserDefaults/NSUserDefaults+SecureAdditions.h>
#import "XMPP.h"


@interface ChatOverviewController()

@end

@implementation ChatOverviewController {
//    NSMutableArray *_imgList;
//    NSMutableArray *_nameLIst;
//    NSMutableArray *_messageList;
//    NSMutableArray *_timeList;
}

//- (AppDelegate *)appDelegate {
//    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
//}

//- (XMPPStream *)xmppStream {
//    return [[self appDelegate] xmppStream];
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(dismissChatOverview:)];
    closeButton.tintColor = [Utility themeColor];
    self.navigationItem.leftBarButtonItem = closeButton;
    //initial the information arraies
    imgList = [[NSMutableArray alloc] init];
    nameList = [[NSMutableArray alloc] init];
    messageList = [[NSMutableArray alloc] init];
    timeList = [[NSMutableArray alloc] init];
    //loading the message data in here
    //	:load three arraies

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
    cell.userImage.image = [UIImage imageNamed:@"flash.png"];
    cell.userName.text = @"FRANK";
    cell.messageContent.text = @"welcome to tripalocal.";
    cell.messageTime.text = @"3 mins";
    
//    cell.userImage.image = [imgList objectAtIndex:indexPath.row];
//    cell.userName.text = [nameList objectAtIndex:indexPath.row];
//    cell.messageContent.text = [messageList objectAtIndex:indexPath.row];
//    cell.messageTime.text = [messageList objectAtIndex:indexPath.row];
    
    return cell;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //    return [self.imgList count];
    return 1;
    //return [nameList count];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //start a chat
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"showDetail" sender: self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
