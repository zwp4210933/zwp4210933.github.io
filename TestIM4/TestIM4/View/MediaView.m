//
//  MediaView.m
//  TestIM4
//
//  Created by Apple on 16/1/8.
//  Copyright © 2016年 lanjue. All rights reserved.
//

#import "MediaView.h"

@implementation MediaView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIButton *photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [photoBtn setBackgroundImage:[UIImage imageNamed:@"Photo"] forState:UIControlStateNormal];
        [photoBtn addTarget:self action:@selector(sendPhoto) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:photoBtn];
        
        UIButton *albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [albumBtn setBackgroundImage:[UIImage imageNamed:@"Album"] forState:UIControlStateNormal];
        [albumBtn addTarget:self action:@selector(sendPhotoFromAlbum) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:albumBtn];
        
        UIButton *replyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [replyBtn setBackgroundImage:[UIImage imageNamed:@"Reply"] forState:UIControlStateNormal];
        [replyBtn addTarget:self action:@selector(quickReply) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:replyBtn];
        
        WS(weakSelf);
        [photoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf).with.offset(16.0f/736*SCREEN_HEIGHT);
            make.left.equalTo(weakSelf).with.offset(231.0f/1242*SCREEN_WIDTH);
            make.height.equalTo(photoBtn.mas_width);
            make.width.equalTo(albumBtn);
        }];
        
        [albumBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(photoBtn);
            make.left.mas_equalTo(photoBtn.mas_right).with.offset(177.0f/1242*SCREEN_WIDTH);
            make.height.equalTo(photoBtn);
            make.right.mas_equalTo(replyBtn.mas_left).with.offset(-177.0f/1242*SCREEN_WIDTH);
        }];
        
        [replyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(photoBtn);
            make.height.equalTo(photoBtn);
            make.width.equalTo(photoBtn);
        }];
        
        NSArray *titleArr = @[@"拍摄照片",@"相册照片",@"快捷回复"];
        NSArray<UIView *> *btnArr = @[photoBtn,albumBtn,replyBtn];
        for (int i = 0; i<titleArr.count; i++) {
            UILabel *label = [[UILabel alloc] init];
            label.text = titleArr[i];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:11];
            [self addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(btnArr[i]).with.offset(-10);
                make.right.equalTo(btnArr[i]).with.offset(10);
                make.top.mas_equalTo(btnArr[i].mas_bottom).with.offset(46.0f/2208*SCREEN_HEIGHT);
                make.bottom.equalTo(weakSelf).with.offset(-15.0/736*SCREEN_HEIGHT);
            }];
        }

    }
    return self;
}

-(void)sendPhoto{
    [self.delegate takePhoto];
}

-(void)sendPhotoFromAlbum{
    [self.delegate openAlbum];
}

-(void)quickReply{
    [self.delegate callReplayView];
}

@end
