//
//  ReplyCell.m
//  TestIM4
//
//  Created by Apple on 15/11/30.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import "ReplyCell.h"

@interface ReplyCell()

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *replyMessageLabel;
@property (nonatomic, strong) UIImageView *backImageView;

@end

@implementation ReplyCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setMessage:(TextMessage *)message{
    _message = message;
    [self configWithModel];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.font = [UIFont systemFontOfSize:12];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.layer.cornerRadius = 10;
        self.timeLabel.layer.masksToBounds = YES;
        self.timeLabel.backgroundColor = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:220/255.0f];
        self.timeLabel.alpha = 0.5;
        self.timeLabel.textColor = [UIColor colorWithRed:80/255.0f green:80/255.0f blue:80/255.0f alpha:1];
        [self.contentView addSubview:self.timeLabel];
        
        self.backImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.backImageView];
        
        self.replyMessageLabel = [[UILabel alloc] init];
        self.replyMessageLabel.textAlignment = NSTextAlignmentCenter;
        self.replyMessageLabel.font = [UIFont systemFontOfSize:14];
        self.replyMessageLabel.textColor = [UIColor colorWithRed:122/255.0f green:122/255.0f blue:122/255.0f alpha:1];
        [self.backImageView addSubview:self.replyMessageLabel];
        
        UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self.backImageView addGestureRecognizer:g];
        self.backImageView.userInteractionEnabled = YES;
    }
    return self;
}

-(void)configWithModel{
    [self timeLabelSet];
    
    if (self.message.requestType == WeChat) {
        self.backImageView.image = [UIImage imageNamed:@"wechatPlay"];
    }else{
        self.backImageView.image = [UIImage imageNamed:@"teleNumberPlay"];
    }
    
    self.backImageView.frame = CGRectMake((SCREEN_WIDTH-312)/2.0f, self.timeLabel.frame.size.height+15, 312, 48);

    self.replyMessageLabel.text = self.message.text;
    self.replyMessageLabel.frame = CGRectMake(5, 5, 250, 38);
}

/*时间显示*/
-(void)timeLabelSet{
    self.timeLabel.frame = CGRectMake((SCREEN_WIDTH-170)/2.0f, 5, 170, 20);
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *curStr = [df stringFromDate:[NSDate date]];
    NSRange range1 = {0,4};
    NSString *curYear = [curStr substringWithRange:range1];
    NSString *sendYear = [self.message.time substringWithRange:range1];
    
    NSRange range2 = {5,2};
    NSString *curMonth = [curStr substringWithRange:range2];
    NSString *sendMonth = [self.message.time substringWithRange:range2];
    
    NSRange range3 = {8,2};
    NSString *curDay = [curStr substringWithRange:range3];
    NSString *sendDay = [self.message.time substringWithRange:range3];
    NSString *timeStr = [self.message.time substringFromIndex:5];
    NSString *hourAndMinute = [self.message.time substringFromIndex:11];
    if ([curYear isEqualToString:sendYear]) {
        if ([curMonth isEqualToString:sendMonth]) {
            if ([curDay integerValue]-[sendDay integerValue] == 0) {
                NSDate *curDate = [NSDate date];
                NSDate *sendDate = [df dateFromString:self.message.time];
                NSTimeInterval time = [curDate timeIntervalSinceDate:sendDate];
                
                if (time > 15 * 60) {
                    timeStr = hourAndMinute;
                }else{
                    //据当前时间15分钟以内的消息不显示时间Label
                    self.timeLabel.frame = CGRectMake(102, 5, 170, 0);
                }
                timeStr = hourAndMinute;
            }else if([curDay integerValue]-[sendDay integerValue]==1){
                timeStr = [NSString stringWithFormat:@"昨天 %@",hourAndMinute];
            }else if([curDay integerValue]-[sendDay integerValue]==2){
                timeStr = [NSString stringWithFormat:@"前天 %@",hourAndMinute];
            }
        }
    }else{
        //年份不同则显示完整时间
        timeStr = self.message.time;
    }
    
    
    self.timeLabel.text = timeStr;
    
}

-(void)tapAction:(UITapGestureRecognizer *)g{
    if (![self.message.text isEqualToString: @"很遗憾，对方拒绝了您的请求"]) {
        CGPoint p = [g locationInView:g.view];
        if (p.x>250) {
            [self.delegate takeConnectionWay:[self.message.text componentsSeparatedByString:@":"].lastObject requestType:self.message.requestType];
        }
        
    }
}

@end
