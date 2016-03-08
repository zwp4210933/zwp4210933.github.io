//
//  TextCell.m
//  TestIM4
//
//  Created by Apple on 15/11/26.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import "TextCell.h"
#import "Masonry.h"

@interface TextCell()
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UIImageView *bubbleImageView;
@property (nonatomic, strong) UILabel *messageLabel;




@end


@implementation TextCell

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
        
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.font = [UIFont systemFontOfSize:12];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.layer.cornerRadius = 10;
        self.timeLabel.layer.masksToBounds = YES;
        self.timeLabel.backgroundColor = [UIColor colorWithRed:220/255.0f green:220/255.0f blue:220/255.0f alpha:1];
        self.timeLabel.alpha = 0.5;
        self.timeLabel.textColor = [UIColor colorWithRed:80/255.0f green:80/255.0f blue:80/255.0f alpha:1];
        [self.contentView addSubview:self.timeLabel];
        
        self.headerImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.headerImageView];
        
        self.bubbleImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:self.bubbleImageView];
        
        self.messageLabel = [[UILabel alloc] init];
        [self.bubbleImageView addSubview:self.messageLabel];
        
    }
    return self;
}

/*重写set方法*/
-(void)setMessage:(TextMessage *)message{
    _message = message;
    [self configWithMessage];
}

/*通过模型显示Cell*/
-(void)configWithMessage{
    
    //设置时间
    [self timeLabelSet];
    
    self.headerImageView.layer.cornerRadius = 25;
    self.headerImageView.layer.masksToBounds = YES;
    UIImage *image = [UIImage imageNamed:@"touxiang"];
    self.headerImageView.image = image;
    
    //获取字符串的显示尺寸
    NSDictionary *attrs = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
    CGSize  size = [self.message.text  boundingRectWithSize:CGSizeMake(SCREEN_WIDTH*0.5, 2000.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    
    if (self.message.direction == To) {
        //发出的消息的Cell显示
        self.headerImageView.frame = CGRectMake(SCREEN_WIDTH-55, 5+self.timeLabel.frame.size.height, 50, 50);
        
        
        UIImage *bubble = [UIImage imageNamed:@"chatto_bg"];
        bubble = [bubble stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
        self.bubbleImageView.image = bubble;
        self.bubbleImageView.frame = CGRectMake(SCREEN_WIDTH-65-size.width-30, 15+self.timeLabel.frame.size.height, size.width+30, size.height+20);
        

        self.messageLabel.frame = CGRectMake(10, 7.5, size.width+10, size.height+5);
        self.messageLabel.text = self.message.text;
        self.messageLabel.font = [UIFont systemFontOfSize:14];
        self.messageLabel.numberOfLines = 0;

        
    }else{
        //收到的消息的Cell显示
        self.headerImageView.frame = CGRectMake(5, 5+self.timeLabel.frame.size.height, 50, 50);
        
        UIImage *bubble = [UIImage imageNamed:@"chatfrom_bg"];
        bubble = [bubble stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
        self.bubbleImageView.image = bubble;
        self.bubbleImageView.frame = CGRectMake(65, 15+self.timeLabel.frame.size.height, size.width+30, size.height+20);
        
        self.messageLabel.frame = CGRectMake(12.5, 7.5, size.width+10, size.height+5);
        self.messageLabel.text = self.message.text;
        self.messageLabel.font = [UIFont systemFontOfSize:14];
        self.messageLabel.numberOfLines = 0;
     }
    self.userInteractionEnabled = NO;
}

/*时间显示*/
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


@end
