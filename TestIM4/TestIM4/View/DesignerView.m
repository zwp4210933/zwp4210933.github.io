//
//  DesignerView.m
//  TestIM4
//
//  Created by Apple on 15/12/31.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import "DesignerView.h"

#define Width (self.bounds.size.width)
#define Height (self.bounds.size.height)

@interface DesignerView()

@property (nonatomic, strong) Designer *model;
@property (nonatomic, strong) UILabel *lastBQLabel;
@property (nonatomic, assign) CGFloat lastWidth;

@end

@implementation DesignerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame Modle:(Designer *)model{
    self = [super initWithFrame:frame];
    if (self) {
        WS(weakSelf);
        self.model = model;
        
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
            make.bottom.equalTo(weakSelf).with.offset(-5);
        }];
        
        //头像
        UIImageView *headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:model.headerImageName]];
        [backView addSubview:headerImageView];
        [headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            NSLog(@"%f",554*backView.frame.size.height);
            make.top.equalTo(backView).with.offset(130.0f/3);
            make.left.equalTo(backView).with.offset(40.0f/1242*SCREEN_WIDTH);
            make.width.equalTo(backView.mas_width).multipliedBy(0.16);
            make.height.equalTo(headerImageView.mas_width);
        }];
        
        //姓名
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.text = model.name;
        nameLabel.font = [UIFont systemFontOfSize:20];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.textColor = [UIColor colorWithRed:144/255.0f green:194/255.0f blue:27/255.0f alpha:1];
        [backView addSubview:nameLabel];
        [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(backView).with.offset(130.0f/3);
            make.left.mas_equalTo(headerImageView.mas_right).with.offset(57.0f/1242*SCREEN_WIDTH);
            make.width.equalTo(@(60));
            make.height.equalTo(@(20));
        }];
        
        //竖线
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor grayColor];
        [backView addSubview:lineView];
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(nameLabel.mas_right).with.offset(10.0f/1242*SCREEN_WIDTH);
            make.bottom.equalTo(nameLabel);
            make.width.equalTo(@(1.5));
            make.height.equalTo(@(15));
        }];
        
        //职业
        UILabel *occupationLabel = [[UILabel alloc] init];
        occupationLabel.text = model.occupation;
        occupationLabel.textColor = [UIColor grayColor];
        occupationLabel.font = [UIFont systemFontOfSize:15];
        [backView addSubview:occupationLabel];
        [occupationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lineView);
            make.left.mas_equalTo(lineView.mas_right).with.offset(10.0f/1242*SCREEN_WIDTH);
            make.bottom.equalTo(lineView);
            make.width.equalTo(@(SCREEN_WIDTH*0.4));
        }];
        
        //价格图标
        UIImageView *priceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qian"]];
        [backView addSubview:priceImageView];
        [priceImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(nameLabel.mas_bottom).with.offset(39.0f/675*Height);
            make.left.mas_equalTo(headerImageView.mas_right).with.offset(57.0f/1242*SCREEN_WIDTH);
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
        
        //擅长风格
        NSMutableString *styleStr = [NSMutableString stringWithFormat:@"擅长风格 :"];
        for (NSString *str in model.styleArray) {
            [styleStr appendFormat:@" %@",str];
        }
        UILabel *styleLabel = [[UILabel alloc] init];
        styleLabel.text = styleStr;
        styleLabel.textColor = [UIColor colorWithRed:175/255.0f green:175/255.0f blue:175/255.0f alpha:1];
        styleLabel.font = [UIFont systemFontOfSize:14];
        styleLabel.numberOfLines = 0;
        [backView addSubview:styleLabel];
        [styleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(priceImageView.mas_bottom).with.offset(40.0f/3);
            make.left.equalTo(priceImageView);
            make.height.equalTo(@(35));
            make.right.equalTo(backView).with.offset(-5);
        }];
        
        //评价
        for (NSString *str in model.characterArray) {
            UILabel *bqLabel = [[UILabel alloc] init];
            bqLabel.text = str;
            bqLabel.textColor = [UIColor whiteColor];
            bqLabel.backgroundColor = [UIColor colorWithRed:154/255.0f green:198/255.0f blue:72/255.0f alpha:1];
            bqLabel.font = [UIFont systemFontOfSize:12];
            bqLabel.textAlignment = NSTextAlignmentCenter;
            bqLabel.layer.masksToBounds = YES;
            bqLabel.layer.cornerRadius = 5;
            [backView addSubview:bqLabel];
            [bqLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                if (weakSelf.lastBQLabel) {
                    if (weakSelf.lastWidth+[weakSelf labelWidthWithText:str Font:[UIFont systemFontOfSize:14]]+10.0f/3>SCREEN_WIDTH-20.0f/414*SCREEN_WIDTH) {
                        make.top.mas_equalTo(weakSelf.lastBQLabel.mas_bottom).with.offset(5);
                        make.left.equalTo(backView).with.offset(46.0f/1242*SCREEN_WIDTH);
                        make.height.equalTo(@(20));
                        make.width.equalTo(@([weakSelf labelWidthWithText:str Font:[UIFont systemFontOfSize:14]]));
                        weakSelf.lastWidth = 46.0f/1242*SCREEN_WIDTH + [weakSelf labelWidthWithText:str Font:[UIFont systemFontOfSize:14]];
                    }else{
                        make.top.equalTo(weakSelf.lastBQLabel);
                        make.left.mas_equalTo(weakSelf.lastBQLabel.mas_right).with.offset(10.0f/3);
                        make.height.equalTo(@(20));
                        make.width.equalTo(@([weakSelf labelWidthWithText:str Font:[UIFont systemFontOfSize:14]]));
                        weakSelf.lastWidth = weakSelf.lastWidth + [weakSelf labelWidthWithText:str Font:[UIFont systemFontOfSize:14]];
                    }
                }else{
                    make.top.mas_equalTo(styleLabel.mas_bottom).with.offset(10);
                    make.left.equalTo(backView).with.offset(46.0f/1242*SCREEN_WIDTH);
                    make.height.equalTo(@(20));
                    make.width.equalTo(@([weakSelf labelWidthWithText:str Font:[UIFont systemFontOfSize:14]]));
                    weakSelf.lastWidth = 46.0f/1242*SCREEN_WIDTH + [weakSelf labelWidthWithText:str Font:[UIFont systemFontOfSize:14]];
                }
            }];
            weakSelf.lastBQLabel = bqLabel;
        }
        
    }
    return self;
}

-(CGFloat)labelWidthWithText:(NSString *)text Font:(UIFont *)font{
    NSDictionary *attrs = @{NSFontAttributeName:font};
    CGSize  size = [text boundingRectWithSize:CGSizeZero options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    return size.width+2;
}

@end
