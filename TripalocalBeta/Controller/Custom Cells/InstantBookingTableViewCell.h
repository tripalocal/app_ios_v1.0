//
//  InstantBookingTableViewCell.h
//  TripalocalBeta
//
//  Created by Fangzhou He on 12/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InstantBookingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *instantDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *instantTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *instantView;
@property (weak, nonatomic) IBOutlet UIImageView *tempImage;
@property (weak, nonatomic) IBOutlet UIView *tempView;

@end
