//
//  ReviewTableViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 12/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "ReviewTableViewController.h"
#import "TLDetailTableViewCell3.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Constant.h"
#import "URLConfig.h"

@interface ReviewTableViewController ()

@end

@implementation ReviewTableViewController {
    NSMutableDictionary *cachedImages;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    cachedImages = [[NSMutableDictionary alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.reviews count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *review = [self.reviews objectAtIndex:indexPath.row];
    NSString *reviewFirst = [review objectForKey:@"reviewer_firstname"];
    NSString *reviewLast = [review objectForKey:@"reviewer_lastname"];
    NSString *PREreviewerImageURL =[ review objectForKey:@"reviewer_image"];
    NSString *reviewerImageURL = [[URLConfig imageServiceURLString] stringByAppendingString: PREreviewerImageURL];
    NSString *reviewComment = [review objectForKey:@"review_comment"];

    TLDetailTableViewCell3 *cell = [tableView dequeueReusableCellWithIdentifier:@"cell3" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[TLDetailTableViewCell3 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell3"];
    }
    
    cell.reviewerName.text = [NSString stringWithFormat:@"%@ %@", reviewFirst, reviewLast];
    cell.commentLabel.text = reviewComment;
    
    [cell.reviewerImage sd_setImageWithURL:[NSURL URLWithString:reviewerImageURL]
                          placeholderImage:[UIImage imageNamed:@"default_profile_image.png"]
                                   options:SDWebImageRefreshCached];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

@end
