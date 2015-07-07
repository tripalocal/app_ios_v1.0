//
//  MyTripViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 6/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "MyTripViewController.h"
#import "UpcommingTripsViewController.h"
#import "PreviousTripsViewController.h"

@interface MyTripViewController ()
@property (nonatomic, copy) NSArray *allViewControllers;

@property (strong, nonatomic) IBOutlet UIView *myTripContentView;
@property (strong, nonatomic) IBOutlet UIButton *upcommingButton;
@property (strong, nonatomic) IBOutlet UIButton *previousButton;

@property (nonatomic, strong) UIViewController *currentViewController;
@end

@implementation MyTripViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationController *upcommingNav = [self.storyboard instantiateViewControllerWithIdentifier:@"upcomming_trips_controller"];
    UpcommingTripsViewController *upcommingController = (UpcommingTripsViewController *)upcommingNav.topViewController;
    [upcommingController setContainerController:self];
    
    UINavigationController *previousNav = [self.storyboard instantiateViewControllerWithIdentifier:@"previous_trips_controller"];
    PreviousTripsViewController *previousController = (PreviousTripsViewController *)previousNav.topViewController;
    [previousController setContainerController:self];
    
    self.allViewControllers = [[NSArray alloc] initWithObjects:upcommingNav, previousNav, nil];
    
    [self cycleFromViewController:self.currentViewController toViewController:[self.allViewControllers objectAtIndex:0]];
}

- (IBAction)changeToPreviousView:(id)sender {
    [self.previousButton setBackgroundColor:[UIColor blueColor]];
    [self.previousButton setTintColor:[UIColor whiteColor]];
    
    [self.upcommingButton setBackgroundColor:[UIColor whiteColor]];
//    [myButton setTitleColor:[UIColor colorWithRed:150.0/256.0 green:150.0/256.0 blue:150.0/256.0 alpha:1.0] forState:UIControlStateHighlighted];
    [self.upcommingButton setTintColor:[UIColor blueColor]];

    UIViewController *incomingViewController = [self.allViewControllers objectAtIndex:1];
    [self cycleFromViewController:self.currentViewController toViewController:incomingViewController];
}


- (IBAction)changeToUpcommingView:(id)sender {
    [self.upcommingButton setBackgroundColor:[UIColor blueColor]];
    [self.upcommingButton setTintColor:[UIColor whiteColor]];
    [self.previousButton setBackgroundColor:[UIColor whiteColor]];
    [self.previousButton setTintColor:[UIColor blueColor]];

    UIViewController *incomingViewController = [self.allViewControllers objectAtIndex:0];
    [self cycleFromViewController:self.currentViewController toViewController:incomingViewController];
}

- (void)cycleFromViewController:(UIViewController*)oldVC toViewController:(UIViewController*)newVC {
    if (newVC == oldVC) return;
    if (newVC) {
        newVC.view.frame = CGRectMake(CGRectGetMinX(self.myTripContentView.bounds), CGRectGetMinY(self.myTripContentView.bounds), CGRectGetWidth(self.myTripContentView.bounds), CGRectGetHeight(self.myTripContentView.bounds));
        if (oldVC) {
            
            // Start both the view controller transitions
            [oldVC willMoveToParentViewController:nil];
            [self addChildViewController:newVC];
            
            // Swap the view controllers
            // No frame animations in this code but these would go in the animations block
            [self transitionFromViewController:oldVC
                              toViewController:newVC
                                      duration:0.25
                                       options:UIViewAnimationOptionLayoutSubviews
                                    animations:^{}
                                    completion:^(BOOL finished) {
                                        // Finish both the view controller transitions
                                        [oldVC removeFromParentViewController];
                                        [newVC didMoveToParentViewController:self];
                                        self.currentViewController = newVC;
                                    }];
        } else {
            // Otherwise we are adding a view controller for the first time
            // Start the view controller transition
            [self addChildViewController:newVC];
            
            // Add the new view controller view to the ciew hierarchy
            [self.myTripContentView addSubview:newVC.view];
            
            // End the view controller transition
            [newVC didMoveToParentViewController:self];
            
            // Store a reference to the current controller
            self.currentViewController = newVC;
        }
    }
}

- (IBAction)startExploring:(id)sender {
    [self.tabBarController setSelectedIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
