//
//  ReplyView.m
//  TestIM4
//
//  Created by Apple on 16/1/8.
//  Copyright © 2016年 lanjue. All rights reserved.
//

#import "ReplyView.h"



@interface ReplyView()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UILabel *countLabel;

@end
@implementation ReplyView


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)init{
    self = [super init];
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        self.backgroundColor = [UIColor whiteColor];
        
        WS(weakSelf);
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor colorWithRed:154/255.0f green:198/255.0f blue:72/255.0f alpha:1];
        titleLabel.text = @"快捷回复";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.clipsToBounds = YES;
        titleLabel.userInteractionEnabled = YES;
        [self addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf);
            make.left.equalTo(weakSelf);
            make.right.equalTo(weakSelf);
            make.height.equalTo(@(40.0f/736*SCREEN_HEIGHT));
        }];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn addTarget:self action:@selector(hiddenSelf) forControlEvents:UIControlEventTouchUpInside];
        [cancelBtn setBackgroundImage:[UIImage imageNamed:@"fork"] forState:UIControlStateNormal];
        [titleLabel addSubview:cancelBtn];
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLabel).with.offset(10.0f/736*SCREEN_HEIGHT);
            make.right.equalTo(titleLabel).with.offset(-10.0/414*SCREEN_HEIGHT);
            make.height.equalTo(@(20.0f/736*SCREEN_HEIGHT));
            make.width.equalTo(cancelBtn.mas_height);
        }];
        
        self.textView = [[UITextView alloc] init];
        _textView.backgroundColor = [UIColor colorWithRed:229.0f/255 green:229.0f/255 blue:229.0f/255 alpha:1];
        _textView.layer.masksToBounds = YES;
        _textView.layer.cornerRadius = 3;
        _textView.delegate = self;
        NSString *holdText = [[NSUserDefaults standardUserDefaults] objectForKey:@"quickReply"];
        if (holdText.length>0) {
            _textView.text = holdText;
            _textView.textColor = [UIColor blackColor];
        }else{
            _textView.text = @"来段开场白吧";
            _textView.textColor = [UIColor colorWithRed:202.0f/255 green:202.0f/255 blue:202.0f/255 alpha:1];
        }
        [self addSubview:self.textView];
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(titleLabel.mas_bottom).with.offset(10.0f/736*SCREEN_HEIGHT);
            make.left.equalTo(weakSelf).with.offset(15.0f/414*SCREEN_WIDTH);
            make.right.equalTo(weakSelf).with.offset(-15.0f/414*SCREEN_WIDTH);
            make.height.equalTo(@(138.0f/736*SCREEN_HEIGHT));
        }];
        
        
        
        UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        sendBtn.layer.masksToBounds = YES;
        sendBtn.layer.cornerRadius = 3;
        sendBtn.backgroundColor = [UIColor colorWithRed:155.0f/255 green:199.0f/255 blue:60.0f/255 alpha:1];
        [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [sendBtn addTarget:self action:@selector(sendReply) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:sendBtn];
        
        UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        saveBtn.layer.masksToBounds = YES;
        saveBtn.layer.cornerRadius = 3;
        saveBtn.backgroundColor = [UIColor colorWithRed:155.0f/255 green:199.0f/255 blue:60.0f/255 alpha:1];
        [saveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [saveBtn addTarget:self action:@selector(saveReply) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:saveBtn];
        
        [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).with.offset(-15.0f/414*SCREEN_WIDTH);
            make.left.mas_equalTo(saveBtn.mas_right).with.offset(37.0f/1242*SCREEN_WIDTH);
            make.bottom.equalTo(self).with.offset(-14.0f/736*SCREEN_HEIGHT);
            make.height.equalTo(@(101.0f/2208*SCREEN_HEIGHT));
        }];
        
        [saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(15.0f/414*SCREEN_WIDTH);
            make.width.equalTo(sendBtn.mas_width);
            make.bottom.equalTo(sendBtn);
            make.height.equalTo(sendBtn);
        }];
        
        self.countLabel = [[UILabel alloc] init];
        self.countLabel.text = [NSString stringWithFormat:@"%ld/200",holdText.length];
        self.countLabel.textColor = [UIColor colorWithRed:155.0f/255 green:199.0f/255 blue:60.0f/255 alpha:1];
        self.countLabel.textAlignment = NSTextAlignmentRight;
        self.countLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.countLabel];
        [self.countLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(weakSelf.textView);
            make.top.mas_equalTo(weakSelf.textView.mas_bottom).with.offset(23.0f/2208*SCREEN_HEIGHT);
            make.height.equalTo(@(40.0f/2208*SCREEN_HEIGHT));
            make.width.equalTo(@(100));
        }];
        
        
    }
    return self;
}

-(void)hiddenSelf{
    self.hidden = YES;
    [self.textView resignFirstResponder];
    [self.delegate displayGrayView];
}

-(void)saveReply{
    
    [self.textView resignFirstResponder];
    if (self.textView.textColor == [UIColor blackColor]&&self.textView.text.length>0&&self.textView.text.length<=200) {
        [[NSUserDefaults standardUserDefaults] setObject:self.textView.text forKey:@"quickReply"];
    }
    [self.delegate displayGrayView];
    self.hidden = YES;
}

-(void)sendReply{
    if (self.textView.textColor == [UIColor blackColor]&&self.textView.text.length>0&&self.textView.text.length<=200) {
        self.hidden = YES;
        [self.textView resignFirstResponder];
        [self.delegate sendQucikReply:self.textView.text];
    }
    
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    if (!(self.textView.textColor == [UIColor blackColor])) {
        self.textView.textColor = [UIColor blackColor];
        self.textView.text = @"";
    }
    
}

-(void)textViewDidChange:(UITextView *)textView{
    self.countLabel.text = [NSString stringWithFormat:@"%ld/200",textView.text.length];
    if (textView.text.length >200) {
        self.countLabel.textColor = [UIColor redColor];
    }else{
        self.countLabel.textColor = [UIColor colorWithRed:155.0f/255 green:199.0f/255 blue:60.0f/255 alpha:1];
    }
}

@end
