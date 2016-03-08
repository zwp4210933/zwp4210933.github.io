//
//  XMPPManager.h
//  TestIM4
//
//  Created by Apple on 15/11/23.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPP.h"
#import "XMPPRoster.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPReconnect.h"
#import "Const.h"

@interface XMPPManager : NSObject



@property (nonatomic, strong) XMPPStream *xmppStream;

//获取单例
+(XMPPManager *)shareManager;
//连接服务器
-(void)xmppConnectWithUserName:(NSString *)userName;
//登录
-(void)xmppAuthenticateWithPassword:(NSString *)password;
//注册
-(void)xmppRegisterWithPassword:(NSString *)password;
//激活花名册并获取好友
-(void)xmppRosterSetUpWithDelegate:(id)delegate delegateQueue:(dispatch_queue_t)dispach;
//登出
-(void)xmppDisConnect;
//上线
-(void)xmppAvailable;
//下线
-(void)xmppUnavailable;
//自动重连
-(void)xmppAutoReconnect;
//测试自身在线状态
-(BOOL)xmppIsAvailable;
//发送文本消息
-(void)xmppSendTextMessageWithText:(NSString *)text receiveName:(NSString *)name;
//发送请求消息
-(void)xmppSendRequestType:(RequestType)type receiveName:(NSString *)name;
//发送回复消息
-(void)xmppReplyRequest:(BOOL)agree receiveName:(NSString *)name requestType:(RequestType)type;
//发送图片消息
-(void)xmppSendLargeImage:(NSString *)lImgUrl smallImage:(NSString *)sImgUrl imageSize:(CGSize)size receiveName:(NSString *)name;
//发送语音消息
-(void)xmppSendAudio:(NSString *)audioUrl audioLength:(CGFloat)audioLength receiveName:(NSString *)name;

@end
