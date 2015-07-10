//
//  MyTripViewController.h
//  TripalocalBeta
//
//  Created by Ye He on 6/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NeedToLoginView.h"

@interface MyTripViewController : UIViewController <NeedToLoginViewDelegate>
@property (strong, nonatomic) IBOutlet UIView *segmentTitleView;
@end
