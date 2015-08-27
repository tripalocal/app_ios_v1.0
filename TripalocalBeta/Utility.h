//
//  Utility.h
//  TripalocalBeta
//
//  Created by Ye He on 20/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject
+ (UIImage *)	croppIngimageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect;
+ (NSString *) 	decimalwithFormat:(NSString *)format floatV:(float)floatV;
+ (NSNumber *) 	numberWithFormat:(NSString *)format floatV:(float)floatV;
+ (UIColor *) 	themeColor;
+ (NSString *)	showTimeDifference:(NSString *)previousTime;
@end
