//
//  Friend.h
//  TestIM4
//
//  Created by Apple on 15/12/10.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import <Foundation/Foundation.h>

/*好友模型*/

typedef enum{
    None,
    Weixin,
    PhoneNumber,
    All
}ChangeState;

@interface Friend : NSObject

/*好友用户名*/
@property (nonatomic, strong) NSString *userName;
/*联系方式交换状态*/
@property (nonatomic, assign) ChangeState changeState;
/*好友微信*/
@property (nonatomic, strong) NSString *weChat;
/*好友手机号*/
@property (nonatomic, strong) NSString *phoneNumber;
/*data格式的头像*/
@property (nonatomic, strong) NSData *data;
/*上次请求交换微信的时间*/
@property (nonatomic, strong) NSString *changeWechatTime;
/*上次请求交换手机的时间*/
@property (nonatomic, strong) NSString *changePhoneNumberTime;

@end
