//
//  UnloginViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 1/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "UnloginViewController.h"

@implementation UnloginViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults stringForKey:@"user_token"];
    
    if (token) {
        
        UIViewController *profileViewController = (UIViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"loggedin_controller"];
        
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
    }
}

@end
