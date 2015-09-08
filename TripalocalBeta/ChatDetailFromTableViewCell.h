//
//  ChatDetailFromTableViewCell.h
//  
//
//  Created by 嵩薛 on 4/08/2015.
//
//

#import <UIKit/UIKit.h>

@interface ChatDetailFromTableViewCell : UITableViewCell{
    UIImageView *otherUserImage;
    UILabel *messageContent;
    UILabel *messageTime;
}
@property (nonatomic, retain) IBOutlet UIImageView *otherUserImage;
@property (nonatomic, retain) IBOutlet UILabel *messageContent;
@property (weak, nonatomic) IBOutlet UIView *msgView;
@property (nonatomic, retain) IBOutlet UILabel *messageTime;
@end
