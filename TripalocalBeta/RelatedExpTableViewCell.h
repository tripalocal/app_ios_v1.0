//
//  RelatedExpTableViewCell.h
//  TripalocalBeta
//
//  Created by Ye He on 26/10/2015.
//  Copyright © 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RelatedExpTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *expImageView;
@property (weak, nonatomic) IBOutlet UILabel *expTitle;
@property (weak, nonatomic) IBOutlet UILabel *dollarsign;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *languageLabel;

@end
