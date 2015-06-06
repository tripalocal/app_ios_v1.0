//
//  Spinner.h
//  TripalocalBeta
//
//  Created by Charles He on 6/06/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface Spinner : UIView

+(Spinner *)loadSpinnerIntoView:(UIView *)superView;
-(void)removeSpinner;
-(UIImage *)addBackground;

@end
