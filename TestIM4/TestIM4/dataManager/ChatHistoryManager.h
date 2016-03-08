//
//  ChatHistoryManager.h
//  TestIM4
//
//  Created by Apple on 15/11/27.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextMessage.h"

/*
 历史消息数据库
 */

@interface ChatHistoryManager : NSObject

//好友用户名，必须设置此参数，不然无法正确创建数据库
@property (nonatomic, strong) NSString *friendName;

//增加消息条
-(void)addDataWithTextMessage:(TextMessage *)model;
//获取全部消息记录
-(NSArray *)selectedAllMessage;
//获取最后一条消息
-(NSString *)selectedLastMessage;
//获取最后一条消息的发送时间
-(NSString *)selectedLastMessageTime;
//修改所有信息的阅读状态为已读
-(void)updateAllMessageReaded;
//删除消息
-(void)deleteMessageWithText:(NSString *)text Type:(MessageType)type;
//设置语音消息为已播放
-(void)updateRedioMessagePlayedWithFileName:(NSString *)fileName;
//设置请求消息为已回复
-(void)updateRequestMessageReplyedWithRequset:(RequestType)type;
//获取所有图片消息
-(NSArray *)selectedAllImageMessage;
//修改图片消息的内容
-(void)updateImageMessageOldName:(NSString *)oldName newName:(NSString *)newName;
@end
