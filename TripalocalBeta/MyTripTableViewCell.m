//
//  MyTripTableViewCell.m
//  TripalocalBeta
//
//  Created by Ye He on 6/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "MyTripTableViewCell.h"

@interface MyTripTableViewCell()

@end

@implementation MyTripTableViewCell

- (void)awakeFromNib {
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 15.0f);
    
    self.callButton.layer.cornerRadius = 5;
    self.callButton.layer.masksToBounds = YES;
    self.callButton.layer.borderWidth = 1.0f;
    self.callButton.layer.borderColor = [UIColor colorWithRed:0.80f green:0.80f blue:0.80f alpha:1.0f].CGColor;
    
    self.messageButton.layer.cornerRadius = 5;
    self.messageButton.layer.masksToBounds = YES;
    
//    self.statusLabel setConten
    
    if (!self.hostImage) {
        self.hostImage.image = [UIImage imageNamed: @"default_profile_image.png"];
    }
    
    self.hostImage.layer.cornerRadius = self.hostImage.frame.size.height / 2;
    self.hostImage.layer.masksToBounds = YES;
    self.hostImage.layer.borderWidth = 0;

}

//- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
//{
//    [super setHighlighted:highlighted animated:animated];
//    [self applyLabelDropShadow:!highlighted];
//}
//
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
//    [self applyLabelDropShadow:!selected];
}
//
//- (void)applyLabelDropShadow:(BOOL)applyDropShadow
//{
//    self.textLabel.shadowColor = applyDropShadow ? [UIColor whiteColor] : nil;
//}

- (IBAction)callHost:(id)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.callButton.tag inSection:0];

    MyTripTableViewCell *cell = (MyTripTableViewCell *)[self.parentView cellForRowAtIndexPath:indexPath];
    
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel://%@",  cell.telephoneLabel.text]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else {
        UIAlertView * calert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [calert show];
    }
}

- (IBAction)messageHost:(id)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.callButton.tag inSection:0];
    
    MyTripTableViewCell *cell = (MyTripTableViewCell *)[self.parentView cellForRowAtIndexPath:indexPath];
    
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"sms://%@",  cell.telephoneLabel.text]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else {
        UIAlertView * calert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Message facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [calert show];
    }
}

@end
