//
//  ChatCell.m
//  TestIM4
//
//  Created by Apple on 15/11/27.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import "ChatCell.h"
#import "ChatHistoryManager.h"

@interface ChatCell()

@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *friendNameLabel;
@property (nonatomic, strong) UILabel *lastMessageLabel;
@property (nonatomic, strong) UILabel *timeLabel;



@end

@implementation ChatCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        WS(weakSelf);
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.headerImageView = [[UIImageView alloc] init];
        self.headerImageView.layer.cornerRadius = 25;
        self.headerImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.headerImageView];
        [self.headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.contentView).with.offset(10.0/375*SCREEN_WIDTH);
            make.top.equalTo(weakSelf.contentView).with.offset(16);
            make.height.equalTo(@(50));
            make.width.equalTo(@(50));
        }];
        
        self.friendNameLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.friendNameLabel];
        [self.friendNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.headerImageView);
            make.left.mas_equalTo(weakSelf.headerImageView.mas_right).with.offset(20.0f/375*SCREEN_WIDTH);
            make.height.equalTo(@(20));
            make.width.equalTo(@(100));
        }];
        
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.font = [UIFont systemFontOfSize:12];
        self.timeLabel.textColor = [UIColor grayColor];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:self.timeLabel];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf.friendNameLabel);
            make.left.mas_equalTo(weakSelf.friendNameLabel.mas_right).with.offset(10.0f/375*SCREEN_WIDTH);
            make.width.equalTo(@(SCREEN_WIDTH-200));
            make.height.equalTo(@(12));
        }];
        
        self.lastMessageLabel = [[UILabel alloc] init];
        self.lastMessageLabel.font = [UIFont systemFontOfSize:12];
        self.lastMessageLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:self.lastMessageLabel];
        [self.lastMessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.friendNameLabel);
            make.bottom.equalTo(weakSelf.headerImageView).with.offset(-5);
            make.right.equalTo(weakSelf.contentView).with.offset(-20.0f/375*SCREEN_WIDTH);
            make.height.equalTo(@(20));
        }];
        
        self.numberLabel = [[UILabel alloc] init];
        self.numberLabel.layer.cornerRadius = 10;
        self.numberLabel.layer.masksToBounds = YES;
        self.numberLabel.backgroundColor = [UIColor redColor];
        self.numberLabel.textColor = [UIColor whiteColor];
        self.numberLabel.textAlignment = NSTextAlignmentCenter;
        self.numberLabel.font = [UIFont systemFontOfSize:17];
        [self.contentView addSubview:self.numberLabel];
        [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.headerImageView).offset(-5);
            make.top.equalTo(weakSelf.headerImageView).offset(-5);
            make.width.equalTo(@(20));
            make.height.equalTo(@(20));
        }];
        
    }
    return self;
}

-(void)configWithChat:(Chat *)model{
    ChatHistoryManager *manager = [[ChatHistoryManager alloc] init];
    manager.friendName = model.userName;
    //获取未读消息数量
    NSArray *array = [manager selectedAllMessage];
    NSInteger count = 0;
    for (TextMessage *message in array) {
        if (!message.readed) {
            count++;
        }
    }
    
    [self timeLabelSetWithTime:[manager selectedLastMessageTime]];
    
    if (count==0) {
        self.numberLabel.hidden = YES;
    }else if(count>0&&count<99){
        self.numberLabel.text =[NSString stringWithFormat:@"%ld",count];
        if (count>10) {
            self.numberLabel.font = [UIFont systemFontOfSize:10];
        }
        self.numberLabel.hidden = NO;
    }else{
        self.numberLabel.text = @"99";
        self.numberLabel.hidden = NO;
    }
    
    self.notReadedCount = count;
    
    
    UIImage *image = [UIImage imageWithData:model.data];
    self.headerImageView.image = image;
    
    
    self.friendNameLabel.text = model.userName;
    //获取该会话的最后一条消息
    self.lastMessageLabel.text = [manager selectedLastMessage];
    
    //根据置顶情况显示置顶图标
    if (model.isTop) {
        self.backgroundColor = [UIColor colorWithRed:231/255.0f green:239/255.0f blue:241/255.0f alpha:1];
    }else{
        self.backgroundColor = [UIColor whiteColor];
    }
}

/*时间显示*/
-(void)timeLabelSetWithTime:(NSString *)time{
    if (time.length>0) {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *curStr = [df stringFromDate:[NSDate date]];
        NSRange range1 = {0,4};
        NSString *curYear = [curStr substringWithRange:range1];
        NSString *sendYear = [time substringWithRange:range1];
        
        NSRange range2 = {5,2};
        NSString *curMonth = [curStr substringWithRange:range2];
        NSString *sendMonth = [time substringWithRange:range2];
        
        NSRange range3 = {8,2};
        NSString *curDay = [curStr substringWithRange:range3];
        NSString *sendDay = [time substringWithRange:range3];
        NSString *timeStr = [time substringFromIndex:5];
        NSString *hourAndMinute = [time substringFromIndex:11];
        if ([curYear isEqualToString:sendYear]) {
            if ([curMonth isEqualToString:sendMonth]) {
                if ([curDay integerValue]-[sendDay integerValue] == 0) {
                    timeStr = hourAndMinute;
                }else if([curDay integerValue]-[sendDay integerValue]==1){
                    timeStr = [NSString stringWithFormat:@"昨天 %@",hourAndMinute];
                }else if([curDay integerValue]-[sendDay integerValue]==2){
                    timeStr = [NSString stringWithFormat:@"前天 %@",hourAndMinute];
                }
            }
        }else{
            //年份不同则显示完整时间
            timeStr = time;
        }
        
        self.timeLabel.text = timeStr;
        

    }
   }

@end
