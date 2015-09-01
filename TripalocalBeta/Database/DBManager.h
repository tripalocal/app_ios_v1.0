//
//  DBManager.h
//  TripalocalBeta
//
//  Created by 嵩薛 on 27/08/2015.
//  Copyright (c) 2015 Tripalocal. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface DBManager : NSObject

-(instancetype)initWithDatabaseFileName: (NSString *)dbFileName;

@property (nonatomic, strong) NSMutableArray *arrColumnNames;
@property (nonatomic) int affectedRows;
@property (nonatomic) long long lastInsertedRowID;

-(NSArray *)loadDataFromDB:(NSString *)query;

-(void)executeQuery:(NSString *)query;

@end