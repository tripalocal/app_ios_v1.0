//
//  UnloginViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 1/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "UnloginViewController.h"
#import "SmsVerificationViewController.h"

@implementation UnloginViewController

- (void)viewDidLoad {
    self.hostImage.image = [UIImage imageNamed: @"default_profile_image.png"];
    self.hostImage.layer.cornerRadius = self.hostImage.frame.size.height / 2;
    self.hostImage.layer.masksToBounds = YES;
    self.hostImage.layer.borderWidth = 0;
    self.hostImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.hostImage.layer.borderWidth = 3.0f;
    
    [self.loginButton.layer setMasksToBounds:YES];
    [self.loginButton.layer setCornerRadius:5.0f];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults stringForKey:@"user_token"];
    if (token) {
        UIViewController *profileViewController = (UIViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"menu_controller"];
        
        NSMutableArray *listOfViewControllers = [NSMutableArray arrayWithArray:self.tabBarController.viewControllers];
        [listOfViewControllers removeLastObject];
        [listOfViewControllers addObject:profileViewController];
        
        UITabBarItem *myprofileBarItem = [[UITabBarItem alloc] init];
        myprofileBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
        myprofileBarItem.selectedImage = [[UIImage imageNamed:@"myprofile_s.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        myprofileBarItem.image = [[UIImage imageNamed:@"myprofile.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
        myprofileBarItem.title = nil;
        profileViewController.tabBarItem = myprofileBarItem;
        
        [self.tabBarController setViewControllers:listOfViewControllers];
    } else {
        if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-zhVersion"]) {
            
            SmsVerificationViewController *smsVerificationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"smsVerificationViewController"];
            [self presentViewController:smsVerificationVC animated:YES completion:nil];
            
        } else {
            [self.navigationController setNavigationBarHidden:YES animated:animated];
        }
    }
}

@end
