//
//  LoginViewController.h
//  TripalocalBeta
//
//  Created by Ye He on 30/06/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RequestController.h"
#import "UnloginViewController.h"
#import "AppDelegate.h"

@interface LoginViewController : RequestController <UITextFieldDelegate>
@property (nonatomic, strong) UnloginViewController *unloggedinVC;
@end
