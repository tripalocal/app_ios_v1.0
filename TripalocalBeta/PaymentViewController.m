//
//  PaymentViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 29/06/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "PaymentViewController.h"
#import "Constant.h"

@interface PaymentViewController ()
@property (strong, nonatomic) IBOutlet UITextField *cardNumberField;
@property (strong, nonatomic) IBOutlet UITextField *ccvField;
@property (strong, nonatomic) IBOutlet UITextField *monthField;
@property (strong, nonatomic) IBOutlet UITextField *yearField;
@property (strong, nonatomic) IBOutlet UIButton *confirmButton;
@property (strong, nonatomic) IBOutlet UILabel *totalPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *unitPriceLabel;
@property (strong, nonatomic) IBOutlet UILabel *guestNumberLabel;

@end

@implementation PaymentViewController
- (IBAction)inputFiledChanged:(id)sender {
    if (self.cardNumberField.text && self.monthField.text && self.yearField && self.ccvField && self.cardNumberField.text.length > 0 && self.monthField.text.length > 0 && self.yearField.text.length > 0 && self.ccvField.text.length > 0) {
        [self.confirmButton setEnabled:YES];
        self.confirmButton.alpha = 1;
    } else {
        [self.confirmButton setEnabled:NO];
        self.confirmButton.alpha = 0.5;
    }
}

- (void)postPaymentInfo {
    [self.confirmButton setEnabled:NO];
    NSDictionary *expInfo = @{@"date" : self.date,
            @"guest_number" : @(self.guestNumber),
            @"id" : self.expId,
            @"time" : self.timePeriod};
    if ([self.coupon length] == 0) {
        self.coupon = @"";
    }

    NSDictionary *tmp = @{@"card_number" : self.cardNumberField.text,
            @"coupon" : self.coupon,
            @"cvv" : @(self.ccvField.text.intValue),
            @"expiration_month" : @(self.monthField.text.intValue),
            @"expiration_year" : @(self.yearField.text.intValue),
            @"itinerary_string" : @[expInfo]};

    NSData *postdata = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:nil];

    NSString *jsonString = [[NSString alloc] initWithData:postdata encoding:NSUTF8StringEncoding];
    // This will be the json string in the preferred format
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\/" withString:@"/"];

    // And this will be the json data object
    NSData *processedData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];

#if DEBUG
    NSLog(@"Sending payment request = %@", jsonString);
#endif

    NSURL *url = [NSURL URLWithString:NSLocalizedString(paymentServiceURL, nil)];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *token = [userDefaults stringForKey:@"user_token"];

    [request addValue:[NSString stringWithFormat:@"Token %@", token] forHTTPHeaderField:@"Authorization"];

    [request setHTTPBody:processedData];

    NSError *connectionError = nil;
    NSURLResponse *response = nil;

    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&connectionError];

    if (connectionError == nil) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;

        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                               options:0
                                                                 error:nil];

        if ([httpResponse statusCode] == 200) {
            [self performSegueWithIdentifier:@"paymentSuccess" sender:nil];
        } else {
            NSString *errorMsg = result[@"error"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Payment Failed"
                                                            message:errorMsg
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }

#if DEBUG
        NSString *decodedData = [[NSString alloc] initWithData:data
                                                      encoding:NSUTF8StringEncoding];
        NSLog(@"Receiving data = %@", decodedData);
#endif
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                        message:@"You must be connected to the internet."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }


    [self.confirmButton setEnabled:YES];

}

- (IBAction)confirmAndPay:(id)sender {
    [self postPaymentInfo];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.confirmButton setEnabled:NO];
    self.confirmButton.alpha = 0.5;
    self.cardNumberField.delegate = self;
    self.monthField.delegate = self;
    self.yearField.delegate = self;
    self.ccvField.delegate = self;

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];

    [self.view addGestureRecognizer:tap];

    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.##"];
    self.unitPriceLabel.text = [fmt stringFromNumber: self.unitPrice];
    self.guestNumberLabel.text = [NSString stringWithFormat:@"%lu", self.guestNumber];
    self.totalPriceLabel.text = [@"$" stringByAppendingFormat:@" %@ AUD", [fmt stringFromNumber: self.totalPrice]];
    self.totalPriceLabel.textColor = [UIColor colorWithRed:0.00f green:0.82f blue:0.82f alpha:1.0f];

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger maxLength = 1;

    if (textField == self.cardNumberField) {
        maxLength = 16;
    } else if (textField == self.monthField) {
        maxLength = 2;
    } else if (textField == self.yearField) {
        maxLength = 4;
    } else if (textField == self.ccvField) {
        maxLength = 3;
    }

    if (range.length + range.location > textField.text.length) {
        return NO;
    }

    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= maxLength;
}


@end
