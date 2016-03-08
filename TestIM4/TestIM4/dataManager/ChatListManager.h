//
//  ChatListManager.h
//  TestIM4
//
//  Created by Apple on 15/11/27.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Chat.h"

/*
 会话记录数据库
*/

@interface ChatListManager : NSObject

//增加会话
-(void)addDataWithChatModel:(Chat *)model;
//删除会话
-(void)removeDataWithUserName:(NSString *)userName;
//提取全部会话（置顶会话置顶）
-(NSArray *)selectedAllChatModel;
//查询会话置顶情况
-(BOOL)chatIsTopWithUserName:(NSString *)userName;
//置顶会话
-(void)makeTop:(BOOL)top UserName:(NSString *)userName;

@end
