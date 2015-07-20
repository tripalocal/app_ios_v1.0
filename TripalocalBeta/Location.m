//
//  Location.m
//  TripalocalBeta
//
//  Created by Ye He on 20/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "Location.h"

@implementation Location

- (id)initWithLoc:(NSString *)loc andLocName:(NSString *)locName
{
    self = [super init];
    if(self) {
        self.location = loc;
        self.locationName = locName;
    }
    return self;
}
@end
