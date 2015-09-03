//
//  MyTripTableViewController.h
//  TripalocalBeta
//
//  Created by Ye He on 7/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyTripTableViewCell.h"

@interface MyTripTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UIViewController *containerController;

- (NSDate *)parseDateTimeString:(NSString *) datetimeString;
@property (retain, nonatomic) IBOutlet UIView *nomatchesView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSString *host_id;

@end



