//
//  UnloginViewController.h
//  TripalocalBeta
//
//  Created by Ye He on 1/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"

@interface UnloginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *hostImage;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) HomeViewController *parentVC;
- (void)hideUnloggedinView;
@end
