//
//  TLDetailTableViewCell3.h
//  TripalocalBeta
//
//  Created by Fangzhou He on 28/06/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDStarRating.h"

@interface TLDetailTableViewCell3 : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (weak, nonatomic) IBOutlet UIImageView *reviewerImage;
@property (weak, nonatomic) IBOutlet UILabel *reviewerName;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (strong, nonatomic) IBOutlet EDStarRating *reviewStars;

@end
