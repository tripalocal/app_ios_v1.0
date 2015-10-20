//
//  MultidayTableViewCell.h
//  TripalocalBeta
//
//  Created by Ye He on 14/10/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultidayTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *multidayImage;
@property (weak, nonatomic) IBOutlet UILabel *oneNightMelbournePriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *allNightMelbournePriceLabel;

@property (weak, nonatomic) IBOutlet UILabel *oneNightSydneyPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *allNightSydneyPriceLabel;

@property (weak, nonatomic) IBOutlet UIButton *check1NightMelbourneButton;
@property (weak, nonatomic) IBOutlet UIButton *checkAllNightMelbourneButton;
@property (weak, nonatomic) IBOutlet UIButton *check1NightSydneyButton;
@property (weak, nonatomic) IBOutlet UIButton *checkAllNightSydneyButton;
@end
