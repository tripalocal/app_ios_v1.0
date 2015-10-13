//
//  TLSearchViewController.h
//  TripalocalBeta
//
//  Created by Charles He on 17/05/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLSearchTableViewCell.h"

@interface TLSearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SearchTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *filterView;
@property NSString *cityName;
@property NSString *expSearchType;
@property (nonatomic, retain) NSMutableArray *expList;

@property (weak, nonatomic) IBOutlet UIImageView *travelWithLocalsImageView;
@property (weak, nonatomic) IBOutlet UILabel *travelWithLocalsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *localExpImageView;
@property (weak, nonatomic) IBOutlet UILabel *localExpLabel;
@property (weak, nonatomic) IBOutlet UIImageView *itinerariesImageView;
@property (weak, nonatomic) IBOutlet UILabel *itenarariesLabel;

@end
