//
//  ReplyView.h
//  TestIM4
//
//  Created by Apple on 16/1/8.
//  Copyright © 2016年 lanjue. All rights reserved.
//

#import <UIKit/UIKit.h>

/*这是快捷回复视图*/

@protocol ReplyViewDelegate <NSObject>

-(void)sendQucikReply:(NSString *)reply;
-(void)displayGrayView;


@end

@interface ReplyView : UIView

@property (nonatomic, weak) id<ReplyViewDelegate> delegate;

@end
