//
//  ChangeInfoView.m
//  TestIM4
//
//  Created by Apple on 15/12/31.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import "ChangeInfoView.h"


@interface ChangeInfoView()

@property (nonatomic, strong)changeContack changeBlock;
@property (nonatomic, strong)UIButton *phoneBtn;
@property (nonatomic, strong)UIButton *wechatBtn;

@end

@implementation ChangeInfoView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame FriendName:(Friend *)friend ChangeBlock:(changeContack)changeBlock{
    self = [super initWithFrame:frame];
    if (self) {
        self.friend = friend;
        self.changeBlock = changeBlock;
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1].CGColor;
        
        WS(weakSelf);
        
        UIView *lineLabel = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*0.5, 5, 1, 30)];
        lineLabel.backgroundColor = [UIColor colorWithRed:232/255.0f green:232/255.0f blue:232/255.0f alpha:1];
        [self addSubview:lineLabel];

        
        self.phoneBtn = [MyUtil createBtnFrame:CGRectZero title:@"交换电话" bgImageName:nil target:self action:@selector(changePhone:)];
        self.phoneBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        self.phoneBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        self.phoneBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        [self addSubview:self.phoneBtn];
        [self.phoneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(weakSelf.mas_centerX).multipliedBy(0.5);
            make.centerY.equalTo(weakSelf);
            make.width.equalTo(weakSelf.mas_width).multipliedBy(0.3);
            make.height.equalTo(weakSelf.mas_height).multipliedBy(0.6);
        }];
        
        self.wechatBtn = [MyUtil createBtnFrame:CGRectZero title:@"交换微信" bgImageName:nil target:self action:@selector(changeWechat:)];
        self.wechatBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        self.wechatBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        self.wechatBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.wechatBtn];
        [self.wechatBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(weakSelf.mas_centerX).multipliedBy(1.5);
            make.centerY.equalTo(weakSelf);
            make.width.equalTo(weakSelf.mas_width).multipliedBy(0.3);
            make.height.equalTo(weakSelf.mas_height).multipliedBy(0.6);
        }];
        
        [self setButtonPlay];
    }
    return self;
}

-(void)refusedWithRequestType:(RequestType)type{
    if (type == WeChat) {
        [self.wechatBtn setImage:[UIImage imageNamed:@"wechat_gray"] forState:UIControlStateNormal];
        [self.wechatBtn setTitle:@"交换微信" forState:UIControlStateNormal];
        [self.wechatBtn setTitleColor:[UIColor colorWithRed:192/255.0f green:192/255.0f blue:192/255.0f alpha:1] forState:UIControlStateNormal];
        self.wechatBtn.enabled = NO;
    }else{
        [self.phoneBtn setImage:[UIImage imageNamed:@"telephone_gray"] forState:UIControlStateNormal];
        [self.phoneBtn setTitle:@"交换手机" forState:UIControlStateNormal];
        [self.phoneBtn setTitleColor:[UIColor colorWithRed:192/255.0f green:192/255.0f blue:192/255.0f alpha:1] forState:UIControlStateNormal];
        self.phoneBtn.enabled = NO;
    }
}

-(void)agreeWithRequestType:(RequestType)type{
    if (type == WeChat) {
        [self.wechatBtn setImage:[UIImage imageNamed:@"wechat"] forState:UIControlStateNormal];
        [self.wechatBtn setTitle:@"微信号" forState:UIControlStateNormal];
        [self.wechatBtn setTitleColor:[UIColor colorWithRed:144/255.0f green:194/255.0f blue:27/255.0f alpha:1] forState:UIControlStateNormal];
        self.wechatBtn.enabled = YES;
    }else{
        [self.phoneBtn setImage:[UIImage imageNamed:@"telephone"] forState:UIControlStateNormal];
        [self.phoneBtn setTitle:@"手机号" forState:UIControlStateNormal];
        [self.phoneBtn setTitleColor:[UIColor colorWithRed:86/255.0f green:172/255.0f blue:252/255.0f alpha:1] forState:UIControlStateNormal];
        self.phoneBtn.enabled = YES;
    }

}


-(void)requestWithRequestType:(RequestType)type{
    if (type == WeChat) {
        [self.wechatBtn setImage:[UIImage imageNamed:@"wechat_gray"] forState:UIControlStateNormal];
        [self.wechatBtn setTitle:@"请求中" forState:UIControlStateNormal];
        [self.wechatBtn setTitleColor:[UIColor colorWithRed:192/255.0f green:192/255.0f blue:192/255.0f alpha:1] forState:UIControlStateNormal];
        self.wechatBtn.enabled = NO;
    }else{
        [self.phoneBtn setImage:[UIImage imageNamed:@"telephone_gray"] forState:UIControlStateNormal];
        [self.phoneBtn setTitle:@"请求中" forState:UIControlStateNormal];
        [self.phoneBtn setTitleColor:[UIColor colorWithRed:192/255.0f green:192/255.0f blue:192/255.0f alpha:1] forState:UIControlStateNormal];
        self.phoneBtn.enabled = NO;
    }
}

-(void)recoverWithRequestType:(RequestType)type{
    [self setButtonPlay];

}

-(void)setButtonPlay{
    ChangeState state = self.friend.changeState;
    if (state == Weixin) {
        [self.wechatBtn setImage:[UIImage imageNamed:@"wechat"] forState:UIControlStateNormal];
        [self.wechatBtn setTitle:@"微信号" forState:UIControlStateNormal];
        [self.wechatBtn setTitleColor:[UIColor colorWithRed:144/255.0f green:194/255.0f blue:27/255.0f alpha:1] forState:UIControlStateNormal];
        self.wechatBtn.enabled = YES;
        
        [self.phoneBtn setImage:[UIImage imageNamed:@"telephone"] forState:UIControlStateNormal];
        [self.phoneBtn setTitle:@"交换手机" forState:UIControlStateNormal];
        [self.phoneBtn setTitleColor:[UIColor colorWithRed:86/255.0f green:172/255.0f blue:252/255.0f alpha:1] forState:UIControlStateNormal];
        self.phoneBtn.enabled = YES;
        
        if (self.friend.changePhoneNumberTime) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSDate *curTime = [NSDate date];
            NSDate *requestTime = [df dateFromString:self.friend.changePhoneNumberTime];
            NSTimeInterval time = [curTime timeIntervalSinceDate:requestTime];
            if (time < 24*60*60) {
                [self.phoneBtn setImage:[UIImage imageNamed:@"telephone_gray"] forState:UIControlStateNormal];
                [self.phoneBtn setTitle:@"请求中" forState:UIControlStateNormal];
                [self.phoneBtn setTitleColor:[UIColor colorWithRed:192/255.0f green:192/255.0f blue:192/255.0f alpha:1] forState:UIControlStateNormal];
                self.phoneBtn.enabled = NO;
            }
        }
    }else if (state == PhoneNumber){
        [self.phoneBtn setImage:[UIImage imageNamed:@"telephone"] forState:UIControlStateNormal];
        [self.phoneBtn setTitle:@"手机号" forState:UIControlStateNormal];
        [self.phoneBtn setTitleColor:[UIColor colorWithRed:86/255.0f green:172/255.0f blue:252/255.0f alpha:1] forState:UIControlStateNormal];
        self.phoneBtn.enabled = YES;
        
        [self.wechatBtn setImage:[UIImage imageNamed:@"wechat"] forState:UIControlStateNormal];
        [self.wechatBtn setTitle:@"交换微信" forState:UIControlStateNormal];
        [self.wechatBtn setTitleColor:[UIColor colorWithRed:144/255.0f green:194/255.0f blue:27/255.0f alpha:1] forState:UIControlStateNormal];
        self.wechatBtn.enabled = YES;
        if (self.friend.changeWechatTime) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSDate *curTime = [NSDate date];
            NSDate *requestTime = [df dateFromString:self.friend.changeWechatTime];
            NSTimeInterval time = [curTime timeIntervalSinceDate:requestTime];
            if (time < 24*60*60) {
                [self.wechatBtn setImage:[UIImage imageNamed:@"wechat_gray"] forState:UIControlStateNormal];
                [self.wechatBtn setTitle:@"请求中" forState:UIControlStateNormal];
                [self.wechatBtn setTitleColor:[UIColor colorWithRed:192/255.0f green:192/255.0f blue:192/255.0f alpha:1] forState:UIControlStateNormal];
                self.wechatBtn.enabled = NO;
            }

        }
    }else if (state == All){
        [self.wechatBtn setImage:[UIImage imageNamed:@"wechat"] forState:UIControlStateNormal];
        [self.wechatBtn setTitle:@"微信号" forState:UIControlStateNormal];
        [self.wechatBtn setTitleColor:[UIColor colorWithRed:144/255.0f green:194/255.0f blue:27/255.0f alpha:1] forState:UIControlStateNormal];
        self.wechatBtn.enabled = YES;
        
        [self.phoneBtn setImage:[UIImage imageNamed:@"telephone"] forState:UIControlStateNormal];
        [self.phoneBtn setTitle:@"手机号" forState:UIControlStateNormal];
        [self.phoneBtn setTitleColor:[UIColor colorWithRed:86/255.0f green:172/255.0f blue:252/255.0f alpha:1] forState:UIControlStateNormal];
        self.phoneBtn.enabled = YES;

    }else{
        [self.wechatBtn setImage:[UIImage imageNamed:@"wechat"] forState:UIControlStateNormal];
        [self.wechatBtn setTitle:@"交换微信" forState:UIControlStateNormal];
        [self.wechatBtn setTitleColor:[UIColor colorWithRed:144/255.0f green:194/255.0f blue:27/255.0f alpha:1] forState:UIControlStateNormal];
        self.wechatBtn.enabled = YES;
        if (self.friend.changeWechatTime) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSDate *curTime = [NSDate date];
            NSDate *requestTime = [df dateFromString:self.friend.changePhoneNumberTime];
            NSTimeInterval time = [curTime timeIntervalSinceDate:requestTime];
            if (time < 24*60*60) {
                [self.wechatBtn setImage:[UIImage imageNamed:@"wechat_gray"] forState:UIControlStateNormal];
                [self.wechatBtn setTitle:@"请求中" forState:UIControlStateNormal];
                [self.wechatBtn setTitleColor:[UIColor colorWithRed:192/255.0f green:192/255.0f blue:192/255.0f alpha:1] forState:UIControlStateNormal];
                self.wechatBtn.enabled = NO;
            }
            
        }
        
        [self.phoneBtn setImage:[UIImage imageNamed:@"telephone"] forState:UIControlStateNormal];
        [self.phoneBtn setTitle:@"交换手机" forState:UIControlStateNormal];
        [self.phoneBtn setTitleColor:[UIColor colorWithRed:86/255.0f green:172/255.0f blue:252/255.0f alpha:1] forState:UIControlStateNormal];
        self.phoneBtn.enabled = YES;
        
        if (self.friend.changePhoneNumberTime) {
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSDate *curTime = [NSDate date];
            NSDate *requestTime = [df dateFromString:self.friend.changeWechatTime];
            NSTimeInterval time = [curTime timeIntervalSinceDate:requestTime];
            if (time < 24*60*60) {
                [self.phoneBtn setImage:[UIImage imageNamed:@"telephone_gray"] forState:UIControlStateNormal];
                [self.phoneBtn setTitle:@"请求中" forState:UIControlStateNormal];
                [self.phoneBtn setTitleColor:[UIColor colorWithRed:192/255.0f green:192/255.0f blue:192/255.0f alpha:1] forState:UIControlStateNormal];
                self.phoneBtn.enabled = NO;
            }
        }


    }
}

-(void)changePhone:(UIButton *)btn{
    self.changeBlock(Phone);
    
}

-(void)changeWechat:(UIButton *)btn{
    self.changeBlock(WeChat);
}

@end
