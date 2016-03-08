//
//  redioCell.h
//  TestIM4
//
//  Created by Apple on 15/12/3.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextMessage.h"


@protocol RedioCellDelegate <NSObject>

-(void)playRedioWithFileName:(NSString *)fileName indexPath:(NSIndexPath *)indexPath;

@end

@interface RedioCell : UITableViewCell

@property (nonatomic, strong) TextMessage *message;
@property (nonatomic, weak) id<RedioCellDelegate> delegate;
@property (nonatomic, strong)  NSTimer *timer;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong)  UIImageView *voiceImageView;

-(void)bubbleBecomeNormal;

@end
