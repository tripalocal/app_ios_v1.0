//
//  ChatDetailToTableViewCell.m
//  
//
//  Created by 嵩薛 on 4/08/2015.
//
//

#import "ChatDetailToTableViewCell.h"

@implementation ChatDetailToTableViewCell
@synthesize userImage, messageTime, messageContent, msgView;

- (void)awakeFromNib {
    // Initialization code
    NSLog(@"From Cell loading...");
    self.userImage.layer.cornerRadius = self.userImage.frame.size.height / 2;
    self.userImage.layer.masksToBounds = YES;
    self.userImage.layer.borderColor = [UIColor colorWithRed:204.0f/255.0f green:204.0f/255.0f blue:204.0f/255.0f alpha:1.0].CGColor;
    self.userImage.layer.borderWidth = 1.0f;
    self.messageContent.textColor = [UIColor colorWithRed:102.0f/255.0f green:102.0f/255.0f blue:102.0f/255.0f alpha:1.0];
    self.messageTime.textColor = [UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0];
    self.msgView.layer.cornerRadius = 5.0f;
    self.msgView.layer.masksToBounds = YES;
    self.msgView.layer.borderWidth = 0.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (CGFloat)getCellHeight:(NSIndexPath *)indexPath{
    CGFloat labelHeight = self.messageContent.frame.size.height;
    return labelHeight;
}

@end
