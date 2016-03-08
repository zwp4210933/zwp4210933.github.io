//
//  RequestCell.m
//  TestIM4
//
//  Created by Apple on 15/11/30.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import "RequestCell.h"
#import "ChatHistoryManager.h"

@interface RequestCell()

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UIImageView *bubbleImageView;
@property (nonatomic, strong) UILabel *requestLabel;
@property (nonatomic, strong) UIButton *agreeBtn;
@property (nonatomic, strong) UIButton *refuseBtn;




@end

@implementation RequestCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setMessage:(TextMessage *)message{
    _message = message;
    [self configWithMessage];
    
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
        
        self.headerImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.headerImageView];
        
        self.bubbleImageView = [[UIImageView alloc] init];
        self.bubbleImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:self.bubbleImageView];
        
        self.requestLabel = [[UILabel alloc] init];
        self.requestLabel.numberOfLines = 0;
        self.requestLabel.textAlignment = NSTextAlignmentCenter;
        self.requestLabel.font = [UIFont systemFontOfSize:14];
        self.requestLabel.textColor = [UIColor colorWithRed:122/255.0f green:122/255.0f blue:122/255.0f alpha:1];
        [self.bubbleImageView addSubview:self.requestLabel];
        
        self.agreeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        self.agreeBtn.layer.cornerRadius = 2;
        self.agreeBtn.layer.masksToBounds = YES;
        [self.agreeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.agreeBtn.backgroundColor = [UIColor colorWithRed:151/255.0f green:197/255.0f blue:68/255.0f alpha:1];
        [self.agreeBtn addTarget:self action:@selector(agreeAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.agreeBtn setTitle:@"同意" forState:UIControlStateNormal];
        [self.bubbleImageView addSubview:self.agreeBtn];
        
        
        self.refuseBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        self.refuseBtn.layer.cornerRadius = 2;
        self.refuseBtn.layer.masksToBounds = YES;
        [self.refuseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.refuseBtn.backgroundColor = [UIColor colorWithRed:250/255.0f green:81/255.0f blue:32/255.0f alpha:1];
        [self.refuseBtn setTitle:@"拒绝" forState:UIControlStateNormal];
        [self.refuseBtn addTarget:self action:@selector(disagreeAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.bubbleImageView addSubview:self.refuseBtn];
    }
    return self;
}

-(void)configWithMessage{
    //时间显示
    [self timeLabelSet];
    
    self.headerImageView.layer.cornerRadius = 25;
    self.headerImageView.layer.masksToBounds = YES;
    UIImage *image = [UIImage imageNamed:@"touxiang"];
    self.headerImageView.image = image;

    if(self.message.direction == To){
        //发出的消息的Cell显示
        self.agreeBtn.hidden = YES;
        self.refuseBtn.hidden = YES;
        
        self.headerImageView.frame = CGRectMake(SCREEN_WIDTH-55, 5+self.timeLabel.frame.size.height, 50, 50);
        
        UIImage *bubble = [UIImage imageNamed:@"chatto_bg"];
        bubble = [bubble stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
        self.bubbleImageView.image = bubble;
        self.bubbleImageView.frame = CGRectMake(SCREEN_WIDTH-240, 15+self.timeLabel.frame.size.height, 180, 50);
        
        self.requestLabel.frame = CGRectMake(7.5, 5, 160, 40);
        self.requestLabel.text = [NSString stringWithFormat:@"您提出了交换%@请求\n请耐心等待回复",self.message.text];
    }else{
        //收到的消息的Cell显示
        self.agreeBtn.hidden = NO;
        self.refuseBtn.hidden = NO;
        if (self.message.replyed == YES) {
            self.agreeBtn.backgroundColor = [UIColor colorWithRed:198/255.0f green:198/255.0f blue:198/255.0f alpha:1];
            self.agreeBtn.enabled = NO;
            self.refuseBtn.backgroundColor = [UIColor colorWithRed:198/255.0f green:198/255.0f blue:198/255.0f alpha:1];
            self.refuseBtn.enabled = NO;
        }else{
            self.agreeBtn.backgroundColor = [UIColor colorWithRed:151/255.0f green:197/255.0f blue:68/255.0f alpha:1];
            self.agreeBtn.enabled = YES;
            self.refuseBtn.backgroundColor = [UIColor colorWithRed:250/255.0f green:81/255.0f blue:32/255.0f alpha:1];
            self.agreeBtn.enabled = YES;
        }
        
        self.headerImageView.frame = CGRectMake(5, 5+self.timeLabel.frame.size.height, 50, 50);
        
        UIImage *bubble = [UIImage imageNamed:@"chatfrom_bg"];
        bubble = [bubble stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
        self.bubbleImageView.image = bubble;
        self.bubbleImageView.frame = CGRectMake(65, 15+self.timeLabel.frame.size.height, 180, 80);
        
        self.requestLabel.frame = CGRectMake(12.5, 5, 160, 40);
        self.requestLabel.text = [NSString stringWithFormat:@"我想和你交换%@\n是否同意",self.message.text];
        
        self.agreeBtn.frame = CGRectMake(7, 50, 86, 30);
        self.refuseBtn.frame = CGRectMake(94, 50, 86, 30);
    }
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
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


- (void)disagreeAction:(id)sender {

    
    if (self.message.requestType == WeChat) {
        [self.delegate replyRequset:NO requestType:WeChat];
    }else{
        [self.delegate replyRequset:NO requestType:Phone];
    }
}

- (void)agreeAction:(id)sender {

    if (self.message.requestType == WeChat) {
        [self.delegate replyRequset:YES requestType:WeChat];
    }else{
        [self.delegate replyRequset:YES requestType:Phone];
    }
}


@end
