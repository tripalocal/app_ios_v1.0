//
//  Spinner.m
//  TripalocalBeta
//
//  Created by Charles He on 6/06/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "Spinner.h"


@implementation Spinner

+(Spinner *)loadSpinnerIntoView:(UIView *)superView{
    
    // Create a new view with the same frame size as the superView
    Spinner *spinerView=[[Spinner alloc]initWithFrame:superView.bounds];
    if(!spinerView)
    {
        return nil;
    }
    
    //Add UIActivityIndicator
    UIActivityIndicatorView *indicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    // Set the resizing mask so it's not stretched
    indicator.autoresizingMask=UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    //Place indicator into center of spinerView
    indicator.center=spinerView.center;
    [spinerView addSubview:indicator];
    [indicator startAnimating];
    
    //Radial Gradiant
    UIImageView *backgroundView=[[UIImageView alloc]initWithImage:[spinerView addBackground]];
    backgroundView.alpha=0.7;
    [spinerView addSubview:backgroundView];
    
    //OR
    //Black Background
    //    spinerView.backgroundColor=[UIColor blackColor];
    //    spinerView.alpha=0.75;
    
    [superView addSubview:spinerView];
    
    CATransition *animation=[CATransition animation];
    // Set the type to a nice wee fade
    [animation setType:kCATransitionFade];
    //Add it to superview
    [[superView layer]addAnimation:animation forKey:@"layerAnimation"];
    
    return spinerView;
}

-(void)removeSpinner{
    CATransition *animation=[CATransition animation];
    // Set the type to a nice wee fade
    [animation setType:kCATransitionFade];
    //Add it to superview
    [[[self superview]layer]addAnimation:animation forKey:@"layerAnimation"];
    [super removeFromSuperview];
}



-(UIImage *)addBackground{
    // Create an image context (think of this as a canvas for our masterpiece) the same size as the view
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 1);
    
    //Two locations - start and finish. More complex gradients might have more colours
    size_t num_locations=2;
    // The location of the colors is at the start and end
    CGFloat locations[2]={0.0,1.0};
    // Colors (two RBGA values)
    CGFloat component[8]={
        0.4,0.4,0.4,0.8,
        0.1,0.1,0.1,0.5
    };
    // Create a color space
    CGColorSpaceRef myColorSpace=CGColorSpaceCreateDeviceRGB();
    
    // Create a gradient with the values we've set up
    CGGradientRef myGradient=CGGradientCreateWithColorComponents(myColorSpace, component, locations, num_locations);
    
    // Set the radius to a nice size, 80% of the width.
    float myRadius=(self.bounds.size.width*.8)/2;
    
    // Now we draw the gradient into the context. Think painting onto the canvas
    CGContextDrawRadialGradient (UIGraphicsGetCurrentContext(), myGradient, self.center, 0, self.center, myRadius, kCGGradientDrawsAfterEndLocation);
    // Rip the 'canvas' into a UIImage object
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    //Release memory
    CGColorSpaceRelease(myColorSpace);
    CGGradientRelease(myGradient);
    UIGraphicsEndImageContext();
    
    return image;
}

@end
