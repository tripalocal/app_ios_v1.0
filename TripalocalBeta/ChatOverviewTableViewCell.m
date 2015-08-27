//
//  ChatOverviewTableViewCell.m
//  
//
//  Created by 嵩薛 on 4/08/2015.
//
//

#import "ChatOverviewTableViewCell.h"

@implementation ChatOverviewTableViewCell
@synthesize userImage;
@synthesize userName;
@synthesize messageContent;
@synthesize messageTime;

- (void)awakeFromNib {
    // Initialization code
    
    //set the apprearence of userImage
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0, 0, self.backgroundView.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor grayColor].CGColor;
    
    self.userImage.layer.cornerRadius = self.userImage.frame.size.height / 2;
    self.userImage.layer.masksToBounds = YES;
    self.userImage.layer.borderColor = [UIColor colorWithRed:204.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0].CGColor;
    self.userImage.layer.borderWidth = 1.0f;
    self.userName.textColor = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0];
    self.messageContent.textColor = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0];
    self.messageTime.textColor = [UIColor colorWithRed:204.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0];

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
