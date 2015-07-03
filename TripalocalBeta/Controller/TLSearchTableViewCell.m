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
    // Initialization code
    _hostImage.layer.cornerRadius = _hostImage.frame.size.height / 2;
    _hostImage.layer.masksToBounds = YES;
    _hostImage.layer.borderWidth = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)saveButton:(id)sender {
}
@end
