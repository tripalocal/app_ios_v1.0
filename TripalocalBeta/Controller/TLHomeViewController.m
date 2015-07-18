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
#import <SDWebImage/UIImageView+WebCache.h>
#import "Constant.h"

@interface TLHomeViewController () {
    NSMutableArray *locations;
    NSMutableArray *locationsURLString;
    NSMutableArray *filteredLocations;
}

@end

@implementation TLHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    locations = [[NSMutableArray alloc]init];
    locationsURLString = [[NSMutableArray alloc]init];

    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    
    locations = [@[@"Melbourne", @"Sydney", @"Brisbane", @"Adelaide",
                   @"Cairns", @"Goldcoast", @"Hobart"] mutableCopy];
    
    filteredLocations = [locations mutableCopy];
    
    [locationsURLString addObject:@"https://www.tripalocal.com/images/mobile/home/Melbourne.jpg"];
    [locationsURLString addObject:@"https://www.tripalocal.com/images/mobile/home/Sydney.jpg"];
    [locationsURLString addObject:@"https://www.tripalocal.com/images/mobile/home/Brisbane.jpg"];
    [locationsURLString addObject:@"https://www.tripalocal.com/images/mobile/home/Adelaide.jpg"];
    [locationsURLString addObject:@"https://www.tripalocal.com/images/mobile/home/Cairns.jpg"];
    [locationsURLString addObject:@"https://www.tripalocal.com/images/mobile/home/Goldcoast.jpg"];
    [locationsURLString addObject:@"https://www.tripalocal.com/images/mobile/home/Hobart.jpg"];

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.scopeButtonTitles = @[];
    self.searchController.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.searchController.searchBar sizeToFit];
    
    self.searchController.searchBar.placeholder = NSLocalizedString(@"search_hint", nil);
    self.searchController.searchBar.barTintColor = [UIColor whiteColor];
    [self.searchController.searchBar setImage:[UIImage new] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    NSShadow *shadow = [NSShadow new];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes: @{
                               NSForegroundColorAttributeName: [UIColor grayColor],
                               NSShadowAttributeName: shadow }
     forState:UIControlStateNormal];
    self.searchController.searchBar.layer.borderWidth = 0.5;
    self.searchController.searchBar.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier=@"homeTableCell";
    static NSString *cityCell=@"CityCell";

    TLHomeTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UITableViewCell *cell2 = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:cityCell];
    if(!cell)
    {
        cell=[[TLHomeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if(!cell2)
    {
        cell2=[[TLHomeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cityCell];
    }
    
    if (self.searchController.active) {
        if (self.searchController.searchBar.text.length == 0) {
            cell2.textLabel.text = locations[indexPath.row];
        } else {
            cell2.textLabel.text = filteredLocations[indexPath.row];
        }
        cell2.imageView.image = [UIImage imageNamed:@"location.png"];
        return cell2;
    } else {
        NSString *locImageURLString = [locationsURLString objectAtIndex:indexPath.row];
        [cell.homeLocationImage sd_setImageWithURL:[NSURL URLWithString:locImageURLString]
                                  placeholderImage:nil
                                           options:SDWebImageRefreshCached];
        
        cell.homeLocationLabel.text = NSLocalizedString([locations objectAtIndex:indexPath.row], nil);
        cell.homeLocationLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchController.active) {
        return 44.f;
    } else {
        return 308.f;
    }
}


- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString];
    [self.tableView reloadData];
}

- (void)searchForText:(NSString *)searchText {
    NSPredicate *startsWith = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", searchText];
    
    filteredLocations = [[locations filteredArrayUsingPredicate:startsWith] mutableCopy];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.searchController.active) {
        if (self.searchController.searchBar.text.length == 0) {
            return [locations count];
        } else {
            return [filteredLocations count];
        }
    } else {
        return [locations count];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *city;
    if (self.searchController.active) {
        if (self.searchController.searchBar.text.length == 0) {
            city = locations[indexPath.row];
        } else {
            city = filteredLocations[indexPath.row];
        }
    } else {
        city = locations[indexPath.row];
    }
    
    [self performSegueWithIdentifier:@"searchToExpList" sender:city];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    self.searchController.searchBar.hidden = NO;
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.searchController.searchBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"searchToExpList"]) {
        TLSearchViewController *vc=[segue destinationViewController];
        
        NSIndexPath *index=[self.tableView indexPathForSelectedRow];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
