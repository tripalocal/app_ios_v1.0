//
//  TLHomeViewController.m
//  TripalocalBeta
//
//  Created by Charles He on 12/05/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "TLHomeViewController.h"
#import "TLHomeTableViewCell.h"
@interface TLHomeViewController ()
{
    NSMutableArray *locationsURLString;
    NSMutableArray *locations;
}
@end

@implementation TLHomeViewController
@synthesize homeTable;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Init
    locations = [[NSMutableArray alloc]init];
    locationsURLString = [[NSMutableArray alloc]init];
    [locations addObject:@"Melbourne"];
    [locations addObject:@"Sydney"];
    [locationsURLString addObject:@"https://www.tripalocal.com/images/mobile/home/Melbourne.jpg"];
    [locationsURLString addObject:@"https://www.tripalocal.com/images/mobile/home/Sydney.jpg"];
    homeTable.dataSource=self;
    homeTable.delegate=self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"homeTableCell";
    
    TLHomeTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell)
    {
        cell=[[TLHomeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSData *homeLocationImageData1 = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:[locationsURLString objectAtIndex:indexPath.row]]];
    cell.homeLocationImage.image = [[UIImage alloc]initWithData:homeLocationImageData1];
    cell.homeLocationLabel.text = [locations objectAtIndex:indexPath.row];
    cell.homeLocationLabel.textAlignment = NSTextAlignmentCenter;
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return locations.count;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)myButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil]; 
}
@end
