//
//  MySearchDisplayController.m
//  TripalocalBeta
//
//  Created by Ye He on 16/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "MySearchDisplayController.h"
#import "TLSearchViewController.h"

@implementation MySearchDisplayController {
    NSArray *locations;
    NSArray *filteredLocations;
}

- (void)viewDidLoad {
    locations = @[@"Melbourne", @"Sydney", @"Brisbane",
                  @"Adelaide", @"Cairns", @"Goldcoast", @"Hobart"];
    
    filteredLocations = [locations copy];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.scopeButtonTitles = @[];
    self.searchController.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.searchController.searchBar sizeToFit];
    //localize
    self.searchController.searchBar.placeholder = @"Where are you goning?";
    self.searchController.searchBar.barTintColor = [UIColor whiteColor];
    [self.searchController.searchBar setImage:[UIImage new] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    NSShadow *shadow = [NSShadow new];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
     setTitleTextAttributes: @{
                               NSForegroundColorAttributeName: [UIColor grayColor],
                               NSShadowAttributeName: shadow }
     forState:UIControlStateNormal];
    self.searchController.searchBar.layer.borderWidth = 1;
    self.searchController.searchBar.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString];
    [self.tableView reloadData];
}

- (void)searchForText:(NSString *)searchText {
    NSPredicate *startsWith = [NSPredicate predicateWithFormat:@"SELF beginswith[c] %@", searchText];
    
    filteredLocations = [locations filteredArrayUsingPredicate:startsWith];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier=@"CityCell";
    UITableViewCell *cell = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (self.searchController.active) {
        if (self.searchController.searchBar.text.length == 0) {
            cell.textLabel.text = locations[indexPath.row];
        } else {
            cell.textLabel.text = filteredLocations[indexPath.row];
        }
    } else {
        cell.textLabel.text = locations[indexPath.row];
    }
    
    cell.imageView.image = [UIImage imageNamed:@"location.png"];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *city = (NSString *)sender;
    if ([segue.identifier isEqualToString:@"searchToExpList"]) {
        TLSearchViewController *vc=[segue destinationViewController];
        vc.cityName = city;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    self.searchController.searchBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.searchController.searchBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}
@end
