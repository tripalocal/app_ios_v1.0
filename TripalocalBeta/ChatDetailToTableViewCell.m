//
//  ChatDetailToTableViewCell.m
//  
//
//  Created by 嵩薛 on 4/08/2015.
//
//

#import "ChatDetailToTableViewCell.h"

@implementation ChatDetailToTableViewCell
@synthesize userImage, messageTime, messageContent;

- (void)awakeFromNib {
    // Initialization code
    NSLog(@"From Cell loading...");
    self.userImage.layer.cornerRadius = self.userImage.frame.size.height / 2;
    self.userImage.layer.masksToBounds = YES;
    self.userImage.layer.borderColor = [UIColor colorWithRed:204.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0].CGColor;
    self.userImage.layer.borderWidth = 1.0f;
    self.messageContent.textColor = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0];
    self.messageTime.textColor = [UIColor colorWithRed:204.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
