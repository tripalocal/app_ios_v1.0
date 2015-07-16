//
//  MySearchDisplayController.h
//  TripalocalBeta
//
//  Created by Ye He on 16/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MySearchDisplayController : UITableViewController <UISearchResultsUpdating, UISearchBarDelegate>
@property (strong, nonatomic) UISearchController *searchController;
@end
