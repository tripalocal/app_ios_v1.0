//
//  PaymentOptionViewController.m
//  TripalocalBeta
//
//  Created by Ye He on 4/07/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//

#import "PaymentOptionViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "DataSigner.h"
#import "DataVerifier.h"

@interface PaymentOptionViewController ()

@end

@implementation PaymentOptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark -
#pragma mark   ==============产生随机订单号==============


- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand(time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *partner = @"2088911571600817";
    NSString *seller = @"jemma@tripalocal.com";
    NSString *privateKey = @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAMo40P7Z3K/zsFF5QuWXBkjfeqc8lUYbhNIpQhqiB4x2H8mlR8nNcGhQVNYLzPa8hbf33uZPyWawd8f3rdeWRF07Rw87ubdm2sK9RK23LpcPwbbt42Vgp3Y/XaWag8hFcgaUMtdyAAqrS0s0uq/JFWaGKytIzO6jKT1i8mNNzTtPAgMBAAECgYBp8QYc3couK/6tUFfprAtQ1jONtcGGbxhQeej1xvkpbyEMJRjM8mH3ZE5trNT+Vpm/XY5bHmWm9MBr9KgQj9rUBceyJI2y4TRM629/21b9/V/vAqimiaXOpu+y2jAqHEhylb7idNPHElJNbpMaw59yC9CGMhb6UFLxJLrSOdm0AQJBAPiyrcBxsTuS+eFm8k8NaanhWm4+a/HCocV4W+2yfi3HY1WcgnD2UvHNE1U4w4pYQXmPQ7+XSuzB4cu1K6uoRQECQQDQKM3F52GqFglAlLYuYfn2bBZFo1M31cBal5D4xfvQdLzv3nYkMxIAyycet4XOjUOBeQJu6Qv4Ru1rwUnpL/BPAkBOObWZYKmEuZhLo9v3rZpcyvtszcmaQ8Qqns8blxdFQwAlv5LwASrZz82S8sXe0B/YIo4Gx4nTqrBhKN1Rox4BAkEAhLO+mw/rHzd1JoqnqeIkLIizmimI/+tw+U/ux+nPoxEI8hJsVp+INqFMizSMRSWhh4TRnEtNqjXtXeiXaeV52QJAO1h0ba2xzyZJs93T/qdNhuWSs8QPUu6AntnJawxoMxXtJq5rHX+6puBsdnaJ9hQISZ3JEYaNWUlQqRe5iZmk8g==";
    
    if ([partner length] == 0 || [seller length] == 0 || [privateKey length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hint"
                                                        message:@"Need partner or seller or private key。"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        /*
         *生成订单信息及签名
         */
        //将商品信息赋予AlixPayOrder的成员变量
        Order *order = [[Order alloc] init];
        order.partner = partner;
        order.seller = seller;
        order.tradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
        order.productName = @"TripaLocal Experience"; //商品标题
        order.productDescription = @"Experience in au"; //商品描述
        
        //商品价格
        order.amount = [NSString stringWithFormat:@"%.2f",self.totalPrice.floatValue];
        
        order.notifyURL =  @"http://notify.msp.hk/notify.htm";
        order.service = @"mobile.securitypay.pay";
        order.paymentType = @"1";
        order.inputCharset = @"utf-8";
        order.itBPay = @"30m";
        order.showUrl = @"m.alipay.com";
        
        //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
        NSString *appScheme = @"alisdkdemo";
        
        NSString *orderSpec = [order description];

#ifdef DEBUG
        NSLog(@"Order Spec = %@",orderSpec);
#endif
        
        //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
        id<DataSigner> signer = CreateRSADataSigner(privateKey);
        NSString *signedString = [signer signString:orderSpec];
        
        //将签名成功字符串格式化为订单字符串,请严格按照该格式
        NSString *orderString = nil;
        if (signedString != nil) {
            orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                           orderSpec, signedString, @"RSA"];
            
            [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                NSLog(@"reslut = %@",resultDic);
            }];
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"payByCreditCard"]){
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        PaymentViewController *controller = (PaymentViewController *)navController.topViewController;
        
        controller.expId = self.expId;
        controller.guestNumber = self.guestNumber;
        controller.date = self.date;
        controller.timePeriod = self.timePeriod;
        controller.unitPrice = self.unitPrice;
    }
}

@end