//
//  MyTripTableViewCell.h
//  TripalocalBeta
//
//  Created by Ye He on 6/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyTripTableViewController.h"

@protocol MyTripViewCellDelegate <NSObject>
-(void) sendClicked;
@end

@interface MyTripTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *backgroudImage;
@property (strong, nonatomic) IBOutlet UIImageView *hostImage;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) IBOutlet UIButton *statusButton;
@property (strong, nonatomic) IBOutlet UITextView *instructionText;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *guestNumberLabel;

@property (strong, nonatomic) IBOutlet UILabel *experienceTitle;
@property (strong, nonatomic) IBOutlet UILabel *hostNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *telephoneLabel;
@property (strong, nonatomic) IBOutlet UIButton *callButton;
@property (strong, nonatomic) UITableView* parentView;
@property (strong, nonatomic) IBOutlet UIButton *messageButton;
@property (nonatomic, weak) id <MyTripViewCellDelegate> delegate;
@end


