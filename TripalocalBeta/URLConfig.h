//
//  URLConfig.h
//  TripalocalBeta
//
//  Created by Ye He on 19/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLConfig : NSObject
+ (NSString *)homePageCityImageURLString;

+ (NSString *)myTripServiceURLString;

+ (NSString *)imageServiceURLString;

+ (NSString *)loginServiceURLString;

+ (NSString *)logoutServiceURLString;

+ (NSString *)myProfileServiceURLString;

+ (NSString *)signupServiceURLString;

+ (NSString *)bookingServiceURLString;

+ (NSString *)searchServiceURLString;

+ (NSString *)expServiceURLString;

+ (NSString *)expDetailServiceURLString;

+ (NSString *)staticServiceURLString;

@end
