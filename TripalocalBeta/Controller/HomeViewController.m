//
//  HomeViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 3/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "HomeViewController.h"
#import "MenuViewController.h"
#import "UnloginViewController.h"
#import "SmsVerificationViewController.h"
#import <SecureNSUserDefaults/NSUserDefaults+SecureAdditions.h>

@interface HomeViewController ()
@property (nonatomic, strong) UnloginViewController *unloggedinVC;
@property (nonatomic, strong) MenuViewController *loggedinVC;
@property (nonatomic, strong) UITapGestureRecognizer *tap;
@property (nonatomic, strong) UIView *coverView;
@end

@implementation HomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openPartialMenu) name:@"openPartialMenu" object:nil];
    self.tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(closePartialMenu)];
    
    self.loggedinVC = (MenuViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"menu_controller"];
    self.unloggedinVC = (UnloginViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"unloggedin_controller"];
    self.loggedinVC.parentVC = self;
    self.unloggedinVC.parentVC = self;

    self.coverView = [[UIView alloc]initWithFrame:self.view.frame];
    self.coverView.backgroundColor = [UIColor blackColor];
    self.coverView.alpha = 0;
    
    self.delegate = (id)self;
    UITabBar *tabBar = self.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];

    
    tabBarItem1.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
#ifdef CN_VERSION
    tabBarItem1.selectedImage = [[UIImage imageNamed:@"ben.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem1.image = [[UIImage imageNamed:@"ben.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
#else
    tabBarItem1.selectedImage = [[UIImage imageNamed:@"home.png"]  imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem1.image = [[UIImage imageNamed:@"home.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
#endif
    tabBarItem1.title = nil;
    
    tabBarItem2.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    tabBarItem2.selectedImage = [[UIImage imageNamed:@"mytrip_s.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem2.image = [[UIImage imageNamed:@"mytrip.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem2.title = nil;
    
    tabBarItem3.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    tabBarItem3.selectedImage = [[UIImage imageNamed:@"myprofile_s.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem3.image = [[UIImage imageNamed:@"myprofile.png"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal ];
    tabBarItem3.title = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentSmsVerifiIfNotLoggedIn)
     
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentSmsVerifiIfNotLoggedIn)
     
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];

}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    
    if (viewController == self.viewControllers[2]) {
        [self openPartialMenu];
        return NO;
    } else {
        return YES;
    }
}

- (void)openPartialMenu
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults secretStringForKey:@"user_token"];
    if (token) {
        self.menuVC = self.loggedinVC;
    } else {
        self.menuVC = self.unloggedinVC;
    }
    
    [self.coverView addGestureRecognizer:self.tap];
    
    [self addChildViewController:self.menuVC];
    CGRect mainFrame = self.view.frame;
    self.menuVC.view.frame = CGRectMake(mainFrame.size.width, 0, mainFrame.size.width / 6 * 5, mainFrame.size.height);
    
    [self.view addSubview:self.coverView];
    [self.coverView bringSubviewToFront:self.view];
    
    [self.view insertSubview:self.menuVC.view aboveSubview:self.coverView];
    [UIView animateWithDuration:0.3 animations:^{
        self.coverView.alpha = 0.4;
        self.menuVC.view.frame = CGRectMake(mainFrame.size.width / 6, 0, mainFrame.size.width / 6 * 5, mainFrame.size.height);;
    } completion:^(BOOL finished) {
        [self.menuVC didMoveToParentViewController:self];
    }];
}

- (void)closePartialMenu
{
    [self.coverView removeGestureRecognizer:self.tap];
    CGRect mainFrame = self.view.frame;
    [UIView animateWithDuration:0.3 animations:^{
        self.coverView.alpha = 0;
        self.menuVC.view.frame = CGRectMake(mainFrame.size.width, 0, mainFrame.size.width / 6 * 5, mainFrame.size.height);
    } completion:^(BOOL finished) {
        [self.coverView removeFromSuperview];
        [self.menuVC.view removeFromSuperview];
        [self.menuVC removeFromParentViewController];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self presentSmsVerifiIfNotLoggedIn];
}

- (void)presentSmsVerifiIfNotLoggedIn
{
#ifdef CN_VERSION
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults secretStringForKey:@"user_token"];
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
