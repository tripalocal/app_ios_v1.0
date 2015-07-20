//
//  TLSearchViewController.m
//  TripalocalBeta
//
//  Created by Charles He on 17/05/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "TLSearchViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TLSearchTableViewCell.h"
#import "Spinner.h"
#import "Constant.h"
#import "URLConfig.h"
#import "TLDetailViewController.h"
#import "JGProgressHUD.h"

@interface TLSearchViewController (){
    NSString *priceString;
    NSMutableArray *dynamicPricingArray;
}
@end

@implementation TLSearchViewController{
    JGProgressHUD *HUD;
    NSString *currentLanguage;
    NSDateFormatter *dateFormatter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-LL-dd"];
    HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.HUDView.layer.shadowColor = [UIColor blackColor].CGColor;
    HUD.HUDView.layer.shadowOffset = CGSizeZero;
    HUD.HUDView.layer.shadowOpacity = 0.4f;
    HUD.HUDView.layer.shadowRadius = 8.0f;
    HUD.textLabel.text = @"Loading";
    [HUD showInView:self.view];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.expList = [self fetchExpData:self.cityName];
    
    [self.tableView reloadData];
    currentLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    dynamicPricingArray = [[NSMutableArray alloc]init];
    [HUD dismissAfterDelay:1.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)saveToWishListClicked:(NSInteger)buttonTag {
    [self toggleWishList: buttonTag];
}

- (IBAction)toggleWishList:(NSInteger)buttonTag {
   NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults stringForKey:@"user_token"];
    NSIndexPath * index = [NSIndexPath indexPathForRow:buttonTag inSection:0];
    
    if (token) {
        NSString *expIdString = [[[self.expList objectAtIndex:index.row] objectForKey:@"id"] stringValue];
        NSMutableArray *wishList = [NSMutableArray arrayWithArray:(NSArray *)[userDefaults objectForKey:@"wish_list"]];
        if ([wishList containsObject:expIdString]) {
            [wishList removeObject:expIdString];
        } else {
            [wishList addObject:expIdString];
        }
        
        [userDefaults setObject:wishList forKey:@"wish_list"];
        [userDefaults synchronize];
        
        NSArray *indexPaths = @[index];
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationMiddle];
    } else {
        [self performSegueWithIdentifier:@"login_segue" sender:nil];
    }
    
}

-(NSString *) transformLanugage:(NSString *) languageString {
    NSMutableArray *languages = [[languageString componentsSeparatedByString:@";"] mutableCopy];
    [languages removeLastObject];
    for (NSUInteger i = 0; i < [languages count]; ++i) {
        NSString * language = [languages objectAtIndex:i];
        if ([language isEqualToString:@"mandarin"]) {
            [languages replaceObjectAtIndex:i withObject:@"中文"];
        } else {
            [languages replaceObjectAtIndex:i withObject:[language capitalizedString]];
        }
    }
    
    return [languages componentsJoinedByString:@" / "];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"SearchCell";
    
    TLSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    if(!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"SearchViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    }
    
    NSDictionary *exp = [self.expList objectAtIndex:indexPath.row];
    NSString *expIdString = [[exp objectForKey:@"id"] stringValue];
    
    NSString *duration = [[exp objectForKey:@"duration"] stringValue];
    NSString *handledDurationString = [duration stringByAppendingString:NSLocalizedString(@"Hours", nil)];
    cell.durationLabel.text = handledDurationString;
    cell.titleLabel.text = [exp objectForKey:@"title"];

    cell.languageLabel.text = [self transformLanugage:(NSString *)[exp objectForKey:@"language"]];
    cell.descriptionLabel.text = [exp objectForKey:@"description"];

    NSString *hostImageRelativeURL = [exp objectForKey:@"host_image"];
    if (hostImageRelativeURL.length > 0) {
        NSString *hostImageURL = [[URLConfig imageServiceURLString] stringByAppendingString: hostImageRelativeURL];
        
        [cell.hostImage sd_setImageWithURL:[NSURL URLWithString:hostImageURL]
                          placeholderImage:[UIImage imageNamed:@"default_profile_image.png"]
                                   options:SDWebImageRefreshCached];
    } else {
        cell.hostImage.image = [UIImage imageNamed:@"default_profile_image.png"];
    }


    
    NSString *backgroundImageURL = [NSString stringWithFormat:@"%@thumbnails/experiences/experience%@_1.jpg", [URLConfig imageServiceURLString], expIdString];
    
    __block UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = cell.experienceImage.center;
    activityIndicator.hidesWhenStopped = YES;
    [cell.experienceImage sd_setImageWithURL:[NSURL URLWithString:backgroundImageURL]
                            placeholderImage:nil
                                     options:SDWebImageRefreshCached
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                       [activityIndicator removeFromSuperview];
                                       if (image) {
                                            cell.experienceImage.image = [self croppIngimageByImageName:image toRect:cell.experienceImage.frame];
                                       }
                                   }];

    [cell.experienceImage addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *wishList = [userDefaults objectForKey:@"wish_list"];
    
    if ([wishList containsObject:expIdString]) {
        [cell.wishListButton setBackgroundImage:[UIImage imageNamed:@"wishlisted.png"] forState:UIControlStateNormal];
        cell.smallWishImage.image = [UIImage imageNamed:@"heart_sr.png"];
        cell.wishStatus.text = NSLocalizedString(@"Saved", nil);;
    } else {
        [cell.wishListButton setBackgroundImage:[UIImage imageNamed:@"unwishlisted.png"] forState:UIControlStateNormal];
        cell.smallWishImage.image = [UIImage imageNamed:@"heart_sw.png"];
        cell.wishStatus.text = NSLocalizedString(@"Add to wishlist", nil);
    }
    cell.delegate = self;
    cell.wishListButton.tag = indexPath.row;
    priceString =[self decimalwithFormat:@"0" floatV:[[[self.expList objectAtIndex:indexPath.row] objectForKey:@"price"] floatValue]];
    cell.priceLabel.text = priceString;
    //???
    [dynamicPricingArray addObject:priceString];
    

    return cell;
}


// todo: move to utility file
- (UIImage *)croppIngimageByImageName:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return cropped;
}

- (NSString *) decimalwithFormat:(NSString *)format  floatV:(float)floatV
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    
    [numberFormatter setPositiveFormat:format];
    
    return  [numberFormatter stringFromNumber:[NSNumber numberWithFloat:floatV]];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.expList count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSMutableArray *)fetchExpData:(NSString *) cityName {
    NSMutableArray *expList = [[NSMutableArray alloc] init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];

    NSString *post = nil;
    NSDate *today = [NSDate date];

    NSString *startDate = [dateFormatter stringFromDate:today];
    NSString *endDate = [dateFormatter stringFromDate:today];
    
    if ([[[NSProcessInfo processInfo] arguments] containsObject:@"-zhVersion"]) {
        post = [NSString stringWithFormat:@"{\"start_datetime\":\"%@\", \"end_datetime\":\"%@\", \"city\":\"%@\", \"guest_number\":\"2\", \"keywords\":\"美食美酒,名校游学,历史人文,经典建筑,蜜月旅拍,风光摄影,移民考察,亲子夏令营,户外探险,购物扫货,运动休闲,领路人自驾,刺激享乐,赛事庆典,美容保健\"}", startDate, endDate ,cityName];
        [request setURL:[NSURL URLWithString:[URLConfig searchServiceURLString]]];
    } else {
        post = [NSString stringWithFormat:@"{\"start_datetime\":\"%@\", \"end_datetime\":\"%@\", \"city\":\"%@\", \"guest_number\":\"2\", \"keywords\":\"Food & wine, Education, History & culture, Architecture, For couples, Photography worthy, Livability research, Kids friendly, Outdoor & nature, Shopping, Sports & leisure, Host with car, Extreme fun, Events, Health & beauty, Private group\"}", startDate, endDate ,cityName];
        [request setURL:[NSURL URLWithString:[URLConfig searchServiceURLString]]];
    }
    
#ifdef DEBUG
    NSLog(@"Sending data = %@",post);
#endif
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];

    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    NSError *connectionError = nil;
    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    if (connectionError == nil) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSMutableArray *allDataDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if ([httpResponse statusCode] == 200) {
            NSDictionary *indexOfExperience = [allDataDictionary objectAtIndex:0];
            expList = [indexOfExperience objectForKey:@"experiences"];
            
#ifdef DEBUG
            NSLog(@"number of cells: %lu", (unsigned long)expList.count);
#endif
            
        }
        else {
#ifdef DEBUG
            NSLog(@"Sending data = %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
#endif
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fetching Data Failed"
                                                            message:@"Server Error"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                        message:@"You must be connected to the internet."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    return expList;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"SearchResultSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SearchResultSegue"]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        navController.hidesBottomBarWhenPushed = YES;
        TLDetailViewController *vc = (TLDetailViewController *) navController.topViewController;
        NSIndexPath *index=[_tableView indexPathForSelectedRow];
        vc.experience_id_string = [[[self.expList objectAtIndex:index.row] objectForKey:@"id"] stringValue];
        vc.expPrice = [dynamicPricingArray objectAtIndex:index.row];
    }
    
}

@end
