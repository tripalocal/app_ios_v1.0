//
//  UpcommingViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 6/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "UpcommingTripsViewController.h"
#import "MyTripTableViewCell.h"
#import "TLDetailViewController.h"
#import "MyTripViewController.h"
#import "Constant.h"

@interface UpcommingTripsViewController ()

@end

@implementation UpcommingTripsViewController

- (NSMutableArray *)abstractTripsFilter:(NSArray *) allTrips {
    NSMutableArray *resultTrips = [[NSMutableArray alloc] init];
    
    for (NSDictionary *trip in allTrips) {
        NSDate *today = [NSDate date];
        NSString *datetimeString = [trip objectForKey:@"datetime"];
        NSDate *date = [super parseDateTimeString:datetimeString];
        
        if (!([date compare:today] == NSOrderedAscending)) {
            [resultTrips addObject:trip];
        }
    }
    
    NSSortDescriptor *datetimeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"datetime" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:datetimeDescriptor];
    return (NSMutableArray *)[resultTrips sortedArrayUsingDescriptors:sortDescriptors];
}

@end
