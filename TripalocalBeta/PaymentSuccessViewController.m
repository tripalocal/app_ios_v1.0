//
//  PaymentSuccessViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 8/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "PaymentSuccessViewController.h"
#import <SecureNSUserDefaults/NSUserDefaults+SecureAdditions.h>
#import "Mixpanel.h"
#import "Constant.h"

@interface PaymentSuccessViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *hostImage;
@property (weak, nonatomic) IBOutlet UILabel *sentToNameLabel;
@end

@implementation PaymentSuccessViewController

- (void)mpTrackCompletedPayment:(NSUserDefaults *)userDefaults {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    NSString *token = [userDefaults secretStringForKey:@"user_token"];
    
    if (token) {
        NSString * userEmail = [userDefaults stringForKey:@"user_email"];
        [mixpanel identify:userEmail];
    }
    
    [mixpanel track:mpTrackCompletedPayment properties:@{@"language":language}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hostImage.layer.cornerRadius = self.hostImage.frame.size.height / 2;
    self.hostImage.layer.masksToBounds = YES;
    self.hostImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.hostImage.layer.borderWidth = 3.0f;

    [self.viewItInMyTripButton.layer setMasksToBounds:YES];
    [self.viewItInMyTripButton.layer setCornerRadius:5.0f];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    UIImage* image = [UIImage imageWithData:[userDefaults objectForKey:@"user_image"]];

    if ([self.expType isEqualToString:@"PRIVATE"] || [self.expType isEqualToString:@"NONPRIVATE"]) {
        if (image) {
            self.hostImage.image = image;
        } else {
            self.hostImage.image = [UIImage imageNamed: @"default_profile_image.png"];
        }
        self.sentToNameLabel.text = [self.sentToNameLabel.text stringByAppendingString:_hostName];
    } else {
        self.hostImage.image = [UIImage imageNamed: @"AppIcon.png"];
        self.sentToNameLabel.text = NSLocalizedString(@"payment_success", nil);
    }

    
    [self mpTrackCompletedPayment:userDefaults];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
