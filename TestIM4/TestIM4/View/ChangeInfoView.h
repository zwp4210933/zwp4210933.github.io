//
//  ChangeInfoView.h
//  TestIM4
//
//  Created by Apple on 15/12/31.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"

/*这个视图是顶部交换联系方式视图*/

typedef void(^changeContack)(RequestType type);

@interface ChangeInfoView : UIView

@property (nonatomic, strong) Friend *friend;
-(instancetype)initWithFrame:(CGRect)frame FriendName:(Friend *)friend ChangeBlock:(changeContack)changeBlock;

//被拒绝之后的UI改变
-(void)refusedWithRequestType:(RequestType)type;
//同意之后的UI改变
-(void)agreeWithRequestType:(RequestType)type;
//发出请求之后的UI改变
-(void)requestWithRequestType:(RequestType)type;
//拒绝对方之后的UI改变、
-(void)recoverWithRequestType:(RequestType)type;
@end
