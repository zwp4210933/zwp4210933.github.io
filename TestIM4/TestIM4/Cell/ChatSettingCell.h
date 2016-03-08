//
//  ChatSettingCell.h
//  TestIM4
//
//  Created by Apple on 16/1/8.
//  Copyright © 2016年 lanjue. All rights reserved.
//

#import <UIKit/UIKit.h>

/*聊天设置Cell*/

@protocol ChatSettingCellDelegate <NSObject>

-(void)switchActionWitnOn:(BOOL)on indexPath:(NSIndexPath *)indexPath;

@end

@interface ChatSettingCell : UITableViewCell



@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<ChatSettingCellDelegate> delegate;

-(void)showSwitch:(BOOL)show on:(BOOL)isOn;

@end
