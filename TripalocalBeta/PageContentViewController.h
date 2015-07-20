//
//  PageContentViewController.h
//  TripalocalBeta
//
//  Created by Ye He on 18/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface PageContentViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *tutorialImage;
@property NSUInteger pageIndex;
@property NSString *imageFile;
@property (strong, nonatomic) IBOutlet UIButton *startExploringButton;
@property (strong, nonatomic) RootViewController *rootVC;
@end
