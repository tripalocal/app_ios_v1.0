//
//  TLHomeViewController.h
//  TripalocalBeta
//
//  Created by Charles He on 12/05/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLHomeViewController : UIViewController<UITableViewDelegate,UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UISearchController *searchController;
- (IBAction)myButton:(id)sender;
@end
