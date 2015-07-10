//
//  MyTripTableViewController.h
//  TripalocalBeta
//
//  Created by Ye He on 7/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyTripTableViewController : UITableViewController
@property (nonatomic, strong) UIViewController *containerController;
- (NSDate *)parseDateTimeString:(NSString *) datetimeString;
@end
