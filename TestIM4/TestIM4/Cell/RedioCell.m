//
//  redioCell.m
//  TestIM4
//
//  Created by Apple on 15/12/3.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import "RedioCell.h"
#import "MyUtil.h"


@interface RedioCell()
@property (nonatomic, strong)  UIImageView *headerImageView;
@property (nonatomic, strong)  UIImageView *bubbleImageView;
@property (nonatomic, strong)  UILabel *timeLabel;
@property (nonatomic, strong)  UILabel *voiceLenghtLabel;
@property (nonatomic, strong)  UIView *playedSign;



@end

@implementation RedioCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)dealloc{
    [self.timer invalidate];
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
        [self.contentView addSubview:self.bubbleImageView];
        
        self.voiceImageView = [[UIImageView alloc] init];
        [self.bubbleImageView addSubview:self.voiceImageView];
        
        self.playedSign = [[UIView alloc] init];
        [self.contentView addSubview:self.playedSign];
        
        self.voiceLenghtLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.voiceLenghtLabel];
    }
    return self;
}

-(void)setMessage:(TextMessage *)message{
    _message = message;
    [self configWithMessage];
}

/*通过模型显示Cell*/
-(void)configWithMessage{
    
    for (UIGestureRecognizer *g in self.gestureRecognizers) {
        [self removeGestureRecognizer:g];
    }    
    
    //设置时间
    [self timeLabelSet];
    
    self.headerImageView.layer.cornerRadius = 25;
    self.headerImageView.layer.masksToBounds = YES;
    
    self.playedSign.backgroundColor = [UIColor redColor];
    self.playedSign.layer.cornerRadius = 2;
    self.playedSign.layer.masksToBounds = YES;
    self.playedSign.hidden = self.message.played;
    
    self.voiceLenghtLabel.text = [NSString stringWithFormat:@"%ld\"",(NSInteger)self.message.voiceLength];
    
    CGFloat bubbleLength = 60+self.message.voiceLength*1;
    UIImage *image = [UIImage imageNamed:@"touxiang"];
    self.headerImageView.image = image;
    if (self.message.direction == To) {
        //发出的消息的Cell显示
        self.headerImageView.frame = CGRectMake(SCREEN_WIDTH-55, 5+self.timeLabel.frame.size.height, 50, 50);
        self.bubbleImageView.frame = CGRectMake(SCREEN_WIDTH-bubbleLength-60, self.timeLabel.frame.size.height+15, bubbleLength, 40);
        UIImage *bubble = [UIImage imageNamed:@"chatto_bg"];
        bubble = [bubble stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
        self.bubbleImageView.image = bubble;
        
        self.voiceImageView.frame = CGRectMake(bubbleLength-30, 12, 16.0f/34*27, 16);
        self.voiceImageView.image = [UIImage imageNamed:@"voice_to"];
        
        self.playedSign.frame = CGRectMake(SCREEN_WIDTH-bubbleLength-70, self.timeLabel.frame.size.height+18, 4, 4);
        self.voiceLenghtLabel.frame = CGRectMake(SCREEN_WIDTH-bubbleLength-80, self.timeLabel.frame.size.height+35, 20, 20);
        self.voiceLenghtLabel.textColor = [UIColor grayColor];
        self.voiceLenghtLabel.font = [UIFont systemFontOfSize:11];
        
        
//        UIImage *bubble = [UIImage imageNamed:@"chatto_bg"];
//        bubble = [bubble stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
//        self.bubbleImageView.image = bubble;
//        self.bubbleImageView.frame = CGRectMake(SCREEN_WIDTH-65-size.width-30, 15+self.timeLabel.frame.size.height, size.width+30, size.height+10);
        


    }else{
        //收到的消息的Cell显示
        self.headerImageView.frame = CGRectMake(5, 5+self.timeLabel.frame.size.height, 50, 50);
        self.bubbleImageView.frame = CGRectMake(60, self.timeLabel.frame.size.height+15, bubbleLength, 40);
        UIImage *bubble = [UIImage imageNamed:@"chatfrom_bg"];
        bubble = [bubble stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
        self.bubbleImageView.image = bubble;
        
        self.voiceImageView.frame = CGRectMake(10, 12, 16.0f/34*27, 16);
        self.voiceImageView.image = [UIImage imageNamed:@"voice_from"];
        
        self.playedSign.frame = CGRectMake(65+bubbleLength, self.timeLabel.frame.size.height+18, 4, 4);
        self.voiceLenghtLabel.frame = CGRectMake(65+bubbleLength, self.timeLabel.frame.size.height+35, 20, 20);
        self.voiceLenghtLabel.textColor = [UIColor grayColor];
        self.voiceLenghtLabel.font = [UIFont systemFontOfSize:11];

        
        

    }

    //为气泡添加点击手势播放录音
    UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playRedio:)];
    self.bubbleImageView.userInteractionEnabled = YES;
    [self.bubbleImageView addGestureRecognizer:g];
    
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

-(void)playRedio:(UITapGestureRecognizer *)g{
    [self.delegate playRedioWithFileName:self.message.text indexPath:self.indexPath];
    self.playedSign.hidden = YES;
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(changeVoiceImage:) userInfo:nil repeats:YES];
        [self performSelector:@selector(bubbleBecomeNormal) withObject:nil afterDelay:self.message.voiceLength];
    
}

-(void)changeVoiceImage:(NSTimer *)timer{
    static int i = 0 ;
    if (self.message.direction == To) {
        self.voiceImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"played_to_%d",i%3+1]];
    }else{
        self.voiceImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"played_from_%d",i%3+1]];
    }
    i++;
}

-(void)bubbleBecomeNormal{
    
    [self.timer invalidate];
    if (self.message.direction == To) {
        self.voiceImageView.image = [UIImage imageNamed:@"voice_to"];
    }else{
        self.voiceImageView.image = [UIImage imageNamed:@"voice_from"];
    }

}

@end
