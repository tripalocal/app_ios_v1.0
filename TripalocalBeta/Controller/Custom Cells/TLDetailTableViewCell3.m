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
    // Initialization code
    _reviewerImage.layer.cornerRadius = _reviewerImage.frame.size.height /2;
    _reviewerImage.layer.masksToBounds = YES;
    _reviewerImage.layer.borderWidth = 0;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
