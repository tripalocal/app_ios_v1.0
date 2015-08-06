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
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil) style:UIBarButtonItemStylePlain target:self action:@selector(dismissChatOverview:)];
    closeButton.tintColor = [Utility themeColor];
    self.navigationItem.leftBarButtonItem = closeButton;
    
    //loading the message data in here
    //	:load three arraies
}

- (IBAction)dismissChatOverview:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"ChatOverviewCell";
    
    ChatOverviewTableViewCell *cell = (ChatOverviewTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ChatOverviewCell"];
    if(!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"ChatOverviewViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    //load data
    cell.userImage.image = [UIImage imageNamed: [imgList objectAtIndex: indexPath.row]];
    cell.userName.text = [nameList objectAtIndex: indexPath.row];
    cell.messageContent.text = [messageList objectAtIndex: indexPath.row];
    cell.messageTime.text = [timeList objectAtIndex: indexPath.row];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
