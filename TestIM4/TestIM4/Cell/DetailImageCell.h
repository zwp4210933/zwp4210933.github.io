//
//  DetailImageCell.h
//  TestIM4
//
//  Created by Apple on 15/12/7.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import <UIKit/UIKit.h>

/*查看大图Cell*/

@protocol DetailImageCellDelegate <NSObject>

-(void)goBackToLastCtrl;

@end


@interface DetailImageCell : UICollectionViewCell


@property (nonatomic, weak) id<DetailImageCellDelegate> delegate;

-(void)configWithImageName:(NSString *)imageName imageSize:(CGSize)imageSize selfName:(NSString *)selfName friendName:(NSString *)friendName;


@end
