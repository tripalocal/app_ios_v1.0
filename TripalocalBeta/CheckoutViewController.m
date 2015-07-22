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
#import "JGProgressHUD.h"

@interface CheckoutViewController (){
    NSMutableArray *guestPickerData;
    NSMutableArray *datePickerData;
    NSMutableArray *timePickerData;
    NSMutableDictionary *wholePickerData;
    NSMutableArray *dynamicTimeArray;
    NSMutableArray *timeArray;
    NSMutableArray *instantDateArray;
    NSMutableArray *instantTimeArray;
    BOOL isInstant;
    NSString *selectedTimeString;
    NSString *selectedDateString;
    NSString *selectedGuestString;
    BOOL isDateChoosed;
    BOOL isTimeChoosed;
    BOOL isGuestChoosed;
}

@end

@implementation CheckoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    _coverImage.image = _expImage;

    _datePicker = [[UIPickerView alloc] init];
    _timePicker = [[UIPickerView alloc] init];
    self.guestPickerView = [[AKPickerView alloc] initWithFrame:CGRectMake(0,0,self.guestView.frame.size.width,self.guestView.frame.size.height)];
//    [self.guestView removeFromSuperview];

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
        NSNumber *currentIndexNumber = [NSNumber numberWithInt:i];
        [guestPickerData addObject:currentIndexNumber];
    }
    
    //Resolve
    int storedFlag = 0;
    int lastIndex = 0;
    [timeArray addObject:timePickerData];
    for (int i = 0; i<_availbleDateArray.count; i++) {
        NSMutableDictionary *currentDic = [_availbleDateArray objectAtIndex:i];
        NSString *currentDateString = [currentDic objectForKey:@"date_string"];
        NSString *currentTimeString = [currentDic objectForKey:@"time_string"];
        
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
        
        isInstant = [[currentDic objectForKey:@"instant_booking"]boolValue];
        if(isInstant){
            [instantDateArray addObject:currentDateString];
            [instantTimeArray addObject:currentTimeString];
        }
    }
    [wholePickerData setValue:timeArray[lastIndex] forKey:datePickerData[lastIndex]];
    dynamicTimeArray = [wholePickerData objectForKey:[datePickerData objectAtIndex:0]];
    
    [_timePicker selectRow:3 inComponent:0 animated:NO];
    [_datePicker selectRow:3 inComponent:0 animated:NO];

    selectedDateString = datePickerData[0];
    selectedTimeString = dynamicTimeArray[0];
    selectedGuestString = guestPickerData[0];
    
    _durationLangLabel.text = [_durationString stringByAppendingFormat:@"hrs • %@", _languageString];
    [NSString stringWithFormat:@"%@ • %@", NSLocalizedString(@"Hours", nil), _languageString];
    _expTitleLabel.text = _expTitleString;
    // todo: default value not equal to picker view
    _unitPriceLabel.text = [@"$" stringByAppendingFormat:@" %@ AUD x %@ pp",_fixPriceString,selectedGuestString];
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    self.unitPrice = [f numberFromString:_fixPriceString];
    self.guestNumber = [selectedGuestString intValue];
    self.totalPrice =@([self.unitPrice floatValue]* self.guestNumber);
    _totalPriceLabel.text = [@"$" stringByAppendingFormat:@" %@ AUD",[self.totalPrice stringValue]];
    _totalPriceLabel.textColor = [UIColor colorWithRed:0.00f green:0.82f blue:0.82f alpha:1.0f];
    
    _confirmButton.backgroundColor = [UIColor grayColor];
    _confirmButton.enabled = NO;
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

- (void)pickerView:(AKPickerView *)pickerView didSelectItem:(NSInteger)item
{
    selectedGuestString = guestPickerData[item];
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    self.unitPrice = [f numberFromString:_fixPriceString];
    
    self.guestNumber = [selectedGuestString intValue];
    self.totalPrice =@([self.unitPrice floatValue] * self.guestNumber);
    
    self.unitPriceLabel.text = [@"$" stringByAppendingFormat:@" %@ AUD x %@ pp",_fixPriceString, selectedGuestString];
    
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.##"];
    self.totalPriceLabel.text = [@"$" stringByAppendingFormat:@" %@ AUD", [fmt stringFromNumber: self.totalPrice]];
    isGuestChoosed = YES;
    if([self checkChoosed]==YES){
        _confirmButton.backgroundColor = [UIColor colorWithRed:71/255.0 green:209/255.0 blue:209/255.0 alpha:1];
        _confirmButton.enabled = YES;
    }
}

#pragma mark - Picker Value
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    if ([pickerView isEqual:_datePicker]) {
        dynamicTimeArray = [wholePickerData objectForKey:[datePickerData objectAtIndex:row]];
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
        cell.instantDateLabel.text = [instantDateArray objectAtIndex:indexPath.row];
        cell.instantTimeLabel.text = [instantTimeArray objectAtIndex:indexPath.row];
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
