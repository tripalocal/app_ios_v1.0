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
    NSMutableArray *filteredLocations;
}

@property (strong, nonatomic) NSMutableDictionary *cachedImages;
@end

@implementation TLHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Init
    locations = [[NSMutableArray alloc]init];
    locationsURLString = [[NSMutableArray alloc]init];
    self.cachedImages = [[NSMutableDictionary alloc]init];

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
    self.searchController.searchBar.layer.borderWidth = 0.5;
    self.searchController.searchBar.layer.borderColor = [[UIColor grayColor] CGColor];
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
    
    NSString *imageCachingIdentifier = [NSString stringWithFormat:@"Cell%ld",(long)indexPath.row];
    
    if (self.searchController.active) {
        if (self.searchController.searchBar.text.length == 0) {
            cell2.textLabel.text = locations[indexPath.row];
        } else {
            cell2.textLabel.text = filteredLocations[indexPath.row];
        }
        cell2.imageView.image = [UIImage imageNamed:@"location.png"];
        return cell2;
    } else {
        cell.homeLocationImage.image = nil;
        if([self.cachedImages objectForKey:imageCachingIdentifier]){
            cell.homeLocationImage.image = [self.cachedImages objectForKey:imageCachingIdentifier];
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *locImageURLString = [locationsURLString objectAtIndex:indexPath.row];
                
                NSData *locImageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:locImageURLString]];
                
                if (locImageData) {
                    UIImage *locImage = [UIImage imageWithData:locImageData];
                    if (locImage) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            TLHomeTableViewCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                            if (updateCell) {
                                updateCell.homeLocationImage.image = locImage;
                                [self.cachedImages setValue:locImage forKey:imageCachingIdentifier];
                            }
                        });
                    }
                }
            });
        }
        
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
