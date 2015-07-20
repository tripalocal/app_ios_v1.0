//
//  Location.h
//  TripalocalBeta
//
//  Created by Ye He on 20/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject
@property (weak, nonatomic) NSString *location;
@property (weak, nonatomic) NSString *locationName;
- (id)initWithLoc:(NSString *)loc andLocName:(NSString *)locName;
@end
