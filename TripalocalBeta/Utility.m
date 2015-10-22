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

+ (UIColor *) themeColor
{
    return [UIColor colorWithRed:0.20f green:0.80f blue:0.80f alpha:1.0f];
}


+ (NSString *)getCurrentUTCTime
{
    //get current time in UTC
    NSDate *currentDate = [NSDate date];//here it returns current date of device.
    //now set the timeZone and set the Date format to this date as you want.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setDateFormat:@"yyyy/MM/dd/HH/mm/ss"];
    [dateFormatter setTimeZone:timeZone];
    NSString *timeStamp = [dateFormatter stringFromDate:currentDate];
    // here you have new Date with desired format and TimeZone.
    return timeStamp;
}

+ (NSString *)showTimeDifference:(NSString *)previousTime
{
    NSString *currentTime = [Utility getCurrentUTCTime];
    NSString *dateString = [currentTime substringWithRange:NSMakeRange(0,10)];
    NSString *timeString = [currentTime substringWithRange:NSMakeRange(11, 8)];
    NSString *previousDateString = [previousTime substringWithRange:NSMakeRange(0, 10)];
    NSString *previousTimeString = [previousTime substringWithRange:NSMakeRange(11, 8)];
    //NSLog(@"%@ && %@" ,dateString,previousDateString);
    //NSLog(@"%@ && %@" ,timeString,previousTimeString);
    if ([previousDateString isEqualToString:dateString]) {
        if ([previousTimeString isEqualToString:timeString]) {
            return @"Now";
        }
        else{
            NSString *currentHour = [timeString substringWithRange:NSMakeRange(0, 2)];
            
            NSString *previousHour = [previousTimeString substringWithRange:NSMakeRange(0, 2)];
            NSString *previousMinute = [previousTimeString substringWithRange:NSMakeRange(3, 2)];
            NSString *previousSecond = [previousTimeString substringWithRange:NSMakeRange(6, 2)];
            NSString *currentMinute = [timeString substringWithRange:NSMakeRange(3, 2)];
            NSString *currentSecond = [timeString substringWithRange:NSMakeRange(6, 2)];
            if ([currentHour isEqualToString:previousHour]) {
                if ([currentMinute isEqualToString:previousMinute]) {
                    NSInteger pSecond = [previousSecond integerValue];
                    NSInteger cSecond = [currentSecond integerValue];
                    NSInteger delta = cSecond - pSecond;
                    NSString *returnSecondDelta = [NSString stringWithFormat:@"Just now"];
                    return returnSecondDelta;
                }
                else{
                    NSInteger pMinute = [previousMinute integerValue];
                    NSInteger cMinute = [currentMinute integerValue];
                    NSInteger delta = cMinute - pMinute;
                    NSString *returnMinuteDelta = [NSString stringWithFormat:@"%ld %s",delta,"min ago"];
                    return returnMinuteDelta;

                }
            }else{
                NSInteger pHour = [previousHour integerValue];
                NSInteger cHour = [currentHour integerValue];
                NSInteger delta = cHour - pHour;
                NSString *returnHourDelta = [NSString stringWithFormat:@"%ld %s",delta,"hour ago"];
                return returnHourDelta;

            }
            
           
        }
    } else {
        NSString *currentYear = [dateString substringWithRange:NSMakeRange(0, 4)];
        NSString *previousYear = [previousDateString substringWithRange:NSMakeRange(0, 4)];
        NSString *previousMonth = [previousDateString substringWithRange:NSMakeRange(5, 2)];
        NSString *currentMonth = [dateString substringWithRange:NSMakeRange(5, 2)];
        NSString *previousDay = [previousDateString substringWithRange:NSMakeRange(8, 2)];
        NSString *currentDay = [dateString substringWithRange:NSMakeRange(8, 2)];
        if ([currentYear isEqualToString:previousYear]) {
            if ([currentMonth isEqualToString:previousMonth]) {
                NSInteger pDay = [previousDay integerValue];
                NSInteger cDay = [currentDay integerValue];
                NSInteger delta = cDay - pDay;
                NSString *returnDayDelta = [NSString stringWithFormat:@"%ld %s",delta,"day ago"];
                return returnDayDelta;
            } else{
                NSInteger pMonth = [previousMonth integerValue];
                NSInteger cMonth = [currentMonth integerValue];
                NSInteger delta = cMonth - pMonth;
                NSString *returnMonthDelta = [NSString stringWithFormat:@"%ld %s",delta,"month ago"];
                return returnMonthDelta;
            }
        }else{
            NSInteger pYear = [previousYear integerValue];
            NSInteger cYear = [currentYear integerValue];
            NSInteger delta = cYear - pYear;
            NSString *returnYearDelta = [NSString stringWithFormat:@"%ld %s",delta,"year ago"];
            return returnYearDelta;
        }
    }
}


+ (UIImage *)filledImageFrom:(UIImage *)source withColor:(UIColor *)color{
    
    // begin a new image context, to draw our colored image onto with the right scale
    UIGraphicsBeginImageContextWithOptions(source.size, NO, [UIScreen mainScreen].scale);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, source.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, source.size.width, source.size.height);
    CGContextDrawImage(context, rect, source.CGImage);
    
    CGContextSetBlendMode(context, kCGBlendModeOverlay);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

+(NSString *) transformLanugage:(NSString *) languageString {
    NSMutableArray *languages = [[languageString componentsSeparatedByString:@";"] mutableCopy];
    [languages removeLastObject];
    for (NSUInteger i = 0; i < [languages count]; ++i) {
        NSString * language = [languages objectAtIndex:i];
        if ([language isEqualToString:@"mandarin"]) {
            [languages replaceObjectAtIndex:i withObject:@"中文"];
        } else {
            [languages replaceObjectAtIndex:i withObject:[language capitalizedString]];
        }
    }
    
    return [languages componentsJoinedByString:@" / "];
}
@end
