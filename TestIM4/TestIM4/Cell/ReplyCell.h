//
//  ReplyCell.h
//  TestIM4
//
//  Created by Apple on 15/11/30.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextMessage.h"

/*该Cell用于聊天界面，用于显示回复请求类型的消息，包含元素：
 1.显示回复消息的Label
 2.时间Label
 3.背景图片
*/

@protocol ReplyCellDelegete <NSObject>

-(void)takeConnectionWay:(NSString *)connectText requestType:(RequestType)type;

@end

@interface ReplyCell : UITableViewCell

/*消息模型*/
@property (nonatomic, strong) TextMessage *message;
@property (nonatomic, weak) id<ReplyCellDelegete> delegate;

@end
