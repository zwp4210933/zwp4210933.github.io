//
//  ChatSettingCell.m
//  TestIM4
//
//  Created by Apple on 16/1/8.
//  Copyright © 2016年 lanjue. All rights reserved.
//

#import "ChatSettingCell.h"
#import "ChatListManager.h"

@interface ChatSettingCell()

@property (nonatomic, strong) UISwitch *switchView;
@property (nonatomic, strong) UIImageView *enterImageView;

@end

@implementation ChatSettingCell

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
        
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        WS(weakSelf);
        _switchView = [[UISwitch alloc] init];
        _switchView.onTintColor = [UIColor colorWithRed:151/255.0f green:197/255.0f blue:68/255.0f alpha:1];
        [_switchView addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:_switchView];
        [_switchView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.contentView).with.offset(7);
            make.right.equalTo(weakSelf.contentView).with.offset(-35.0f/3);
            make.bottom.equalTo(weakSelf.contentView).with.offset(-7);
            make.width.equalTo(@(60));
        }];
        
        _enterImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"enter_green"]];
        [self.contentView addSubview:_enterImageView];
        [_enterImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.contentView).with.offset(12);
            make.right.equalTo(weakSelf.contentView).with.offset(-35);
            make.bottom.equalTo(weakSelf.contentView).with.offset(-12);
            make.width.equalTo(_enterImageView.mas_height).multipliedBy(15.0/27);
        }];
    }
    return self;
}


-(void)showSwitch:(BOOL)show on:(BOOL)isOn{
    self.switchView.hidden = !show;
    self.switchView.on = isOn;
    self.enterImageView.hidden = show;
    
    if (show) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
}

-(void)switchAction:(UISwitch *)switchView{
    [self.delegate switchActionWitnOn:switchView.on indexPath:self.indexPath];
}

@end
