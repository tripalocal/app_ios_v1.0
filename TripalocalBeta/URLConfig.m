//
//  URLConfig.m
//  TripalocalBeta
//
//  Created by Ye He on 19/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "URLConfig.h"

@implementation URLConfig

+ (NSString *)myTripServiceURLString
{
    if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-zhVersion"]) {
        return @"https://www.tripalocal.com/cn/service_mytrip/";
    } else {
        return @"https://www.tripalocal.com/service_mytrip/";
    }
}

+ (NSString *)imageServiceURLString
{
    if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-zhVersion"]) {
        return @"https://www.tripalocal.com/cn/images/";
    } else {
        return @"https://www.tripalocal.com/images//";
    }
}

+ (NSString *)loginServiceURLString
{
    if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-zhVersion"]) {
        return @"https://www.tripalocal.com/cn/service_login/";
    } else {
        return @"https://www.tripalocal.com/service_login/";
    }
}

+ (NSString *)myProfileServiceURLString
{
    if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-zhVersion"]) {
        return @"https://www.tripalocal.com/cn/service_myprofile/";
    } else {
        return @"https://www.tripalocal.com/service_myprofile/";
    }
}

+ (NSString *)logoutServiceURLString
{
    if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-zhVersion"]) {
        return @"https://www.tripalocal.com/cn/service_logout/";
    } else {
        return @"https://www.tripalocal.com/service_logout/";
    }
}

+ (NSString *)signupServiceURLString
{
    if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-zhVersion"]) {
        return @"https://www.tripalocal.com/cn/service_signup/";
    } else {
        return @"https://www.tripalocal.com/service_signup/";
    }
}

+ (NSString *)bookingServiceURLString
{
    if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-zhVersion"]) {
        return @"https://www.tripalocal.com/cn/service_booking/";
    } else {
        return @"https://www.tripalocal.com/service_booking/";
    }
}

+ (NSString *)searchServiceURLString
{
    if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-zhVersion"]) {
        return @"https://tripalocal.com/cn/service_search/";
    } else {
        return @"https://tripalocal.com/service_search/";
    }
}

+ (NSString *)expDetailhServiceURLString
{
    if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-zhVersion"]) {
        return @"https://tripalocal.com/cn/service_experience/";
    } else {
        return @"https://tripalocal.com/service_experience/";
    }
}

@end
