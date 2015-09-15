//
//  TLDetailTableViewCell0.m
//  TripalocalBeta
//
//  Created by Fangzhou He on 28/06/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "TLDetailTableViewCell0.h"

@implementation TLDetailTableViewCell0

- (void)awakeFromNib {
    // Initialization code
    _hostImage.layer.cornerRadius = _hostImage.frame.size.height / 2;
    _hostImage.layer.masksToBounds = YES;
    _hostImage.layer.borderWidth = 0;
    _hostImage.layer.masksToBounds = YES;
    
    
    self.hostImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.hostImage.layer.borderWidth = 5.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
