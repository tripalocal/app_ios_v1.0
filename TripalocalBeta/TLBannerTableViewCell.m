//
//  TLBannerTableViewCell.m
//  TripalocalBeta
//
//  Created by Ye He on 27/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "TLBannerTableViewCell.h"
#import "Constant.h"

@implementation TLBannerTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)wechatClicked:(id)sender {
    NSURL *wechatURL = [NSURL URLWithString:@"weixin://"];
    
    if ([[UIApplication sharedApplication] canOpenURL:wechatURL]) {
        [[UIApplication sharedApplication] openURL:wechatURL];
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil) message:NSLocalizedString(@"alert_wechat", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_button", nil) otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)emailClicked:(id)sender {
    NSURL *emailURL = [NSURL URLWithString:[NSString  stringWithFormat:@"mailto:%@", enqueryEmail]];
    
    if ([[UIApplication sharedApplication] canOpenURL:emailURL]) {
        [[UIApplication sharedApplication] openURL:emailURL];
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil) message:NSLocalizedString(@"alert_email", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_button", nil) otherButtonTitles:nil];
        [alert show];
    }
}


@end
