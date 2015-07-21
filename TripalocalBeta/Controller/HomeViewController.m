//
//  HomeViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 3/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "HomeViewController.h"
#import "SmsVerificationViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UITabBar *tabBar = self.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
//    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
//    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:2];
    
//    tabBar.tintColor=[UIColor whiteColor];
//    tabBar.translucent = NO;
    
    tabBarItem1.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    tabBarItem1.selectedImage = [[UIImage imageNamed:@"home_s.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem1.image = [[UIImage imageNamed:@"home.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem1.title = nil;
    
//    tabBarItem2.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
//    tabBarItem2.selectedImage = [[UIImage imageNamed:@"search_s.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
//    tabBarItem2.image = [[UIImage imageNamed:@"search.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
//    tabBarItem2.title =nil;
//
//    tabBarItem3.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
//    tabBarItem3.selectedImage = [[UIImage imageNamed:@"heart.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
//    tabBarItem3.image = [[UIImage imageNamed:@"heart.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
//    tabBarItem3.title = nil;
    
    tabBarItem3.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    tabBarItem3.selectedImage = [[UIImage imageNamed:@"mytrip_s.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem3.image = [[UIImage imageNamed:@"mytrip.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem3.title = nil;
    
    tabBarItem4.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    tabBarItem4.selectedImage = [[UIImage imageNamed:@"myprofile_s.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem4.image = [[UIImage imageNamed:@"myprofile.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem4.title = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentSmsVerifiIfNotLoggedIn)
     
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentSmsVerifiIfNotLoggedIn)
     
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self presentSmsVerifiIfNotLoggedIn];
}

- (void)presentSmsVerifiIfNotLoggedIn {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults stringForKey:@"user_token"];
    
#ifdef CN_VERSION
        if (token) {
            
        } else {
            SmsVerificationViewController *smsVerificationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"smsVerificationViewController"];
            [self presentViewController:smsVerificationVC animated:YES completion:nil];
        }
#endif
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
