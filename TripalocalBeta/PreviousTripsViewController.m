//
//  PreviousTripsViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 6/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "PreviousTripsViewController.h"

@interface PreviousTripsViewController ()

@end

@implementation PreviousTripsViewController

- (NSMutableArray *)abstractTripsFilter:(NSArray *) allTrips {
    NSMutableArray *resultTrips = [[NSMutableArray alloc] init];
    
    for (NSDictionary *trip in allTrips) {
        NSDate *today = [NSDate date];
        NSString *datetimeString = [trip objectForKey:@"datetime"];
        NSDate *date = [super parseDateTimeString:datetimeString];
//        todo:
        if ([date compare:today] == NSOrderedDescending) {
            [resultTrips addObject:trip];
        }
    }
    
    NSSortDescriptor *datetimeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"datetime" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:datetimeDescriptor];
    return (NSMutableArray *)[resultTrips sortedArrayUsingDescriptors:sortDescriptors];
}

@end
