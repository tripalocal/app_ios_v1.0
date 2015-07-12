//
//  TLSearchTableViewCell.h
//  TripalocalBeta
//
//  Created by Charles He on 17/05/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SearchTableViewCellDelegate <NSObject>

- (void)saveToWishListClicked:(NSInteger)buttonTag;

@end

@interface TLSearchTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *experienceImage;
@property (weak, nonatomic) IBOutlet UIImageView *hostImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *languageLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIButton *wishListButton;
@property (strong, nonatomic) IBOutlet UIImageView *smallWishImage;
@property (strong, nonatomic) IBOutlet UILabel *wishStatus;
@property (nonatomic, weak) id <SearchTableViewCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *PriceBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end
