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

@interface ChatOverviewController()

@end

@implementation ChatOverviewController {
//    NSMutableArray *_imgList;
//    NSMutableArray *_nameLIst;
//    NSMutableArray *_messageList;
//    NSMutableArray *_timeList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(dismissChatOverview:)];
    closeButton.tintColor = [Utility themeColor];
    self.navigationItem.leftBarButtonItem = closeButton;
    
    //loading the message data in here
    //	:load three arraies
//    NSMutableArray *_imgList = [[NSMutableArray alloc] init];
//    NSMutableArray *_nameList = [[NSMutableArray alloc] init];
//    NSMutableArray *_messageList = [[NSMutableArray alloc] init];
//    NSMutableArray *_timeList = [[NSMutableArray alloc] init];
    [self.imgList addObject: @"flash.png"];
    [self.imgList addObject: @"heart_lg.png"];
    
    [self.nameList addObject: @"Frank"];
    [self.nameList addObject: @"Felix"];
    
    [self.messageList addObject: @"Welcome to Tripalocal."];
    [self.messageList addObject: @"Welcome to Tripalocal."];
   
    [self.timeList addObject: @"3 mins"];
    [self.timeList addObject: @"2 mins"];
}

- (IBAction)dismissChatOverview:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return [self.imgList count];
    return 1;
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
//    cell.userImage.image = [UIImage imageNamed: [self.imgList objectAtIndex: indexPath.row]];
//    cell.userName.text = [self.nameList objectAtIndex: indexPath.row];
//    cell.messageContent.text = [self.messageList objectAtIndex: indexPath.row];
//    cell.messageTime.text = [self.timeList objectAtIndex: indexPath.row];
    
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"showDetail" sender: self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
