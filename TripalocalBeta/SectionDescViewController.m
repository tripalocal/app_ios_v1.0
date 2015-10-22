//
//  SectionDescViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 16/10/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "SectionDescViewController.h"

@interface SectionDescViewController ()

@end

@implementation SectionDescViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.sectionTitle;
    self.sectionDescLabel.text = self.sectionDescription;
}


@end
