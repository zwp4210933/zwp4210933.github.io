//
//  TextCell.h
//  TestIM4
//
//  Created by Apple on 15/11/26.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextMessage.h"


/*该Cell用于聊天界面，用于显示文本（包括表情）类型的消息，包含元素：
 1.头像（自身或者好友的）
 2.背景气泡框
 3.显示消息文本的Label
 4.时间Label
*/

@interface TextCell : UITableViewCell

/*消息模型*/
@property (nonatomic, strong)TextMessage *message;

@end
