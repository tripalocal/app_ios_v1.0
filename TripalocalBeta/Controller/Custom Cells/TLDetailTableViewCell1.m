//
//  TLDetailTableViewCell1.m
//  TripalocalBeta
//
//  Created by Fangzhou He on 28/06/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "TLDetailTableViewCell1.h"
#import "TLDetailViewController.h"

@implementation TLDetailTableViewCell1

- (void)awakeFromNib {
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

        CGFloat origHeight = self.expDescriptionLabel.frame.size.height;

        self.expDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.expDescriptionLabel.numberOfLines = 0;
        [self.expDescriptionLabel sizeToFit];
        
        CGFloat newHeight = self.expDescriptionLabel.frame.size.height;
        
        TLDetailViewController * target = (TLDetailViewController *) self.parentView.delegate;
        
        target.isExpReadMoreOpen = YES;
        CGFloat changedHeight = self.frame.size.height + newHeight - origHeight;
        [target.cellHeights setObject:[NSNumber numberWithFloat:changedHeight] atIndexedSubscript:indexPath.row];
    } else {
        CGFloat origHeight = self.expDescriptionLabel.frame.size.height;
        
        self.expDescriptionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.expDescriptionLabel.numberOfLines = 5;
        [self.expDescriptionLabel sizeToFit];
        CGFloat newHeight = self.expDescriptionLabel.frame.size.height;
        TLDetailViewController * target = (TLDetailViewController *) self.parentView.delegate;

        target.isExpReadMoreOpen = NO;
        CGFloat changedHeight = self.frame.size.height + newHeight - origHeight;
        [target.cellHeights setObject:[NSNumber numberWithFloat:changedHeight] atIndexedSubscript:indexPath.row];
    }
    
    [[self parentView] beginUpdates];
    [[self parentView] reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem: 1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[self parentView] endUpdates];
}

@end
