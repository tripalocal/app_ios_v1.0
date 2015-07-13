//
//  ReviewTableViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 12/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "ReviewTableViewController.h"
#import "TLDetailTableViewCell3.h"
#import "Constant.h"

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
    NSString *reviewerImageURL = [imageServiceURL stringByAppendingString: PREreviewerImageURL];
    NSString *reviewComment = [review objectForKey:@"review_comment"];

    TLDetailTableViewCell3 *cell = [tableView dequeueReusableCellWithIdentifier:@"cell3" forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[TLDetailTableViewCell3 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell3"];
    }
    
    cell.reviewerName.text = [NSString stringWithFormat:@"%@ %@", reviewFirst, reviewLast];
    cell.commentLabel.text = reviewComment;
    
    UIImage *reviewerImage = (UIImage *)[cachedImages objectForKey:[@(indexPath.row) stringValue]];
    
    if(!reviewerImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *hostImageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:reviewerImageURL]];
            dispatch_sync(dispatch_get_main_queue(), ^{
                UIImage *image = [[UIImage alloc] initWithData:hostImageData];
                if (image) {
                    [cachedImages setObject:image forKey:[@(indexPath.row) stringValue]];
                    cell.reviewerImage.image = (UIImage *)[cachedImages objectForKey:[@(indexPath.row) stringValue]];
                } else {
                    cell.reviewerImage.image = [UIImage imageNamed:@"default_profile_image.png"];
                    [cachedImages setObject:cell.reviewerImage.image forKey:[@(indexPath.row) stringValue]];
                }
            });
        });
    } else {
        cell.reviewerImage.image = reviewerImage;
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
