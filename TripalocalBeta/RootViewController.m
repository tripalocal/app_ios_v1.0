//
//  RootViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 18/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "RootViewController.h"
#import "PageContentViewController.h"
#import "HomeViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.pageImages = @[NSLocalizedString(@"slide1", nil), NSLocalizedString(@"slide2", nil), NSLocalizedString(@"slide3", nil)];
        self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"page_view_controller"];
        self.pageViewController.dataSource = self;
        
        PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
        NSArray *viewControllers = @[startingViewController];
        
        [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        
        self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height + 37);
        
        [self addChildViewController:_pageViewController];
        [self.view addSubview:_pageViewController.view];
        [self.pageViewController didMoveToParentViewController:self];
        
        [self.pageControl setNumberOfPages:[self.pageImages count]];
        [self.view bringSubviewToFront:self.pageControl];
//        [self.view bringSubviewToFront:self.btnSkip];
    } else {
        [self.pageViewController.view removeFromSuperview];
        [self.pageViewController removeFromParentViewController];
        [self performSegueWithIdentifier:@"goto_home" sender:nil];
    }
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageImages count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageImages count] == 0) || (index >= [self.pageImages count])) {
        return nil;
    }
    
    PageContentViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"page_content_controller"];
    pageContentViewController.imageFile = self.pageImages[index];
    pageContentViewController.pageIndex = index;
    pageContentViewController.rootVC = self;
    
    return pageContentViewController;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    [self.pageControl setCurrentPage:index];
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    [self.pageControl setCurrentPage:index];
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageImages count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (void)startExploring {
    [self.pageViewController.view removeFromSuperview];
    [self.pageViewController removeFromParentViewController];
    [self performSegueWithIdentifier:@"goto_home" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
