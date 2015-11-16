//
//  ChatOverviewTableViewCell.h
//  
//
//  Created by 嵩薛 on 4/08/2015.
//
//

#import <UIKit/UIKit.h>

@interface ChatOverviewTableViewCell : UITableViewCell{
    UIImageView *userImage;
    UILabel *userName;
    UILabel *messageContent;
    UILabel *messageTime;
}
@property (nonatomic,retain) IBOutlet UIImageView *userImage;
@property (nonatomic,retain) IBOutlet UILabel *userName;
@property (nonatomic,retain) IBOutlet UILabel *messageContent;
@property (nonatomic,retain) IBOutlet UILabel *messageTime;

@end
