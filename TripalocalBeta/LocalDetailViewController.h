//
//  LocalDetailViewController.h
//  TripalocalBeta
//
//  Created by Ye He on 15/10/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (strong, nonatomic) NSMutableArray *cellHeights;
@property NSString *experience_id_string;
@property UIImage *coverImage;
@property NSString *expPrice;
@property NSString *expType;

@end
