//
//  ChatViewController.h
//  TestIM4
//
//  Created by Apple on 15/11/25.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chat.h"
#import "Friend.h"

/*聊天界面*/

@interface ChatViewController : UIViewController

/*会话模型*/
@property (nonatomic, strong) Friend *friend;
/*外部未读消息数量*/
@property (nonatomic, assign) NSInteger noticeCount;

@end
