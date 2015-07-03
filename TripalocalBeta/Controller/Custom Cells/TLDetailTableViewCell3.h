//
//  TLDetailTableViewCell3.h
//  TripalocalBeta
//
//  Created by Fangzhou He on 28/06/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLDetailTableViewCell3 : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *reviewerImage;
@property (weak, nonatomic) IBOutlet UILabel *reviewerFirstName;
@property (weak, nonatomic) IBOutlet UILabel *reviewerLastName;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@end
