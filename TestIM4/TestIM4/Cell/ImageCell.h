//
//  ImageCell.h
//  TestIM4
//
//  Created by Apple on 15/12/3.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextMessage.h"

@protocol ImageCellDelegate <NSObject>

-(void)configDetailImageWithFileName:(NSString *)fileName Size:(CGSize)size;

@end

@interface ImageCell : UITableViewCell

@property (nonatomic, strong) TextMessage *message;

@property (nonatomic, weak) id delegate;

-(void)configWithMessage:(TextMessage *)message friendName:(NSString *)friendName;

@end
