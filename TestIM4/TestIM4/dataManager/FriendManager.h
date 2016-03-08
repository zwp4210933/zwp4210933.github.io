//
//  FriendManager.h
//  TestIM4
//
//  Created by Apple on 15/12/10.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Friend.h"

/*好友数据库*/

@interface FriendManager : NSObject


//增加好友
-(void)addDataWithFriendModel:(Friend *)model;
//查询好友联系方式交换状态
-(int)changeStateWithUserName:(NSString *)userName;
//通过用户名查询好友
-(Friend *)friendWithUserName:(NSString *)userName;
//修改联系方式交换状态
-(void)updateFriend:(NSString *)username WithChangeState:(ChangeState)state;
//设置微信请求时间
-(void)updateFriend:(NSString *)username WithWechatTime:(NSString *)time;
//设置手机请求时间
-(void)updateFriend:(NSString *)username WithPhoneNumberTime:(NSString *) time;
@end
