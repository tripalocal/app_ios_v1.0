//
//  PageContentViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 18/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "PageContentViewController.h"
#import "Utility.h"

@interface PageContentViewController ()

@end

@implementation PageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startExploringButton.layer.cornerRadius = 5.0f;
    self.startExploringButton.layer.masksToBounds = YES;
    if (self.pageIndex == 2) {
        [self.startExploringButton setHidden:NO];
    } else {
        [self.startExploringButton setHidden:YES];
    }
}

- (void)viewDidLayoutSubviews {
    [self.tutorialImage setClipsToBounds:YES];
    self.tutorialImage.image = [UIImage imageNamed:self.imageFile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)startExploring:(id)sender {
    [self.rootVC startExploring];
}

@end
