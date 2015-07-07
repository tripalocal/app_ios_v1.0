//
//  MyTripTableViewCell.m
//  TripalocalBeta
//
//  Created by Ye He on 6/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "MyTripTableViewCell.h"

@interface MyTripTableViewCell()

@end

@implementation MyTripTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.callButton.layer.cornerRadius = 2;
    self.callButton.layer.masksToBounds = YES;
    self.callButton.layer.borderWidth = 1.0f;
    self.callButton.layer.borderColor = [UIColor grayColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)callHost:(id)sender {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.callButton.tag inSection:0];

    MyTripTableViewCell *cell = (MyTripTableViewCell *)[self.parentView cellForRowAtIndexPath:indexPath];
    
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"tel://%@",  cell.telephoneLabel.text]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else {
        UIAlertView * calert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
        [calert show];
    }
}

@end
