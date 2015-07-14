//
//  TLDetailTableViewCell3.m
//  TripalocalBeta
//
//  Created by Fangzhou He on 28/06/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "TLDetailTableViewCell3.h"

@implementation TLDetailTableViewCell3

- (void)awakeFromNib {
    self.viewAllButton.layer.cornerRadius = 5;
    self.viewAllButton.layer.masksToBounds = YES;
    self.viewAllButton.layer.borderColor = [UIColor colorWithRed:0.80f green:0.80f blue:0.80f alpha:1.0f].CGColor;
    self.viewAllButton.layer.borderWidth = 1.0f;
    
    _reviewerImage.layer.cornerRadius = _reviewerImage.frame.size.height /2;
    _reviewerImage.layer.masksToBounds = YES;
    _reviewerImage.layer.borderWidth = 0;
    
    self.reviewerImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.reviewerImage.layer.borderWidth = 3.0f;
    
    
    CGSize newSize = CGSizeMake(15, 15);
    self.reviewStars.starImage = [self imageWithImage:[UIImage imageNamed:@"star_w.png"] scaledToSize:newSize];
    self.reviewStars.starHighlightedImage = [self imageWithImage:[UIImage imageNamed:@"star_y.png"] scaledToSize:newSize];
    self.reviewStars.maxRating = 5.0;
    self.reviewStars.horizontalMargin = 12;
    [self.reviewStars sizeToFit];
    self.reviewStars.editable = NO;
    self.reviewStars.displayMode = EDStarRatingDisplayFull;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
