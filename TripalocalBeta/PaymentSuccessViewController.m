//
//  PaymentSuccessViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 8/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "PaymentSuccessViewController.h"

@interface PaymentSuccessViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *hostImage;
@property (weak, nonatomic) IBOutlet UILabel *sentToNameLabel;
@end

@implementation PaymentSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hostImage.layer.cornerRadius = self.hostImage.frame.size.height / 2;
    self.hostImage.layer.masksToBounds = YES;
    self.hostImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.hostImage.layer.borderWidth = 3.0f;

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    UIImage* image = [UIImage imageWithData:[userDefaults objectForKey:@"user_image"]];

    if (image) {
        self.hostImage.image = image;
    } else {
        self.hostImage.image = [UIImage imageNamed: @"default_profile_image.png"];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
