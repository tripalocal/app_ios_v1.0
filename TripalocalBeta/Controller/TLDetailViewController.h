//
//  TLDetailViewController.h
//  TripalocalBeta
//
//  Created by Charles He on 27/06/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (strong, nonatomic) NSMutableArray *cellHeights;
@property NSString *experience_id_string;
@property UIImage *coverImage;
@property UIImage *hostImage;
@property BOOL isExpReadMoreOpen;
@property BOOL isHostReadMoreOpen;

@end
