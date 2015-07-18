//
//  PageContentViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 18/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "PageContentViewController.h"

@interface PageContentViewController ()

@end

@implementation PageContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tutorialImage.image = [UIImage imageNamed:self.imageFile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
