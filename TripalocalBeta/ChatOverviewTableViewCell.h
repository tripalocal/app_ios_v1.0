//
//  ChatOverviewTableViewCell.h
//  
//
//  Created by 嵩薛 on 4/08/2015.
//
//

#import <UIKit/UIKit.h>

@interface ChatOverviewTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *userImage;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *messageContent;
@property (strong, nonatomic) IBOutlet UILabel *messageTime;
@end
