//
//  TextMessage.h
//  TestIM4
//
//  Created by Apple on 15/11/26.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Const.h"

/*消息模型*/

typedef enum{
    To,
    From
}Direction;

typedef enum{
    Text,
    Request,
    Reply,
    Image,
    Redio
}MessageType;


@interface TextMessage : NSObject

/*内容*/
@property (nonatomic, strong) NSString *text;
/*时间*/
@property (nonatomic, strong) NSString *time;
/*消息方向*/
@property (nonatomic, assign) Direction direction;
/*消息类型*/
@property (nonatomic, assign) MessageType type;
/*阅读状态*/
@property (nonatomic, assign) BOOL readed;
/*请求类型，只有回复消息和请求消息需要设置此值*/
@property (nonatomic, assign) RequestType requestType;
/*恢复状态，只有请求消息需要设置此值*/
@property (nonatomic, assign) BOOL replyed;
/*图片尺寸，只有图片消息需要设置此值*/
@property (nonatomic, assign) CGSize imageSize;
/*小图文件名,只有收到的图片消息需要设置此值*/
@property (nonatomic, strong) NSString *sImgName;
/*语音长度，只有语音消息需要设置此值*/
@property (nonatomic, assign) CGFloat voiceLength;
/*语音播放状态，只有语音消息需要设置此值*/
@property (nonatomic, assign) BOOL played;


@end
