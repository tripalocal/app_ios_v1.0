//
//  TLDetailTableViewCell2.m
//  TripalocalBeta
//
//  Created by Fangzhou He on 28/06/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "TLDetailTableViewCell2.h"
#import "TLDetailViewController.h"

@implementation TLDetailTableViewCell2

- (void)awakeFromNib {
    // Initialization code
    _hostImage.layer.cornerRadius = _hostImage.frame.size.height /2;
    _hostImage.layer.masksToBounds = YES;
    _hostImage.layer.borderWidth = 0;
    
    self.hostImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.hostImage.layer.borderWidth = 3.0f;
    
    self.readMoreButton.layer.cornerRadius = 5;
    self.readMoreButton.layer.masksToBounds = YES;
    self.readMoreButton.layer.borderColor = [UIColor colorWithRed:0.80f green:0.80f blue:0.80f alpha:1.0f].CGColor;
    self.readMoreButton.layer.borderWidth = 1.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)toggleReadMore:(id)sender {
    NSIndexPath *indexPath = [self.parentView indexPathForCell:self];
    if ([self.readMoreButton.titleLabel.text isEqualToString:@"Read More"]) {
        
        CGFloat origHeight = self.hostBioLabel.frame.size.height;
        
        self.hostBioLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.hostBioLabel.numberOfLines = 0;
        [self.hostBioLabel sizeToFit];
        
        CGFloat newHeight = self.hostBioLabel.frame.size.height;
        
        TLDetailViewController * target = (TLDetailViewController *) self.parentView.delegate;
        
        target.isHostReadMoreOpen = YES;
        CGFloat changedHeight = self.frame.size.height + newHeight - origHeight;
        [target.cellHeights setObject:[NSNumber numberWithFloat:changedHeight] atIndexedSubscript:indexPath.row];
    } else {
        CGFloat origHeight = self.hostBioLabel.frame.size.height;
        
        self.hostBioLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.hostBioLabel.numberOfLines = 5;
        [self.hostBioLabel sizeToFit];
        CGFloat newHeight = self.hostBioLabel.frame.size.height;
        TLDetailViewController * target = (TLDetailViewController *) self.parentView.delegate;
        
        target.isHostReadMoreOpen = NO;
        CGFloat changedHeight = self.frame.size.height + newHeight - origHeight;
        [target.cellHeights setObject:[NSNumber numberWithFloat:changedHeight] atIndexedSubscript:indexPath.row];
    }
    
    [[self parentView] beginUpdates];
    [[self parentView] reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem: 2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self parentView] endUpdates];
}

@end
