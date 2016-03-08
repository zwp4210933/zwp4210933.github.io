//
//  MyUtil.h
//  TestSouhuAuto
//
//  Created by gaokunpeng on 15/9/25.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MyUtil : NSObject

//创建图片
+ (UILabel *)createLabelFrame:(CGRect)frame title:(NSString *)title textColor:(UIColor *)color;
//创建按钮
+ (UIButton *)createBtnFrame:(CGRect)frame title:(NSString *)title bgImageName:(NSString *)bgImageName target:(id)target action:(SEL)action;
//创建图片视图
+ (UIImageView *)createImageViewFrame:(CGRect)frame imageName:(NSString *)imageName;
//创建TextField
+(UITextField *)createTextFieldFrame:(CGRect)frame placeHolder:(NSString *)placeHolder;
//改变图片颜色
+ (UIImage *)changeImage:(UIImage *)image withColor:(UIColor *)color;
//旋转图片
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;
@end
