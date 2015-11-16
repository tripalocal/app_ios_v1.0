//
//  MyTripTableViewCell.m
//  TripalocalBeta
//
//  Created by Ye He on 6/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "MyTripTableViewCell.h"
#import "ChatDetailViewController.h"
#import "MyTripTableViewController.h"
#import <SecureNSUserDefaults/NSUserDefaults+SecureAdditions.h>

@interface MyTripTableViewCell()

@end

@implementation MyTripTableViewCell

- (void)awakeFromNib {
    self.statusButton.layer.cornerRadius = 5;
    self.statusButton.layer.masksToBounds = YES;
    
    self.callButton.layer.cornerRadius = 5;
    self.callButton.layer.masksToBounds = YES;
    self.callButton.layer.borderWidth = 1.0f;
    self.callButton.layer.borderColor = [UIColor colorWithRed:0.80f green:0.80f blue:0.80f alpha:1.0f].CGColor;
    
    self.messageButton.layer.cornerRadius = 5;
    self.messageButton.layer.masksToBounds = YES;
    self.messageButton.titleLabel.text = NSLocalizedString(@"send_message", nil);
    
    if (!self.hostImage) {
        self.hostImage.image = [UIImage imageNamed: @"default_profile_image.png"];
    }
    
    self.hostImage.layer.cornerRadius = self.hostImage.frame.size.height / 2;
    self.hostImage.layer.masksToBounds = YES;
    self.hostImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.hostImage.layer.borderWidth = 3.0f;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


- (IBAction)callHost:(id)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.callButton.tag inSection:0];
    
    MyTripTableViewCell *cell = (MyTripTableViewCell *)[self.parentView cellForRowAtIndexPath:indexPath];
    
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel://%@",  cell.telephoneLabel.text]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil) message:NSLocalizedString(@"alert_call", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_button", nil) otherButtonTitles:nil];
        [alert show];
    }
}


- (IBAction)send_message:(id)sender {
    //get the host id
    [self.delegate sendClicked];
    NSLog(@"Send message button clicked.");
}
//- (IBAction)messageHost:(id)sender {
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.callButton.tag inSection:0];
//    
//    MyTripTableViewCell *cell = (MyTripTableViewCell *)[self.parentView cellForRowAtIndexPath:indexPath];
//    
//    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"sms://%@",  cell.telephoneLabel.text]];
//    
//    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
//        [[UIApplication sharedApplication] openURL:phoneUrl];
//    } else {
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil) message:NSLocalizedString(@"alert_sms", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_button", nil) otherButtonTitles:nil];
//        [alert show];
//    }
//}

@end
