//
//  ChatOverviewController.h
//  TripalocalBeta
//
//  Created by Song Xue on 4/08/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatOverviewTableViewCell.h"

@interface ChatOverviewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *noDataLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *imgList;
@property (nonatomic, retain) NSMutableArray *nameList;
@property (nonatomic, retain) NSMutableArray *messageList;
@property (nonatomic, retain) NSMutableArray *timeList;
@end