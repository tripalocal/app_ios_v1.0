//
//  TLSearchViewController.h
//  TripalocalBeta
//
//  Created by Charles He on 17/05/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLSearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSString *cityName;
@property (nonatomic, retain) NSMutableArray *expList;
@end
