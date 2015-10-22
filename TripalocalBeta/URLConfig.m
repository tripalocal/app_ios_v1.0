//
//  URLConfig.m
//  TripalocalBeta
//
//  Created by Ye He on 19/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "URLConfig.h"

@implementation URLConfig

+ (NSString *)homePageCityImageURLString
{
//#ifdef CN_VERSION
//    return @"https://www.tripalocal.com.cn/images/mobile/home/";
//#else
//    return @"https://www.tripalocal.com/images/mobile/home/";
//#endif
    return @"https://tripalocal-static.s3.amazonaws.com/images/mobile/home/";
}
+ (NSString *)myTripServiceURLString
{
#ifdef CN_VERSION
        return @"https://www.tripalocal.com.cn/service_mytrip/";
#else
        return @"https://www.tripalocal.com/service_mytrip/";
#endif
}

+ (NSString *)staticServiceURLString
{
    return @"https://tripalocal-static.s3.amazonaws.com/static/";
}

+ (NSString *)imageServiceURLString
{
//#ifdef CN_VERSION
//        return @"https://www.tripalocal.com.cn/images/";
//#else
//        return @"https://www.tripalocal.com/images/";
//#endif
    return @"https://tripalocal-static.s3.amazonaws.com/images/";
}

+ (NSString *)loginServiceURLString
{
#ifdef CN_VERSION
        return @"https://www.tripalocal.com.cn/service_login/";
#else
        return @"https://www.tripalocal.com/service_login/";
#endif
}

+ (NSString *)myProfileServiceURLString
{
#ifdef CN_VERSION
        return @"https://www.tripalocal.com.cn/service_myprofile/";
#else
        return @"https://www.tripalocal.com/service_myprofile/";
#endif
}

+ (NSString *)logoutServiceURLString
{
#ifdef CN_VERSION
        return @"https://www.tripalocal.com.cn/service_logout/";
#else
        return @"https://www.tripalocal.com/service_logout/";
#endif
}

+ (NSString *)signupServiceURLString
{
#ifdef CN_VERSION
        return @"https://www.tripalocal.com.cn/service_signup/";
#else
        return @"https://www.tripalocal.com/service_signup/";
#endif
}

+ (NSString *)bookingServiceURLString
{
#ifdef CN_VERSION
        return @"https://www.tripalocal.com.cn/service_booking/";
#else
        return @"https://www.tripalocal.com/service_booking/";
#endif
}

+ (NSString *)searchServiceURLString
{
#ifdef CN_VERSION
        return @"https://tripalocal.com.cn/service_search/";
#else
        return @"https://tripalocal.com/service_search/";
#endif
}

+ (NSString *)expServiceURLString
{
#ifdef CN_VERSION
        return @"https://tripalocal.com.cn/service_experience/";
#else
        return @"https://tripalocal.com/service_experience/";
#endif
}

+ (NSString *)expDetailServiceURLString
{
#ifdef CN_VERSION
    return @"https://tripalocal.com.cn/service_experiencedetail/";
#else
    return @"https://tripalocal.com/service_experiencedetail/";
#endif
}

+ (NSString *)serviceMessageListURLString
{
#ifdef CN_VERSION
    return @"https://tripalocal.com.cn/service_message_list/";
#else
    return @"https://tripalocal.com/service_message_list/";
#endif
}

+ (NSString *)serviceMessageURLString
{
#ifdef CN_VERSION
    return @"https://tripalocal.com.cn/service_message/";
#else
    return @"https://tripalocal.com/service_message/";
#endif
}

+ (NSString *)servicePublicProfileURLString
{
#ifdef CN_VERSION
    return @"https://tripalocal.com.cn/service_publicprofile/";
#else
    return @"https://tripalocal.com/service_publicprofile/";
#endif
}
@end
