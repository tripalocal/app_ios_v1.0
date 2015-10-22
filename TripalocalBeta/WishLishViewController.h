//
//  WishLishViewController.h
//  TripalocalBeta
//
//  Created by Ye He on 9/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLSearchViewController.h"
#import "NeedToLoginView.h"

@interface WishLishViewController : UIViewController <NeedToLoginViewDelegate, UITableViewDelegate, UITableViewDataSource, SearchTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *expList;

@property (retain, nonatomic) IBOutlet NeedToLoginView *needToLoginView;
@property (strong, nonatomic) IBOutlet UILabel *noDataLabel;
@end
