//
//  UnloginViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 1/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "UnloginViewController.h"
#import "LoginViewController.h"

@implementation UnloginViewController

- (void)viewDidLoad
{
    self.hostImage.image = [UIImage imageNamed: @"default_profile_image.png"];
    self.hostImage.layer.cornerRadius = self.hostImage.frame.size.height / 2;
    self.hostImage.layer.masksToBounds = YES;
    self.hostImage.layer.borderWidth = 0;
    self.hostImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.hostImage.layer.borderWidth = 3.0f;
    
    [self.loginButton.layer setMasksToBounds:YES];
    [self.loginButton.layer setCornerRadius:5.0f];
}

- (void)hideUnloggedinView
{
    [self.parentVC closePartialMenu];
    [self.parentVC presentSmsVerifiIfNotLoggedIn];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LoginViewController *loginVC = (LoginViewController *)segue.destinationViewController;
    loginVC.unloggedinVC = self;
}

@end
