//
//  TLHomeViewController.m
//  TripalocalBeta
//
//  Created by Charles He on 12/05/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "TLHomeViewController.h"
#import "TLHomeTableViewCell.h"
#import "TLSearchViewController.h"
#import "Constant.h"

@interface TLHomeViewController ()
{
    NSMutableArray *locations;
    NSMutableArray *locationsURLString;

}

@property (strong, nonatomic) NSMutableDictionary *cachedImages;
@end

@implementation TLHomeViewController
@synthesize homeTable;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Init
    locations = [[NSMutableArray alloc]init];
    locationsURLString = [[NSMutableArray alloc]init];
    self.cachedImages = [[NSMutableDictionary alloc]init];

    homeTable.dataSource=self;
    homeTable.delegate=self;
    
    [locations addObject:@"Melbourne"];
    [locations addObject:@"Sydney"];
    [locations addObject:@"Brisbane"];
    [locations addObject:@"Adelaide"];
    [locations addObject:@"Cairns"];
    [locations addObject:@"Goldcoast"];
    [locations addObject:@"Hobart"];
    
    [locationsURLString addObject:@"https://www.tripalocal.com/images/mobile/home/Melbourne.jpg"];
    [locationsURLString addObject:@"https://www.tripalocal.com/images/mobile/home/Sydney.jpg"];
    [locationsURLString addObject:@"https://www.tripalocal.com/images/mobile/home/Brisbane.jpg"];
    [locationsURLString addObject:@"https://www.tripalocal.com/images/mobile/home/Adelaide.jpg"];
    [locationsURLString addObject:@"https://www.tripalocal.com/images/mobile/home/Cairns.jpg"];
    [locationsURLString addObject:@"https://www.tripalocal.com/images/mobile/home/Goldcoast.jpg"];
    [locationsURLString addObject:@"https://www.tripalocal.com/images/mobile/home/Hobart.jpg"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void)cacheForImage{
    for (int index = 0; index< locations.count; index++) {
        
        NSString *imageCachingIdentifier = [NSString stringWithFormat:@"Cell%ld",(long)index];
        NSData *homeLocationImageData1 = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:[locationsURLString objectAtIndex:index]]];
        UIImage *image;
        image = [[UIImage alloc]initWithData:homeLocationImageData1];
        [self.cachedImages setValue:image forKey:imageCachingIdentifier];
        
    }


}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"homeTableCell";

    TLHomeTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
    {
        cell=[[TLHomeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString *imageCachingIdentifier = [NSString stringWithFormat:@"Cell%ld",(long)indexPath.row];
    
    if([self.cachedImages objectForKey:imageCachingIdentifier]){
        cell.homeLocationImage.image = [self.cachedImages objectForKey:imageCachingIdentifier];
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *homeLocationImageURLString = [locationsURLString objectAtIndex:indexPath.row];

            NSData *homeLocationImageDate = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:homeLocationImageURLString]];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                cell.homeLocationImage.image = [[UIImage alloc] initWithData:homeLocationImageDate];
                [self.cachedImages setObject:cell.homeLocationImage.image forKey:imageCachingIdentifier];
            });
            
        });
    }
    
    cell.homeLocationLabel.text = NSLocalizedString([locations objectAtIndex:indexPath.row], nil);
    cell.homeLocationLabel.textAlignment = NSTextAlignmentCenter;
   
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return locations.count;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ExpListSegue"]) {
        TLSearchViewController *vc=[segue destinationViewController];
        
        NSIndexPath *index=[homeTable indexPathForSelectedRow];
        NSString *cityName = [locations objectAtIndex:index.row];
        vc.cityName = cityName;
    }
}

- (IBAction)unwindToHome:(UIStoryboardSegue *)unwindSegue {
    [self.tabBarController setSelectedIndex:2];
}

- (IBAction)myButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
