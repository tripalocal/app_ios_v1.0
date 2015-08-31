//
//  ChatOverviewController.h
//  TripalocalBeta
//
//  Created by Song Xue on 4/08/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatOverviewTableViewCell.h"
#import "AppDelegate.h"
#import "UnloginViewController.h"
#import "ChatDetailViewController.h"
@interface ChatOverviewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    UITableView *tableview;
    NSMutableArray *imgList;
    NSMutableArray *nameList;
    NSMutableArray *messageList;
	NSMutableArray *timeList;
    NSMutableArray *sender_id_list;

}

@property (retain, nonatomic) IBOutlet UITableView *tableView;

@end