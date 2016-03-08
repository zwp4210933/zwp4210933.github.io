//
//  MissionView.m
//  TestIM4
//
//  Created by Apple on 16/1/9.
//  Copyright © 2016年 lanjue. All rights reserved.
//

#import "MissionView.h"
#define Width (self.bounds.size.width)
#define Height (self.bounds.size.height)

@implementation MissionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame Modle:(Mission *)model{
    self = [super initWithFrame:frame];
    if (self) {
        WS(weakSelf);
        //背景
        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor = [UIColor whiteColor];
        backView.layer.cornerRadius = 8;
        backView.layer.masksToBounds = YES;
        [self addSubview:backView];
        [backView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf).with.offset(26);
            make.left.equalTo(weakSelf).with.offset(10.0f/414*SCREEN_WIDTH);
            make.right.equalTo(weakSelf).with.offset(-10.0f/414*SCREEN_WIDTH);
            make.bottom.equalTo(weakSelf).with.offset(5);
        }];
        
        //头像
        UIImageView *headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:model.headerImageName]];
        [backView addSubview:headerImageView];
        [headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            NSLog(@"%f",554*backView.frame.size.height);
            make.centerY.equalTo(backView);
            make.right.equalTo(backView).with.offset(-127.0f/1242*SCREEN_WIDTH);
            make.width.equalTo(backView.mas_width).multipliedBy(0.16);
            make.height.equalTo(headerImageView.mas_width);
        }];
        
        //发布者
        UILabel *publicLabel = [[UILabel alloc] init];
        publicLabel.text = model.publicer;
        publicLabel.textAlignment = NSTextAlignmentCenter;
        [backView addSubview:publicLabel];
        [publicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(headerImageView.mas_bottom).with.offset(43.0f/3);
            make.centerX.equalTo(headerImageView);
            make.width.equalTo(@(60));
            make.height.equalTo(@(18));
        }];
        
        //任务名称
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.text = model.name;
        nameLabel.font = [UIFont systemFontOfSize:20];
        nameLabel.textColor = [UIColor colorWithRed:144/255.0f green:194/255.0f blue:27/255.0f alpha:1];
        [backView addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(backView).with.offset(83.0f/3);
            make.left.equalTo(backView).with.offset(21.0f/414*SCREEN_WIDTH);
            make.width.equalTo(@([self labelWidthWithText:model.name Font:[UIFont systemFontOfSize:20]]));
            make.height.equalTo(@(20));
        }];
        
        
        
        //价格图标
        UIImageView *priceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qian"]];
        [backView addSubview:priceImageView];
        [priceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(nameLabel.mas_bottom).with.offset(43.0f/3);
            make.left.equalTo(nameLabel);
            make.height.equalTo(@(12));
            make.width.equalTo(priceImageView.mas_height).multipliedBy(17.0f/21);
        }];
        
        //价格
        UILabel *priceLabel = [[UILabel alloc] init];
        priceLabel.text = model.salary;
        priceLabel.textColor = [UIColor colorWithRed:175/255.0f green:175/255.0f blue:175/255.0f alpha:1];
        priceLabel.font = [UIFont systemFontOfSize:14];
        [backView addSubview:priceLabel];
        [priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(priceImageView);
            make.left.mas_equalTo(priceImageView.mas_right).with.offset(2);
            make.height.equalTo(@(14));
            make.width.equalTo(@([weakSelf labelWidthWithText:model.salary Font:[UIFont systemFontOfSize:14]]));
        }];
        
        UIImageView *styleImageView = [[UIImageView alloc] initWithImage:@""];
        
        //地点图标
        UIImageView *placeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dibiao"]];
        [backView addSubview:placeImageView];
        [placeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(priceImageView);
            make.left.mas_equalTo(priceLabel.mas_right).with.offset(39.0f/1242*SCREEN_WIDTH);
            make.height.equalTo(@(12));
            make.width.equalTo(priceImageView.mas_height).multipliedBy(16.0f/25);
        }];
        
        //地点
        UILabel *placeLabel = [[UILabel alloc] init];
        placeLabel.text = model.place;
        placeLabel.textColor = [UIColor colorWithRed:175/255.0f green:175/255.0f blue:175/255.0f alpha:1];
        placeLabel.font = [UIFont systemFontOfSize:14];
        [backView addSubview:placeLabel];
        [placeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(priceImageView);
            make.left.mas_equalTo(placeImageView.mas_right).with.offset(2);
            make.height.equalTo(@(14));
            make.width.equalTo(@([weakSelf labelWidthWithText:model.place Font:[UIFont systemFontOfSize:14]]));
        }];
        
        //经验图标
        UIImageView *exImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jingyanxiang"]];
        [backView addSubview:exImageView];
        [exImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(priceImageView);
            make.left.mas_equalTo(placeLabel.mas_right).with.offset(39.0f/1242*SCREEN_WIDTH);
            make.height.equalTo(@(12));
            make.width.equalTo(priceImageView.mas_height).multipliedBy(27.0f/24);
        }];
        
        //经验
        UILabel *exLabel = [[UILabel alloc] init];
        exLabel.text = model.time;
        exLabel.textColor = [UIColor colorWithRed:175/255.0f green:175/255.0f blue:175/255.0f alpha:1];
        exLabel.font = [UIFont systemFontOfSize:14];
        [backView addSubview:exLabel];
        [exLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(priceImageView);
            make.left.mas_equalTo(exImageView.mas_right).with.offset(2);
            make.height.equalTo(@(14));
            make.width.equalTo(@([weakSelf labelWidthWithText:model.time Font:[UIFont systemFontOfSize:14]]));
        }];
        
        //性别图标
        UIImageView *genderImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sex_women"]];
        [backView addSubview:genderImageView];
        [genderImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(priceImageView);
            make.left.mas_equalTo(exLabel.mas_right).with.offset(39.0f/1242*SCREEN_WIDTH);
            make.height.equalTo(@(12));
            make.width.equalTo(priceImageView.mas_height).multipliedBy(17.0f/29);
        }];
        
        //性别
        UILabel *genderLabel = [[UILabel alloc] init];
        genderLabel.text = model.genger;
        genderLabel.textColor = [UIColor colorWithRed:175/255.0f green:175/255.0f blue:175/255.0f alpha:1];
        genderLabel.font = [UIFont systemFontOfSize:14];
        [backView addSubview:genderLabel];
        [genderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(priceImageView);
            make.left.mas_equalTo(genderImageView.mas_right).with.offset(2);
            make.height.equalTo(@(14));
            make.width.equalTo(@([weakSelf labelWidthWithText:model.genger Font:[UIFont systemFontOfSize:14]]));
        }];

    }
    return self;
}

-(CGFloat)labelWidthWithText:(NSString *)text Font:(UIFont *)font{
    NSDictionary *attrs = @{NSFontAttributeName:font};
    CGSize  size = [text boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    return size.width+2;
}

@end
