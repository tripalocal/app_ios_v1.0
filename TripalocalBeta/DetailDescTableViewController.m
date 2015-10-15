//
//  DetailDescTableViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 15/10/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "DetailDescTableViewController.h"
#import "DetailDescCell.h"

static NSString * const cellIdentifier0 = @"detailCell";

@interface DetailDescTableViewController ()

@end

@implementation DetailDescTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (void)setUpCell:(DetailDescCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            cell.titleLabel.text = @"Description";
            cell.contentLabel.text = self.description_detail;
            break;
        }
        case 1: {
            cell.titleLabel.text = @"Highlights";
            cell.contentLabel.text = self.highlights;
            break;
        }
        case 2: {
            cell.titleLabel.text = @"Tips";
            cell.contentLabel.text = self.tips;
            break;
        }
        default: {
            NSLog(@"Wrong number of cells.");
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DetailDescCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier0 forIndexPath:indexPath];
    
    [self setUpCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static DetailDescCell *cell = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier0];
    });
    
    [self setUpCell:cell atIndexPath:indexPath];
    
    return [self calculateHeightForConfiguredSizingCell:cell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


@end
