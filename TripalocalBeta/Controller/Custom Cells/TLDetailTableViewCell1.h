//
//  TLDetailTableViewCell1.h
//  TripalocalBeta
//
//  Created by Fangzhou He on 28/06/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TLDetailTableViewCell1 : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *expTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *expDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *readMoreButton;
@property (strong, nonatomic) UITableView* parentView;
@end
