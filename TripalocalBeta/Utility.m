//
//  Utility.m
//  TripalocalBeta
//
//  Created by Ye He on 20/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (UIImage *)croppIngimageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGRect newRect = rect;
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], newRect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}


+ (NSString *) decimalwithFormat:(NSString *)format floatV:(float)floatV
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:format];
    return [numberFormatter stringFromNumber:@(floatV)];
}

+ (NSNumber *) numberWithFormat:(NSString *)format floatV:(float)floatV
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSString * decimalString = [self decimalwithFormat:format floatV:floatV];
    return [f numberFromString:decimalString];
}

@end
