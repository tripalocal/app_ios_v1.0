//
//  HomeViewController.h
//  TripalocalBeta
//
//  Created by Ye He on 3/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UITabBarController
@property (nonatomic, strong) UIViewController *menuVC;
- (void)openPartialMenu;
- (void)closePartialMenu;
- (void)presentSmsVerifiIfNotLoggedIn;
@end
