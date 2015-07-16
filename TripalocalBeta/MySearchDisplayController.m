//
//  MySearchDisplayController.m
//  TripalocalBeta
//
//  Created by Ye He on 16/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "MySearchDisplayController.h"

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
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
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
        cell.textLabel.text = filteredLocations[indexPath.row];
    } else {
        cell.textLabel.text = locations[indexPath.row];
    }
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.active) {
        return [filteredLocations count];
    } else {
        return [locations count];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
