//
//  RootViewController.h
//  TripalocalBeta
//
//  Created by Ye He on 18/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController <UIPageViewControllerDataSource>
@property (strong, nonatomic) NSArray *pageImages;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) UIPageViewController *pageViewController;
- (void)startExploring;
@end
