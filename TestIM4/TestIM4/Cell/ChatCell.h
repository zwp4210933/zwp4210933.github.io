//
//  ChatCell.h
//  TestIM4
//
//  Created by Apple on 15/11/27.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chat.h"


/*
 该Cell用于会话列表元素包括：
 1.好友头像
 2.好友昵称
 3.好友会话的最后一条消息
 4.置顶图标
*/

@interface ChatCell : UITableViewCell

/*会话中的未读消息数量*/
@property (nonatomic, assign)NSInteger notReadedCount;
@property (nonatomic, strong) UILabel *numberLabel;

/*根据模型显示数据*/
-(void)configWithChat:(Chat *)model;


@end
