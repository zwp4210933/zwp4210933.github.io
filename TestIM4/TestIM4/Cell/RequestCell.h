//
//  RequestCell.h
//  TestIM4
//
//  Created by Apple on 15/11/30.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextMessage.h"

/*该Cell用于聊天界面，用于显示请求类型的消息，包含元素：
 1.显示请求的Label
 2.回复请求的按钮
 3.时间Label
*/

//用于实现按钮点击事件的代理方法
@protocol RequestCellDelegate <NSObject>

-(void)replyRequset:(BOOL)agree requestType:(RequestType)type;

@end

@interface RequestCell : UITableViewCell

//消息模型
@property (nonatomic, strong) TextMessage *message;
//代理
@property (nonatomic, weak) id<RequestCellDelegate> delegate;

@end
