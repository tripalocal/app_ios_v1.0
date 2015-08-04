//
//  ChatDetailFromTableViewCell.h
//  
//
//  Created by 嵩薛 on 4/08/2015.
//
//

#import <UIKit/UIKit.h>

@interface ChatDetailFromTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *otherUserImage;
@property (strong, nonatomic) IBOutlet UILabel *messageContent;
@property (strong, nonatomic) IBOutlet UILabel *messageTime;
@end
