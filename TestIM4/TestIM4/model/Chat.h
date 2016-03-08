//
//  Chat.h
//  TestIM4
//
//  Created by Apple on 15/11/27.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import <Foundation/Foundation.h>

/*会话模型*/

@interface Chat : NSObject

/*判断是否为置顶对话*/
@property (nonatomic, assign) BOOL isTop;
/*会话对象名*/
@property (nonatomic, strong) NSString *userName;
/*data格式的头像*/
@property (nonatomic, strong) NSData *data;

@end
