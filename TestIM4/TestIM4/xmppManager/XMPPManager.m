//
//  XMPPManager.m
//  TestIM4
//
//  Created by Apple on 15/11/23.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import "XMPPManager.h"
#import "AppDelegate.h"

#define MY_DOMAIN @("app.gafaer.com")

@interface XMPPManager()

@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *rosterCoreDataStorage;
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;

@end


@implementation XMPPManager

+(XMPPManager *)shareManager{
    static XMPPManager *xmppManager = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        xmppManager = [[XMPPManager alloc] init];
    });
    return xmppManager;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        self.xmppStream = [[XMPPStream alloc] init];
    }
    return self;
}

-(void)xmppConnectWithUserName:(NSString *)userName
{
    //1.创建JID
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:MY_DOMAIN resource:@"iPhone"];
    //2.把JID添加到xmppSteam中
    [self.xmppStream setMyJID:jid];
    self.xmppStream.hostName = @"114.215.240.173";
    self.xmppStream.hostPort = 5222;
    //连接服务器
    NSError *error = nil;
    [self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        NSLog(@"连接出错：%@",[error localizedDescription]);
        [self.xmppStream disconnect];
    }
}

//登录实现
-(void)xmppAuthenticateWithPassword:(NSString *)password{
    NSError *error = nil;
    [self.xmppStream authenticateWithPassword:password error:&error];
    if (error) {
        NSLog(@"认证错误%@",[error localizedDescription]);
        [self.xmppStream disconnect];
    }

}
//登出实现
-(void)xmppDisConnect{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [self.xmppStream sendElement:presence];
    [self.xmppStream disconnect];
}

//下线实现
-(void)xmppUnavailable{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [self.xmppStream sendElement:presence];
}

//注册实现
-(void)xmppRegisterWithPassword:(NSString *)password{
    NSError *error = nil;
    [self.xmppStream registerWithPassword:password error:&error];
    if (error) {
        NSLog(@"注册错误%@",[error localizedDescription]);
        [self.xmppStream disconnect];
    }
}

//上线实现
-(void)xmppAvailable{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [self.xmppStream sendElement:presence];
}

//激活花名册并获取好友实现
-(void)xmppRosterSetUpWithDelegate:(id)delegate delegateQueue:(dispatch_queue_t)dispach{
    self.rosterCoreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
    
    //初始化xmppRoster
    self.xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:self.rosterCoreDataStorage];
    //激活
    [self.xmppRoster activate:self.xmppStream];
    //设置代理
    [self.xmppRoster addDelegate:delegate delegateQueue:dispach];
    [self.xmppRoster fetchRoster];
}

//发送文本消息
-(void)xmppSendTextMessageWithText:(NSString *)text receiveName:(NSString *)name{
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:name domain:MY_DOMAIN resource:@"iPhone"]];
    //text 纯文本
    [msg addAttributeWithName:@"bodyType" stringValue:@"text"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [msg addAttributeWithName:@"sendTime" stringValue:strDate];
    
    // 设置内容
    [msg addBody:text];
    NSLog(@"%@",msg);
    [self.xmppStream sendElement:msg];
}

//发送请求消息
-(void)xmppSendRequestType:(RequestType)type receiveName:(NSString *)name{
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:name domain:MY_DOMAIN resource:@"iPhone"]];
    //请求
    [msg addAttributeWithName:@"bodyType" stringValue:@"request"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [msg addAttributeWithName:@"sendTime" stringValue:strDate];

    if(type == Phone){
        [msg addBody:@"手机"];
        [msg addAttributeWithName:@"requestType" stringValue:@"phone"];
    }else{
        [msg addBody:@"微信"];
        [msg addAttributeWithName:@"requestType" stringValue:@"weChat"];
    }
    NSLog(@"%@",msg);
    [self.xmppStream sendElement:msg];
}

//发送回复消息
-(void)xmppReplyRequest:(BOOL)agree receiveName:(NSString *)name requestType:(RequestType)type{
    
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:name domain:MY_DOMAIN resource:@"iPhone"]];
    //回复请求
    [msg addAttributeWithName:@"bodyType" stringValue:@"reply"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [msg addAttributeWithName:@"sendTime" stringValue:strDate];
    
    if (type == WeChat) {
        [msg addAttributeWithName:@"requestType" stringValue:@"weChat"];
    }else{
        [msg addAttributeWithName:@"requestType" stringValue:@"phone"];
    }
    if (agree) {
        [msg addAttributeWithName:@"agree" boolValue:YES];
    }else{
        [msg addAttributeWithName:@"agree" boolValue:NO];
    }
    
    
    NSLog(@"%@",msg);
    [self.xmppStream sendElement:msg];
}

//发送图片消息
-(void)xmppSendLargeImage:(NSString *)lImgUrl smallImage:(NSString *)sImgUrl imageSize:(CGSize)size receiveName:(NSString *)name{
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:name domain:MY_DOMAIN resource:@"iPhone"]];
    //设置类型为图片
    [msg addAttributeWithName:@"bodyType" stringValue:@"image"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [msg addAttributeWithName:@"sendTime" stringValue:strDate];
    [msg addAttributeWithName:@"sImage" stringValue:sImgUrl];
    [msg addAttributeWithName:@"imageWidth" floatValue:size.width];
    [msg addAttributeWithName:@"imageHeight" floatValue:size.height];
    [msg addBody:lImgUrl];
    
    
    NSLog(@"%@",msg);
    [self.xmppStream sendElement:msg];

}

//发送语音消息
-(void)xmppSendAudio:(NSString *)audioUrl audioLength:(CGFloat)audioLength receiveName:(NSString *)name{
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithUser:name domain:MY_DOMAIN resource:@"iPhone"]];
    //设置类型为语音
    [msg addAttributeWithName:@"bodyType" stringValue:@"audio"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    [msg addAttributeWithName:@"sendTime" stringValue:strDate];
    [msg addAttributeWithName:@"audioLength" floatValue:audioLength];
    [msg addBody:audioUrl];
    NSLog(@"%@",msg);
    [self.xmppStream sendElement:msg];

}

//自动重连实现
-(void)xmppAutoReconnect{
    self.xmppReconnect = [[XMPPReconnect alloc] init];
    [self.xmppReconnect activate:self.xmppStream];
}

//测试自身在线状态
-(BOOL)xmppIsAvailable{
    NSString *type = self.xmppStream.myPresence.type;
    if ([type isEqualToString:@"available"]) {
        return YES;
    }
    return NO;
}

@end
