//
//  ChatOverviewTableViewCell.m
//  
//
//  Created by 嵩薛 on 4/08/2015.
//
//

#import "ChatOverviewTableViewCell.h"

@implementation ChatOverviewTableViewCell
@synthesize userImage = _userImage;
@synthesize userName = _userName;
@synthesize messageContent = _messageContent;
@synthesize messageTime = _messageTime;

- (void)awakeFromNib {
    // Initialization code
    
    //set the apprearence of userImage
//    self.userImage.layer.cornerRadius = self.userImage.frame.size.height / 2;
//    self.userImage.layer.masksToBounds = YES;
//    self.userImage.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.userImage.layer.borderWidth = 3.0f;


}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
