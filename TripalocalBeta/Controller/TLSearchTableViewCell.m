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
//    
//    self.descriptonText.contentInset = UIEdgeInsetsMake(-4,-4,-4,-4);
}
- (IBAction)clickSaveToWishList:(id)sender {
    UIButton *button = (UIButton *)sender;
    [self.delegate saveToWishListClicked:button.tag];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
