//
//  CheckoutViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 4/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "URLConfig.h"
#import "CheckoutViewController.h"
#import "InstantBookingTableViewCell.h"
#import <SecureNSUserDefaults/NSUserDefaults+SecureAdditions.h>
#import "JGProgressHUD.h"
#import "Utility.h"
#import "Mixpanel.h"
#import "Constant.h"

@interface CheckoutViewController (){
    NSMutableArray *guestPickerData;
    NSMutableArray *datePickerData;
    NSMutableArray *timePickerData;
    NSMutableDictionary *wholePickerData;
    NSMutableArray *dynamicTimeArray;
    NSMutableArray *timeArray;
    NSMutableArray *instantDateArray;
    NSMutableArray *instantTimeArray;
    NSArray *availableDateArray;
    BOOL isInstant;
    JGProgressHUD *HUD;
    NSString *selectedTimeString;
    NSString *selectedDateString;
    NSString *selectedGuestString;
    BOOL isDateChoosed;
    BOOL isTimeChoosed;
    BOOL isGuestChoosed;
}

@end

@implementation CheckoutViewController

- (void)mpTrackViewCheckout {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults secretStringForKey:@"user_token"];
    
    if (token) {
        NSString * userEmail = [userDefaults stringForKey:@"user_email"];
        [mixpanel identify:userEmail];
        [mixpanel.people set:@{}];
    }
    
    [mixpanel track:mpTrackViewCheckout properties:@{@"language":language}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.HUDView.layer.shadowColor = [UIColor blackColor].CGColor;
    HUD.HUDView.layer.shadowOffset = CGSizeZero;
    HUD.HUDView.layer.shadowOpacity = 0.4f;
    HUD.HUDView.layer.shadowRadius = 8.0f;
    HUD.textLabel.text = NSLocalizedString(@"loading", nil);
    [HUD showInView:self.view];
    [self fetchData];
    [HUD dismissAfterDelay:1];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    _coverImage.image = _expImage;

    _datePicker = [[UIPickerView alloc] init];
    _timePicker = [[UIPickerView alloc] init];
    self.guestPickerView = [[AKPickerView alloc] initWithFrame:CGRectMake(0,0,self.guestView.frame.size.width,self.guestView.frame.size.height)];

    self.guestPickerView.interitemSpacing = 20.0;
    self.guestPickerView.fisheyeFactor = 0.001;
    self.guestPickerView.pickerViewStyle = AKPickerViewStyle3D;
    self.guestPickerView.maskDisabled = false;
    
    self.guestPickerView.delegate = self;
    self.guestPickerView.dataSource = self;
    [self.guestView addSubview:self.guestPickerView];
    [self.guestPickerView reloadData];

    _datePicker.delegate = self;
    _datePicker.dataSource = self;
    _timePicker.delegate = self;
    _timePicker.dataSource = self;
    _instantTable.dataSource = self;
    _instantTable.delegate = self;
    self.dateTextField.delegate = self;
    self.timeTextField.delegate = self;
    self.dateTextField.text = NSLocalizedString(@"select_date", nil);
    self.dateTextField.tintColor = [UIColor clearColor];
    self.timeTextField.tintColor = [UIColor clearColor];
    self.timeTextField.text = NSLocalizedString(@"select_time", nil);
    [_instantTable allowsSelection];
    [_instantTable setAllowsSelection:YES];
    self.dateTextField.inputView = self.datePicker;
    self.timeTextField.inputView = self.timePicker;
    
    //Initialize guest data
    guestPickerData = [[NSMutableArray alloc]init];
    datePickerData = [[NSMutableArray alloc]init];
    timePickerData = [[NSMutableArray alloc]init];
    wholePickerData = [[NSMutableDictionary alloc]init];
    timeArray = [[NSMutableArray alloc]init];
    instantDateArray = [[NSMutableArray alloc]init];
    instantTimeArray = [[NSMutableArray alloc]init];
    
    isDateChoosed = NO;
    isTimeChoosed = NO;
    isGuestChoosed = NO;
    
    int i = [_minGuestNum intValue];
    int max = [_maxGuestNum intValue];
    for (; i<= max; i++) {
        NSNumber *currentIndexNumber = @(i);
        [guestPickerData addObject:currentIndexNumber];
    }
    
    //Resolve
    int storedFlag = 0;
    int lastIndex = 0;
    [timeArray addObject:timePickerData];
    for (int i = 0; i<availableDateArray.count; i++) {
        NSMutableDictionary *currentDic = availableDateArray[i];
        NSString *currentDateString = currentDic[@"date_string"];
        NSString *currentTimeString = currentDic[@"time_string"];
        
        if(storedFlag == 0)
        {
            [datePickerData addObject:currentDateString];
            [timeArray[0] addObject:currentTimeString];
            storedFlag = 1;
        }
        else if(datePickerData.count>0){
            if (![currentDateString isEqualToString:datePickerData[lastIndex]]) {
                [datePickerData addObject:currentDateString];
                [wholePickerData setValue:timeArray[lastIndex] forKey:datePickerData[lastIndex]];
                lastIndex ++;
                storedFlag = 1;
                NSMutableArray *newTimePickerData = [[NSMutableArray alloc]init];
                [timeArray addObject:newTimePickerData];
                [timeArray[lastIndex] addObject:currentTimeString];
            }
            else{
                [timeArray[lastIndex] addObject:currentTimeString];
            }
        }
        
        isInstant = [currentDic[@"instant_booking"] boolValue];
        if(isInstant){
            [instantDateArray addObject:currentDateString];
            [instantTimeArray addObject:currentTimeString];
        }
    }
    [wholePickerData setValue:timeArray[lastIndex] forKey:datePickerData[lastIndex]];
    dynamicTimeArray = wholePickerData[datePickerData[0]];
    
    [_timePicker selectRow:3 inComponent:0 animated:NO];
    [_datePicker selectRow:3 inComponent:0 animated:NO];

    selectedDateString = datePickerData[0];
    selectedTimeString = dynamicTimeArray[0];
    selectedGuestString = guestPickerData[0];
    
    _durationLangLabel.text = [_durationString stringByAppendingFormat:@"hrs • %@", _languageString];
    [NSString stringWithFormat:@"%@ • %@", NSLocalizedString(@"Hours", nil), _languageString];
    _expTitleLabel.text = _expTitleString;

    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    self.guestNumber = [selectedGuestString intValue];
    
    if ([_dynamicPriceArray count] == 0)
    {
        self.unitPrice = @([_fixPriceString intValue]);
    }
    else
    {
        self.unitPrice = _dynamicPriceArray[self.guestNumber - [_minGuestNum intValue]];
    }
    
    self.unitPrice = [Utility numberWithFormat:@"0" floatV:[self.unitPrice floatValue]];
    _unitPriceLabel.text = [@"$" stringByAppendingFormat:@" %@ AUD x %@ pp",[self.unitPrice stringValue],selectedGuestString];
    
    self.totalPrice =@([self.unitPrice floatValue]* self.guestNumber);
    _totalPriceLabel.text = [@"$" stringByAppendingFormat:@" %@ AUD", [self.totalPrice stringValue]];
    _totalPriceLabel.textColor = [UIColor colorWithRed:0.00f green:0.82f blue:0.82f alpha:1.0f];
    
    _confirmButton.backgroundColor = [UIColor grayColor];
    _confirmButton.enabled = NO;
    
    [self mpTrackViewCheckout];
}

- (void)fetchData
{
    NSString *post = [NSString stringWithFormat:@"{\"experience_id\":\"%@\"}",_exp_ID_string];
#if DEBUG
    NSLog(@"(Checkout)POST: %@", post);
#endif
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[URLConfig expServiceURLString]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSError *connectionError = nil;
    NSURLResponse *response = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];
    
    if (connectionError == nil) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                               options:0
                                                                 error:nil];

        if ([httpResponse statusCode] == 200) {
            NSDictionary *expData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            availableDateArray = expData[@"available_options"];
        } else {
            NSString *errorMsg = result[@"Server Error"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"server_error", nil)
                                                            message:errorMsg
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"ok_button", nil)
                                                  otherButtonTitles:nil];
            [alert show];
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"no_network", nil)
                                                        message:NSLocalizedString(@"no_network_msg", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"ok_button", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark - Picker View
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    if ([pickerView isEqual:_datePicker]) {
        return datePickerData.count;
    }
    
    if ([pickerView isEqual:_timePicker]) {
        return dynamicTimeArray.count;
    }
    
    return 0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if ([pickerView isEqual:_datePicker]) {
        return datePickerData[row];
    }
    
    if ([pickerView isEqual:_timePicker]) {
        return dynamicTimeArray[row];
    }
    
    return nil;
}

#pragma mark - AKPicker
- (NSString *)pickerView:(AKPickerView *)pickerView titleForItem:(NSInteger)item
{
    return [guestPickerData[item] stringValue];
}

- (NSUInteger)numberOfItemsInPickerView:(AKPickerView *)pickerView
{
    return [guestPickerData count];
}

- (void)mpTrackNumberOfPeople
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults secretStringForKey:@"user_token"];
    
    if (token) {
        NSString * userEmail = [userDefaults stringForKey:@"user_email"];
        [mixpanel identify:userEmail];
        [mixpanel.people set:@{}];
    }
    
    [mixpanel track:mpTrackNumberOfPeople properties:@{@"language":language}];
}

- (void)pickerView:(AKPickerView *)pickerView didSelectItem:(NSInteger)item
{
    selectedGuestString = guestPickerData[item];

    [self mpTrackNumberOfPeople];

    self.guestNumber = [selectedGuestString intValue];
    if ([_dynamicPriceArray count] == 0)
    {
        self.unitPrice = @([_fixPriceString intValue]);
    }
    else
    {
        self.unitPrice = _dynamicPriceArray[self.guestNumber - [_minGuestNum intValue]];
    }
    
    self.unitPrice = [Utility numberWithFormat:@"0" floatV:[self.unitPrice floatValue]];
    
    _unitPriceLabel.text = [@"$" stringByAppendingFormat:@" %@ AUD x %@ pp", [self.unitPrice stringValue], selectedGuestString];
    
    self.totalPrice =@([self.unitPrice floatValue] * self.guestNumber);
    _totalPriceLabel.text = [@"$" stringByAppendingFormat:@" %@ AUD", [self.totalPrice stringValue]];
    
    isGuestChoosed = YES;
    if([self checkChoosed]==YES){
        _confirmButton.backgroundColor = [UIColor colorWithRed:71/255.0 green:209/255.0 blue:209/255.0 alpha:1];
        _confirmButton.enabled = YES;
    }
}

#pragma mark - Picker Value
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if ([pickerView isEqual:_datePicker]) {
        dynamicTimeArray = wholePickerData[datePickerData[row]];
        [_timePicker selectRow:3 inComponent:0 animated:YES];
        [_timePicker reloadAllComponents];
        selectedDateString = datePickerData[row];
        isDateChoosed = YES;
        self.dateTextField.text = selectedDateString;
        self.timeTextField.text = NSLocalizedString(@"select_time", nil);
        isTimeChoosed = NO;
        if([self checkChoosed]==YES){
            _confirmButton.backgroundColor = [UIColor colorWithRed:71/255.0 green:209/255.0 blue:209/255.0 alpha:1];
            _confirmButton.enabled = YES;
        } else {
            _confirmButton.backgroundColor = [UIColor grayColor];
            _confirmButton.enabled = NO;
        }
        [self.dateTextField resignFirstResponder];
    }
    if ([pickerView isEqual:_timePicker]) {
        selectedTimeString = dynamicTimeArray[row];
        isTimeChoosed = YES;
        if([self checkChoosed]==YES){
            _confirmButton.backgroundColor = [UIColor colorWithRed:71/255.0 green:209/255.0 blue:209/255.0 alpha:1];
            _confirmButton.enabled = YES;
        }
        self.timeTextField.text = selectedTimeString;
        [self.timeTextField resignFirstResponder];
    }
    
#ifdef DEBUG
    NSLog(@"Selected Date:%@ Time:%@ Guest:%@",selectedDateString,selectedTimeString,selectedGuestString);
#endif
}

- (BOOL)checkChoosed{
    if(isDateChoosed == NO ){
        return NO;
    }
    if(isTimeChoosed == NO){
        return NO;
    }
    if(isGuestChoosed == NO){
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(instantTimeArray.count == 0)
    {
        _tableVisibleConstrain.constant = 0;
        _instantTable.hidden = YES;
    }
    return instantTimeArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"instantCell";
    InstantBookingTableViewCell *cell = (InstantBookingTableViewCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];;
    if(!cell){
        cell=[[InstantBookingTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if(instantTimeArray.count == 0){
        cell.tempView.hidden = YES;
        cell.instantDateLabel.text = @"No instant booking available";
        cell.instantTimeLabel.text = @"";
    }
    else{
        cell.tempView.hidden = NO;
        cell.instantDateLabel.text = instantDateArray[indexPath.row];
        cell.instantTimeLabel.text = instantTimeArray[indexPath.row];
//        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.tempImage.image = [UIImage imageNamed:@"flash.png"];
    }
    
    return cell;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"showPaymentOption"]){
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        PaymentOptionViewController *controller = (PaymentOptionViewController *)navController.topViewController;
        
        controller.coupon = self.couponField.text;
        controller.expId = _exp_ID_string ;
        controller.guestNumber = self.guestNumber;
        controller.hostName = self.hostName;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"dd/MM/yyyy";
        
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        timeFormatter.dateFormat = @"HH:mm";
        
        NSDate *date = [dateFormatter dateFromString:selectedDateString];
        NSDate *startTime = [timeFormatter dateFromString:selectedTimeString];
        NSTimeInterval secondsIntHours = [self.durationString integerValue] * 60 * 60;
        NSDate *endTime = [startTime dateByAddingTimeInterval: secondsIntHours];
        NSString *endTimeString = [timeFormatter stringFromDate:endTime];

        // output format
        dateFormatter.dateFormat = @"yyyy/MM/dd";
        
        controller.date = [dateFormatter stringFromDate:date];
        controller.timePeriod = [NSString stringWithFormat:@"%@-%@", selectedTimeString, endTimeString];

        controller.unitPrice = self.unitPrice;
        controller.totalPrice = self.totalPrice;
    }
}


@end
