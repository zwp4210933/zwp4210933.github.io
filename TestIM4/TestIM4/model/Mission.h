//
//  Mission.h
//  TestIM4
//
//  Created by Apple on 16/1/9.
//  Copyright © 2016年 lanjue. All rights reserved.
//

#import <Foundation/Foundation.h>
/*任务数据模型*/

@interface Mission : NSObject

@property (nonatomic, strong) NSString *headerImageName;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *publicer;
@property (nonatomic, strong) NSString *salary;
@property (nonatomic, strong) NSString *place;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *genger;
@property (nonatomic, strong) NSString *style;
@property (nonatomic, strong) NSString *missionPlace;
@property (nonatomic, strong) NSString *missionType;

@end
