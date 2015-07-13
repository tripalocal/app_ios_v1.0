//
//  TLSearchTableViewCell.m
//  TripalocalBeta
//
//  Created by Charles He on 17/05/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "TLSearchTableViewCell.h"

@implementation TLSearchTableViewCell

- (void)awakeFromNib {
    // Initialization code

    self.hostImage.layer.cornerRadius = self.hostImage.frame.size.height / 2;
    self.hostImage.layer.masksToBounds = YES;
    self.hostImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.hostImage.layer.borderWidth = 3.0f;
    self.PriceBackgroundView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.65f];
    
    UITapGestureRecognizer *wishStatusClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveToWishList)];
    wishStatusClick.numberOfTapsRequired = 1;
    [self.wishStatus setUserInteractionEnabled:YES];
    [self.wishStatus addGestureRecognizer:wishStatusClick];
    
    UITapGestureRecognizer *smallWishClick = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(saveToWishList)];
    smallWishClick.numberOfTapsRequired = 1;
    [self.smallWishImage setUserInteractionEnabled:YES];
    [self.smallWishImage addGestureRecognizer:smallWishClick];
}

- (IBAction)clickSaveToWishList:(id)sender {
    UIButton *button = (UIButton *)sender;
    [self.delegate saveToWishListClicked:button.tag];
}

- (void)saveToWishList {
    [self.delegate saveToWishListClicked:self.wishListButton.tag];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
