//
//  Designer.h
//  TestIM4
//
//  Created by Apple on 15/12/31.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import <Foundation/Foundation.h>
/*设计师数据模型*/


@interface Designer : NSObject


@property (nonatomic, strong) NSString *headerImageName;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *occupation;
@property (nonatomic, strong) NSString *salary;
@property (nonatomic, strong) NSString *place;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *genger;
@property (nonatomic, strong) NSArray *styleArray;
@property (nonatomic, strong) NSArray *characterArray;

@end
