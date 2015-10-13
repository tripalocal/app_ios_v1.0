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
#import "TLMultiDaySearchViewController.h"
#import "TLBannerTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ButtonTableViewCell.h"
#import "Constant.h"
#import "Utility.h"
#import "Location.h"
#import "URLConfig.h"

NSInteger const ButtonCellPos = 1;
NSInteger const CustomItineraryPos = 3;
NSInteger const WeChatCellPos = 7;

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
    
    [locations addObject:[[Location alloc] initWithLoc:@"Melbourne" andLocName:NSLocalizedString(@"melbourne",  nil)]];
    [locations addObject:[[Location alloc] initWithLoc:@"Sydney" andLocName:NSLocalizedString(@"sydney",  nil)]];
    [locations addObject:[[Location alloc] initWithLoc:@"Brisbane" andLocName:NSLocalizedString(@"brisbane",  nil)]];
    [locations addObject:[[Location alloc] initWithLoc:@"Adelaide" andLocName:NSLocalizedString(@"adelaide",  nil)]];
    [locations addObject:[[Location alloc] initWithLoc:@"Cairns" andLocName:NSLocalizedString(@"cairns",  nil)]];
    [locations addObject:[[Location alloc] initWithLoc:@"Goldcoast" andLocName:NSLocalizedString(@"goldcoast",  nil)]];
    [locations addObject:[[Location alloc] initWithLoc:@"Hobart" andLocName:NSLocalizedString(@"hobart",  nil)]];
    [locations addObject:[[Location alloc] initWithLoc:@"Darwin" andLocName:NSLocalizedString(@"darwin", nil)]];
    [locations addObject:[[Location alloc] initWithLoc:@"Alice Springs" andLocName:NSLocalizedString(@"alicesprings", nil)]];
    [locations addObject:[[Location alloc] initWithLoc:@"Christchurch" andLocName:NSLocalizedString(@"christchurch",  nil)]];
    [locations addObject:[[Location alloc] initWithLoc:@"Queenstown" andLocName:NSLocalizedString(@"queenstown",  nil)]];
    [locations addObject:[[Location alloc] initWithLoc:@"Auckland" andLocName:NSLocalizedString(@"auckland", nil)]];
    [locations addObject:[[Location alloc] initWithLoc:@"Wellington" andLocName:NSLocalizedString(@"wellington", nil)]];

    filteredLocations = [locations mutableCopy];
    
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    
    
    [locationsURLString addObject: [NSString stringWithFormat:@"%@%@", [URLConfig homePageCityImageURLString], @"Melbourne.jpg"]];
    [locationsURLString addObject: [NSString stringWithFormat:@"%@%@", [URLConfig homePageCityImageURLString], @"Sydney.jpg"]];
    [locationsURLString addObject: [NSString stringWithFormat:@"%@%@", [URLConfig homePageCityImageURLString], @"Brisbane.jpg"]];
    [locationsURLString addObject: [NSString stringWithFormat:@"%@%@", [URLConfig homePageCityImageURLString], @"Adelaide.jpg"]];
    [locationsURLString addObject: [NSString stringWithFormat:@"%@%@", [URLConfig homePageCityImageURLString], @"Cairns.jpg"]];
    [locationsURLString addObject: [NSString stringWithFormat:@"%@%@", [URLConfig homePageCityImageURLString], @"Goldcoast.jpg"]];
    [locationsURLString addObject: [NSString stringWithFormat:@"%@%@", [URLConfig homePageCityImageURLString], @"Hobart.jpg"]];
    [locationsURLString addObject: [NSString stringWithFormat:@"%@%@", [URLConfig homePageCityImageURLString], @"Darwin.jpg"]];
    [locationsURLString addObject: [NSString stringWithFormat:@"%@%@", [URLConfig homePageCityImageURLString], @"Alicesprings.jpg"]];
    [locationsURLString addObject: [NSString stringWithFormat:@"%@%@", [URLConfig homePageCityImageURLString], @"Christchurch.jpg"]];
    [locationsURLString addObject: [NSString stringWithFormat:@"%@%@", [URLConfig homePageCityImageURLString], @"Queenstown.jpg"]];
    [locationsURLString addObject: [NSString stringWithFormat:@"%@%@", [URLConfig homePageCityImageURLString], @"Auckland.jpg"]];
    [locationsURLString addObject: [NSString stringWithFormat:@"%@%@", [URLConfig homePageCityImageURLString], @"Wellington.jpg"]];
    
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
    static NSString *bannerCellID=@"BannerCell";
    static NSString *buttonCellID=@"ButtonCell";

    TLHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    TLBannerTableViewCell *bannerCell = [tableView dequeueReusableCellWithIdentifier:bannerCellID];
    ButtonTableViewCell *buttonCell = [tableView dequeueReusableCellWithIdentifier:buttonCellID];
    UITableViewCell *cell2 = (UITableViewCell *) [tableView dequeueReusableCellWithIdentifier:cityCell];
    if(!cell)
    {
        cell=[[TLHomeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if(!cell2)
    {
        cell2=[[TLHomeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cityCell];
    }
    
    if (!bannerCell)
    {
        [tableView registerNib:[UINib nibWithNibName:@"TLBannerTableViewCell" bundle:nil] forCellReuseIdentifier:bannerCellID];
        bannerCell = [tableView dequeueReusableCellWithIdentifier:bannerCellID];
    }
    
    if (!buttonCell)
    {
        [tableView registerNib:[UINib nibWithNibName:@"ButtonTableViewCell" bundle:nil] forCellReuseIdentifier:buttonCellID];
        buttonCell = [tableView dequeueReusableCellWithIdentifier:buttonCellID];
    }
    
    if (self.searchController.active) {
        if (self.searchController.searchBar.text.length == 0) {
            Location *loc = (Location *)locations[indexPath.row];
            cell2.textLabel.text = loc.locationName;
        } else {
            Location *loc = (Location *)filteredLocations[indexPath.row];
            cell2.textLabel.text = loc.locationName;
        }
        cell2.imageView.image = [UIImage imageNamed:@"location.png"];
        return cell2;
    } else {
        NSInteger iLocation;
        if (indexPath.row == CustomItineraryPos) {
            bannerCell.bannerImage.image = [UIImage imageNamed:NSLocalizedString(@"custom_itinerary", nil)];
            bannerCell.backgroundColor = [UIColor whiteColor];
            return bannerCell;
        } else if (indexPath.row == ButtonCellPos) {

            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                                     initWithTarget:self action:@selector(gotoTravelWithLocal:)];
            tapRecognizer.numberOfTapsRequired = 1;
            [buttonCell.travelWithLocalView addGestureRecognizer:tapRecognizer];
            return buttonCell;
            
        } else if (indexPath.row == WeChatCellPos) {
            bannerCell.bannerImage.image = [UIImage imageNamed:NSLocalizedString(@"wechat_banner", nil)];
            bannerCell.backgroundColor = [Utility themeColor];
            return bannerCell;
        } else if (indexPath.row > ButtonCellPos && indexPath.row < CustomItineraryPos) {
            iLocation = indexPath.row - 1;
        } else if (indexPath.row > CustomItineraryPos && indexPath.row < WeChatCellPos) {
            iLocation = indexPath.row - 2;
        } else if (indexPath.row > CustomItineraryPos && indexPath.row > WeChatCellPos){
            iLocation = indexPath.row - 3;
        } else {
            iLocation = indexPath.row;
        }
        
        NSString *locImageURLString = [locationsURLString objectAtIndex:iLocation];
        
        __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [cell.homeLocationImage setClipsToBounds:YES];
        activityIndicator.center = cell.homeLocationImage.center;
        activityIndicator.hidesWhenStopped = YES;
        [cell.homeLocationImage sd_setImageWithURL:[NSURL URLWithString:locImageURLString]
                                  placeholderImage:nil
                                           options:SDWebImageRefreshCached
                                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                             cell.homeLocationImage.image = [Utility filledImageFrom:image withColor:[UIColor colorWithWhite:0.0 alpha:0.3]];
                                             [activityIndicator removeFromSuperview];
                                         }];
        [cell.homeLocationImage addSubview:activityIndicator];
        [activityIndicator startAnimating];
        
        Location *loc = (Location *)locations[iLocation];
        cell.homeLocationLabel.text = loc.locationName;
        cell.homeLocationLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    }
}

- (IBAction)gotoTravelWithLocal:(UITapGestureRecognizer *)recognizer {
    [self performSegueWithIdentifier:@"searchToExpList" sender:@"Melbourne"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchController.active) {
        return 44.f;
    } else if (indexPath.row == CustomItineraryPos || indexPath.row == WeChatCellPos) {
        return 220.f;
    } else if (indexPath.row == ButtonCellPos) {
        return 120.f;
    }else {
        return 308.f;
    }
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString];
    [self.tableView reloadData];
}

- (void)searchForText:(NSString *)searchText {
    NSPredicate *startsWith = [NSPredicate predicateWithFormat:@"locationName beginswith[c] %@", searchText];
    
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
        return [locations count] + 3;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *city;
    if (self.searchController.active) {
        if (self.searchController.searchBar.text.length == 0) {
            Location *loc = (Location *)locations[indexPath.row];
            city = loc.location;
        } else {
            Location *loc = (Location *)filteredLocations[indexPath.row];
            city = loc.location;
        }
    } else {
        NSInteger iLocation;
        if (indexPath.row == CustomItineraryPos) {
            [self emailUs];
            return;
        } else if (indexPath.row == WeChatCellPos) {
            [self openWeChat];
            return;
        } else if (indexPath.row == ButtonCellPos) {
            return;
        } else if (indexPath.row > ButtonCellPos && indexPath.row < CustomItineraryPos) {
            iLocation = indexPath.row - 1;
        } else if (indexPath.row > CustomItineraryPos && indexPath.row < WeChatCellPos) {
            iLocation = indexPath.row - 2;
        } else if (indexPath.row > CustomItineraryPos && indexPath.row > WeChatCellPos){
            iLocation = indexPath.row - 3;
        } else {
            iLocation = indexPath.row;
        }
        
        Location *loc = (Location *)locations[iLocation];
        city = loc.location;
    }
    
//    [self.searchController setActive:FALSE];
    [self performSegueWithIdentifier:@"searchToExpList" sender:city];
}

- (void)openWeChat {
    NSURL *wechatURL = [NSURL URLWithString:@"weixin://"];
    
    if ([[UIApplication sharedApplication] canOpenURL:wechatURL]) {
        [[UIApplication sharedApplication] openURL:wechatURL];
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert", nil) message:NSLocalizedString(@"alert_wechat", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"ok_button", nil) otherButtonTitles:nil];
        [alert show];
    }
}

- (void)emailUs {
    [self.searchController setActive:FALSE];
    [self performSegueWithIdentifier:@"searchToMultiExpList" sender:@"Melbourne"];
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
        vc.cityName = (NSString *)sender;
    } else if ([segue.identifier isEqualToString:@"searchToMultiExpList"]){
        TLMultiDaySearchViewController *vc = [segue destinationViewController];
        vc.cityName = (NSString *)sender;
    }
}

- (IBAction)unwindToHome:(UIStoryboardSegue *)unwindSegue {
    [self.tabBarController setSelectedIndex:1];
}

- (IBAction)myButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
