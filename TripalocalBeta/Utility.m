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
    CGRect newRect = CGRectMake(rect.origin.x + 45, rect.origin.y + 50, rect.size.width - 65, rect.size.height * 2 -50);
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], newRect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

@end
