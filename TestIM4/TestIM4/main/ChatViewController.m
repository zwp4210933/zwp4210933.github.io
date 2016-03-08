//
//  ChatViewController.m
//  TestIM4
//
//  Created by Apple on 15/11/25.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import "ChatViewController.h"
#import "ImageViewController.h"
#import "TextMessage.h"
#import "TextCell.h"
#import "RequestCell.h"
#import "ReplyCell.h"
#import "ImageCell.h"
#import "RedioCell.h"
#import "XMPPManager.h"
#import "MyUtil.h"
#import "Chat.h"
#import "ChatListManager.h"
#import "ChatHistoryManager.h"
#import "FriendManager.h"
#import "MJRefresh.h"
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "ChangeInfoView.h"
#import "Designer.h"
#import "DesignerView.h"
#import "AFNetworking.h"
#import "SDWebImageManager.h"
#import "ReplyView.h"
#import "MediaView.h"
#import "DXFaceView.h"
#import "ChatSettingViewController.h"
#import "VoiceConverter.h"

@interface ChatViewController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,XMPPStreamDelegate,RequestCellDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,AVAudioRecorderDelegate,RedioCellDelegate,ImageCellDelegate,AVAudioPlayerDelegate,ReplyViewDelegate,MediaViewDelegate,ReplyCellDelegete,UIAlertViewDelegate,DXFaceDelegate>


@property (nonatomic, strong) NSMutableArray<TextMessage *> *dataArray;
@property (nonatomic, strong) UITableView *tableView;
/*输入框背景界面*/
@property (nonatomic, strong) UIView *groundView;  
/*文本输入框*/
@property (nonatomic, strong) UITextView *textView;
/*表情视图*/
@property (nonatomic, strong) DXFaceView *faceView;
/*录音Label*/
@property (nonatomic, strong) UILabel *redioView;
/*快捷回复视图*/
@property (nonatomic, strong) ReplyView *replyView;
/*覆盖变暗视图*/
@property (nonatomic, strong) UIView *grayView;
/*提示录音视图*/
@property (nonatomic, strong) UIView *micView;
/*提示录音视图内动态变换图片的ImageView*/
@property (nonatomic, strong) UIImageView *micImageView;
/*下拉加载界面*/
@property (nonatomic, strong) MJRefreshNormalHeader *header;
/*显示消息数量*/
@property (nonatomic, assign) NSInteger messageCount;
/*顶部请求交换手机与微信界面*/
@property (nonatomic, strong) ChangeInfoView *topView;
/*底部多功能视图*/
@property (nonatomic, strong) MediaView *bottomView;
/*录音控件*/
@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
/*定时检测音量大小的定时器*/
@property (nonatomic, strong) NSTimer *timer;
/*录音名*/
@property (nonatomic, strong) NSString *voiceName;
/*录音播放控件*/
@property (nonatomic, strong) AVAudioPlayer *redioPlayer;
/*音频播放动画计时器*/
@property (nonatomic, strong) NSTimer *playTimer;
/*当前点击的联系方式*/
@property (nonatomic, strong) NSString *connectNumber;
/*最后播放的录音cell的indexpath*/
@property (nonatomic, strong) NSIndexPath *lastPlayedIndexPath;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.view.backgroundColor = [UIColor colorWithRed:231/255.0f green:239/255.0f blue:241/255.0f alpha:1];
    //初始化一个界面首次加载显示的消息数量为20
    self.messageCount = 20;

    [self setNav];
    //获取历史消息
    [self prepareDataArray];
    //若tableView的可滑动高度大于其本身的高度(即消息Cell溢出当前显示屏幕)，将table滑动至底部
    [self createTopView];
    [self createBottmView];
    [self createTextView];
    [self createTableView];
    [self createFaceView];
    [self createMicView];
    [self createGrayView];
    [self createReplyView];
    //添加键盘监视
    [self registerForKeyboardNotifications];
}

-(void)dealloc{
    //释放TableView头界面
    self.tableView.header = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //界面即将出现时设置xmpp
    [self xmppSetUP];
    
    //通过会话置顶情况设置置顶按钮的显示
//    BOOL isTop = [[[ChatListManager alloc] init] chatIsTopWithUserName:self.friend.userName];
//    if (isTop) {
//        [self.navRightBtn setTitle:@"已置顶" forState:UIControlStateNormal];
//    }else{
//        [self.navRightBtn setTitle:@"置顶" forState:UIControlStateNormal];
//    }
    

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //界面即将消失时取消该试图控制器对xmppStream的代理工作
    [[XMPPManager shareManager].xmppStream removeDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark 设置导航及其按钮方法
-(void)setNav{
    
    //设置导航颜色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:59/255.0f green:63/255.0f blue:74/255.0f alpha:1];
    
    //设置导航标题为会话对象的用户名
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*0.4, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:20];
    label.text = self.friend.userName;
    self.navigationItem.titleView = label;
    
    //左边返回按钮
    UIButton *navLeftBtn = [MyUtil createBtnFrame:CGRectMake(0, 0, 30, 30) title:nil bgImageName:@"fanhui" target:self action:@selector(goToChatList:)];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:navLeftBtn];
    self.navigationItem.leftBarButtonItem = item;
    
    //右边更多按钮
    UIButton *navRightBtn = [MyUtil createBtnFrame:CGRectMake(0, 0, 30, 30) title:nil bgImageName:@"more" target:self action:@selector(goToChatSetting:)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:navRightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

//显示更多视图
-(void)goToChatSetting:(UIButton *)btn{
    ChatSettingViewController *ctrl = [[ChatSettingViewController alloc] init];
    ctrl.friendName = self.friend.userName;
    [[XMPPManager shareManager] xmppUnavailable];
    [self.navigationController pushViewController:ctrl animated:YES];
}


//返回按钮功能实现
-(void)goToChatList:(UIBarButtonItem *)item{
    self.navigationController.tabBarController.tabBar.hidden = NO;
    self.navigationController.tabBarController.selectedIndex = 0;
    [self.navigationController popViewControllerAnimated:YES];
}

//准备数据
#pragma mark 准备数据
-(void)prepareDataArray{
    self.dataArray = [NSMutableArray array];
    //获取用户对应的历史消息数据库
    ChatHistoryManager *manager = [[ChatHistoryManager alloc] init];
    manager.friendName = self.friend.userName;
    //将数据库内所有消息的阅读状态设置为已读
    [manager updateAllMessageReaded];
    //获取全部历史消息
    NSMutableArray *allMessageArray = [NSMutableArray array];
    [allMessageArray addObjectsFromArray:[manager selectedAllMessage]];
    if (allMessageArray.count>self.messageCount) {
        //当全部历史消息的数量大于当前需要显示的消息数量时，取出最新的X条消息来初始化消息数组
        NSMutableArray *array = [NSMutableArray array];
        for (NSInteger i = allMessageArray.count-self.messageCount; i<allMessageArray.count; i++) {
            [array addObject:allMessageArray[i]];
        }
        self.dataArray = [NSMutableArray arrayWithArray:array];
        [self.tableView reloadData];
    }else{
        //当全部历史消息的数量小于等于当前需要显示的消息数量时，将全部历史消息加入消息数组
        self.dataArray = [NSMutableArray arrayWithArray:allMessageArray];
        [self.tableView reloadData];
        //并且修改加载更多消息界面的提示文字
        [self.header setTitle:@"没有更多了" forState:MJRefreshStateIdle];
        [self.header setTitle:@"没有更多了" forState:MJRefreshStatePulling];
        [self.header setTitle:@"没有更多了" forState:MJRefreshStateRefreshing];
    }
}

//设置TableView
#pragma mark 设置TableView及其手势方法
-(void)createTableView{
    //tableView的基本属性设置
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 104, SCREEN_WIDTH, SCREEN_HEIGHT-154) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:231/255.0f green:239/255.0f blue:241/255.0f alpha:1];
    [self.view addSubview:self.tableView ];
    [self.view sendSubviewToBack:self.tableView];
    if (self.tableView.contentSize.height>self.tableView.bounds.size.height) {
        [self tableviewGoToBottom];
    }

    //为tableView创建headerView
    Designer *model = [[Designer alloc] init];
    model.headerImageName = @"ren";
    model.name = @"张叶军";
    model.occupation = @"室内设计师";
    model.salary = @"30-50";
    model.place = @"杭州";
    model.time = @"1-2年";
    model.genger = @"女";
    model.styleArray = @[@"现代简约",@"古典简约",@"时尚简约"];
    model.characterArray = @[@"别具一格",@"匠心独具",@"认真负责",@"诙谐幽默",@"经验十足"];
    DesignerView *designerView = [[DesignerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 225) Modle:model];
    self.tableView.tableHeaderView = designerView;
    
    //创建下拉加载视图
    self.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(addHistory)];
    [self.header setTitle:@"下拉加载更早消息" forState:MJRefreshStateIdle];
    [self.header setTitle:@"松开手指开始加载" forState:MJRefreshStatePulling];
    [self.header setTitle:@"正在为您加载" forState:MJRefreshStateRefreshing];
    self.tableView.header = self.header;
    //为tableView添加点击手势，用于取消textView的第一响应状态
    UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelFirstResponder:)];
    [self.tableView addGestureRecognizer:g];

}
//下拉加载方法
-(void)addHistory{
    //每次加载20条
    self.messageCount+=20;
    [self prepareDataArray];
    [self.header endRefreshing];
    NSLog(@"%ld",self.dataArray.count);
}
//取消textView的第一响应状态
-(void)cancelFirstResponder:(UITapGestureRecognizer *)g{
    if ([self.textView isFirstResponder]) {
        [self.textView resignFirstResponder];
    }
    
    if (!self.faceView.hidden||!self.bottomView.hidden) {
        self.faceView.hidden = YES;
        self.bottomView.hidden = YES;
        UIButton *imageBtn = [self.groundView viewWithTag:500];
        [imageBtn setBackgroundImage:[UIImage imageNamed:@"tianjia"] forState:UIControlStateNormal];
        [UIView animateWithDuration:0.1   animations:^{
            self.groundView.frame = CGRectMake(0, SCREEN_HEIGHT-self.groundView.frame.size.height, SCREEN_WIDTH, self.groundView.frame.size.height);
        } completion:^(BOOL finished) {
            self.tableView.frame = CGRectMake(0, 64+self.topView.bounds.size.height , SCREEN_WIDTH , SCREEN_HEIGHT-self.groundView.frame.size.height-64-self.topView.bounds.size.height);
            if (self.tableView.contentSize.height>self.tableView.frame.size.height) {
                [self tableviewGoToBottom];
            }
        }];
    }
}


//将tableView滑到底部
-(void)tableviewGoToBottom{
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height -self.tableView.frame.size.height) animated:YES];
}

-(void)tableViewGoToTop{
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark 设置顶部交换联系方式视图
-(void)createTopView{
    WS(weakSelf);
    self.topView = [[ChangeInfoView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 40) FriendName:self.friend ChangeBlock:^(RequestType type) {
        //点击按钮触发的block
        FriendManager *friendManager = [[FriendManager alloc] init];
        ChangeState state = weakSelf.friend.changeState;
        
        //创建消息模型
        TextMessage *message = [[TextMessage alloc] init];
        message.readed = YES;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
        message.time =strDate;
        if (type == WeChat) {
            //点击微信按钮
            if (state == Weixin || state == All) {
                //如果已经交换过微信，则自动显示回复类消息，不经过网络
                message.direction = From;
                message.type = Reply;
                message.requestType = WeChat;
                message.text = [NSString stringWithFormat:@"%@的微信号为:%@",weakSelf.friend.userName,weakSelf.friend.weChat];
            }else{
                //如果没有交换过微信，则发送请求交换微信消息
                [[XMPPManager shareManager] xmppSendRequestType:type receiveName:weakSelf.friend.userName];
                message.direction = To;
                message.type = Request;
                message.text = @"微信";
                message.requestType = WeChat;
                [friendManager updateFriend:weakSelf.friend.userName WithWechatTime:strDate];
                //发送后修改UI显示
                [weakSelf.topView requestWithRequestType:WeChat];
            }
        }else{
            if (state == PhoneNumber || state == All) {
                //如果已经交换过手机，则自动显示回复类消息，不经过网络
                message.direction = From;
                message.requestType = Phone;
                message.type = Reply;
                message.text = [NSString stringWithFormat:@"%@的手机号为:%@",weakSelf.friend.userName,weakSelf.friend.phoneNumber];
            }else{
                 //如果没有交换过手机，则发送请求交换手机消息
                [[XMPPManager shareManager] xmppSendRequestType:type receiveName:weakSelf.friend.userName];
                message.direction = To;
                message.type = Request;
                message.text = @"手机";
                message.requestType = Phone;
                [friendManager updateFriend:weakSelf.friend.userName WithPhoneNumberTime:strDate];
                //发送后修改UI显示
                [weakSelf.topView requestWithRequestType:Phone];
            }

        }

        //将消息模型存入历史消息数据库
        ChatHistoryManager * historyManager = [[ChatHistoryManager alloc] init];
        historyManager.friendName = weakSelf.friend.userName;
        [historyManager addDataWithTextMessage:message];
        //将消息模型存入消息数组
        [weakSelf.dataArray addObject:message];
        [weakSelf.tableView reloadData];
        if (weakSelf.tableView.contentSize.height>weakSelf.tableView.frame.size.height) {
            [weakSelf tableviewGoToBottom];
        }
        //发出请求后将该会话置在会话列表最前
        ChatListManager *listManager = [[ChatListManager alloc] init];
        Chat *chat = [[Chat alloc] init];
        chat.userName = weakSelf.friend.userName;
        chat.isTop = [listManager chatIsTopWithUserName:weakSelf.friend.userName];
        chat.data = weakSelf.friend.data;
        [listManager addDataWithChatModel:chat];
    }];

    [self.view addSubview:self.topView];
}




//设置TextView
#pragma mark 设置TextView及其按钮方法
-(void)createTextView{
    WS(weakSelf);
    //创建输入栏
    self.groundView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 50)];
    self.groundView.backgroundColor = [UIColor colorWithRed:228/225.0f green:238/225.0f blue:245/225.0f alpha:1];
    self.groundView.layer.borderColor = [UIColor colorWithRed:190/255.0f green:190/255.0f blue:190/255.0f alpha:1].CGColor;
    self.groundView.layer.borderWidth = 1;
    [self.view addSubview:self.groundView];
    
    //创建切换文本与录音按钮
    UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [switchBtn setBackgroundImage:[UIImage imageNamed:@"maikefeng"] forState:UIControlStateNormal];
    [switchBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    switchBtn.tag = 400;
    [self.groundView addSubview:switchBtn];
    [switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.groundView).with.offset(10);
        make.left.equalTo(weakSelf.groundView).with.offset(25.0f/1242*SCREEN_WIDTH);
        make.height.equalTo(@(30));
        make.width.equalTo(switchBtn.mas_height);
    }];
    
    //创建调出发送图片界面按钮
    UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [imageBtn setBackgroundImage:[UIImage imageNamed:@"tianjia"] forState:UIControlStateNormal];
    [imageBtn addTarget:self action:@selector(callBottomView:) forControlEvents:UIControlEventTouchUpInside];
    imageBtn.tag = 500;
    [self.groundView addSubview:imageBtn];
    [imageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(switchBtn);
        make.right.equalTo(weakSelf.groundView).with.offset(-25.0f/1242*SCREEN_WIDTH);
        make.height.equalTo(switchBtn);
        make.width.equalTo(switchBtn);
    }];
    
    //创建调出发送表情界面按钮
    UIButton *expressionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [expressionBtn setBackgroundImage:[UIImage imageNamed:@"xiao"] forState:UIControlStateNormal];
    [expressionBtn addTarget:self action:@selector(callFaceView:) forControlEvents:UIControlEventTouchUpInside];
    [self.groundView addSubview:expressionBtn];
    [expressionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(switchBtn);
        make.right.mas_equalTo(imageBtn.mas_left).with.offset(-24.0f/1242*SCREEN_WIDTH);
        make.height.equalTo(switchBtn);
        make.width.equalTo(switchBtn);
        
    }];
    
    //创建textView
    self.textView = [[UITextView alloc] init];
    self.textView.layer.cornerRadius = 5;
    self.textView.layer.masksToBounds = YES;
    self.textView.layer.borderWidth = 1;
    self.textView.layer.borderColor = [UIColor colorWithRed:209/255.0f green:211/255.0f blue:212/255.0f alpha:1].CGColor;
    self.textView.backgroundColor = [UIColor whiteColor];
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:19];
    [self.groundView addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.groundView).with.offset(7);
        make.left.mas_equalTo(switchBtn.mas_right).with.offset(20.0f/1242*SCREEN_WIDTH);
        make.bottom.equalTo(weakSelf.groundView).with.offset(-7);
        make.right.mas_equalTo(expressionBtn.mas_left).with.offset(-20.0f/1242*SCREEN_WIDTH);
    }];
    

    
    
    
    
    //创建长按录音视图
    self.redioView = [[UILabel alloc] init];
    self.redioView.backgroundColor = [UIColor whiteColor];
    self.redioView.layer.cornerRadius = 3;
    self.redioView.layer.masksToBounds = YES;
    self.redioView.layer.borderWidth = 1;
    self.redioView.layer.borderColor = [UIColor colorWithRed:209/255.0f green:211/255.0f blue:212/255.0f alpha:1].CGColor;
    self.redioView.text = @"按住 说话";
    self.redioView.textAlignment = NSTextAlignmentCenter;
    self.redioView.hidden = YES;
    [self.groundView addSubview:self.redioView];
    [self.redioView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.groundView).with.offset(7);
        make.left.mas_equalTo(switchBtn.mas_right).with.offset(20.0f/1242*SCREEN_WIDTH);
        make.bottom.equalTo(weakSelf.groundView).with.offset(-7);
        make.right.mas_equalTo(expressionBtn.mas_left).with.offset(-20.0f/1242*SCREEN_WIDTH);

    }];
    
    //为长按录音视图添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(sendVoice:)];
    longPress.minimumPressDuration = 0.2;
    self.redioView.userInteractionEnabled = YES;
    [self.redioView addGestureRecognizer:longPress];

}

-(void)callBottomView:(UIButton *)btn{
    
    if (self.bottomView.hidden == YES) {
        [btn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        self.bottomView.hidden = NO;
        //当多媒体视图未显示时
        if ([self.textView isFirstResponder]) {
            [self.textView resignFirstResponder];
        }

        //如果输入栏当前处于录音模式，则修改为文字输入模式
        self.redioView.hidden = YES;
        self.textView.hidden = NO;
        UIButton *switchBtn = (UIButton *)[self.groundView viewWithTag:400];
        [switchBtn setBackgroundImage:[UIImage imageNamed:@"maikefeng"] forState:UIControlStateNormal];

        self.faceView.hidden = YES;
        //修改输入栏UI，显示多媒体视图
        [UIView animateWithDuration:0.1 animations:^{
            self.groundView.frame = CGRectMake(0, SCREEN_HEIGHT-self.groundView.frame.size.height-self.bottomView.bounds.size.height, SCREEN_WIDTH, self.groundView.frame.size.height);
            
        } completion:^(BOOL finished) {
            //修改tableView
            self.tableView.frame = CGRectMake(0, 104, SCREEN_WIDTH, SCREEN_HEIGHT-self.groundView.frame.size.height-self.bottomView.bounds.size.height-104);
            if (self.tableView.contentSize.height>self.tableView.frame.size.height) {
                [self tableviewGoToBottom];
            }
        }];
        
        
        
    }else{
        [UIView animateWithDuration:0.1 animations:^{
            //键盘隐藏后修改输入栏的位置
            self.groundView.frame = CGRectMake(0, SCREEN_HEIGHT-self.groundView.frame.size.height, SCREEN_WIDTH, self.groundView.frame.size.height);
            if (!self.bottomView.hidden) {
                self.bottomView.hidden = YES;
            }
        } completion:^(BOOL finished) {
            //修改tableView的位置
            self.tableView.frame = CGRectMake(0, 64+self.topView.bounds.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-64-self.groundView.frame.size.height-self.topView.bounds.size.height);
        }];
        [btn setBackgroundImage:[UIImage imageNamed:@"tianjia"] forState:UIControlStateNormal];
    }
    //如果多媒体视图已经显示则不作反应
}

//呼出表情键盘
-(void)callFaceView:(UIButton *)btn{
    if (self.faceView.hidden == YES) {
        self.faceView.hidden = NO;
        //如果输入栏当前处于录音模式，则修改为文字输入模式
        self.redioView.hidden = YES;
        self.textView.hidden = NO;
        UIButton *switchBtn = (UIButton *)[self.groundView viewWithTag:400];
        [switchBtn setBackgroundImage:[UIImage imageNamed:@"maikefeng"] forState:UIControlStateNormal];
        self.bottomView.hidden = YES;
        UIButton *imageBtn = [self.groundView viewWithTag:500];
        [imageBtn setBackgroundImage:[UIImage imageNamed:@"tianjia"] forState:UIControlStateNormal];
        if ([self.textView isFirstResponder]){
            [self.textView resignFirstResponder];
        }
        //调出键盘后改变输入栏和TableView的位置
        [UIView animateWithDuration:0.1 animations:^{
            self.groundView.frame = CGRectMake(0, SCREEN_HEIGHT-self.groundView.frame.size.height-self.faceView.frame.size.height, SCREEN_WIDTH, self.groundView.frame.size.height);
            self.faceView.frame = CGRectMake(0, SCREEN_HEIGHT-self.faceView.frame.size.height, self.faceView.frame.size.width, self.faceView.frame.size.height);
        } completion:^(BOOL finished) {
            self.tableView.frame = CGRectMake(0, 64+self.topView.bounds.size.height , SCREEN_WIDTH , SCREEN_HEIGHT-self.groundView.frame.size.height-self.faceView.frame.size.height-64-self.topView.bounds.size.height);
            if (self.tableView.contentSize.height>self.tableView.frame.size.height) {
                [self tableviewGoToBottom];
                self.bottomView.hidden = YES;
            }
        }];

    }
}

//文本与语音切换方法
-(void)switchAction:(UIButton *)btn{

    if (self.redioView.hidden) {
        //隐藏输入框和多媒体视图
        self.bottomView.hidden = YES;
        UIButton *imageBtn = [self.groundView viewWithTag:500];
        [imageBtn setBackgroundImage:[UIImage imageNamed:@"tianjia"] forState:UIControlStateNormal];
        self.faceView.hidden = YES;
        self.textView.hidden = YES;
        self.redioView.hidden = NO;
        [btn setBackgroundImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
        
        

            //若键盘显示，则取消输入框的第一响应者
            [self.textView resignFirstResponder];

            [UIView animateWithDuration:0.1 animations:^{
                self.groundView.frame = CGRectMake(0, SCREEN_HEIGHT-50, SCREEN_WIDTH, 50);
            } completion:^(BOOL finished) {
                //修改TableView
                self.tableView.frame = CGRectMake(0, 64+self.topView.bounds.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-64-self.groundView.frame.size.height-self.topView.bounds.size.height);
                
                
                
            }];


        
        
        
    }else{
        //如果当前为录音状态
        //根据当前输入框的内容长度，修改输入栏的UI
        NSDictionary *attrs = @{NSFontAttributeName:[UIFont systemFontOfSize:19]};
        CGSize  size = [self.textView.text  boundingRectWithSize:CGSizeMake(self.textView.bounds.size.width, 2000.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
        if (size.height>=38) {
            [UIView animateWithDuration:0.35 animations:^{
                self.groundView.frame = CGRectMake(0, self.groundView.frame.origin.y-38, SCREEN_WIDTH, self.groundView.bounds.size.height+38);
                self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.bounds.size.width, self.textView.bounds.size.height+38);
            }];
        }
        [btn setBackgroundImage:[UIImage imageNamed:@"maikefeng"] forState:UIControlStateNormal];
        self.redioView.hidden = YES;
        self.textView.hidden = NO;

        [self.textView becomeFirstResponder];
     }
}

-(void)sendMessage{
    if (self.textView.text.length>0) {
        //当textView内有内容时发送文本消息
        [[XMPPManager shareManager] xmppSendTextMessageWithText:self.textView.text receiveName:self.friend.userName];
        //创建文本类型的消息模型
        TextMessage *message = [[TextMessage alloc] init];
        message.text = self.textView.text;
        message.direction = To;
        message.type = Text;
        message.readed = YES;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
        message.time =strDate;
        //将文本消息存入历史消息数据库
        ChatHistoryManager * historyManager = [[ChatHistoryManager alloc] init];
        historyManager.friendName = self.friend.userName;
        [historyManager addDataWithTextMessage:message];
        
        [self.dataArray addObject:message];
        [self.tableView reloadData];
        if (self.tableView.contentSize.height>self.tableView.frame.size.height) {
            [self tableviewGoToBottom];
        }
        //将当前会话在会话记录数据库中置在最前
        ChatListManager *listManager = [[ChatListManager alloc] init];
        Chat *chat = [[Chat alloc] init];
        chat.userName = self.friend.userName;
        chat.isTop = [listManager chatIsTopWithUserName:self.friend.userName];
        chat.data = self.friend.data;
        [listManager addDataWithChatModel:chat];
        //清空texView内容
        self.textView.text = @"";
        //若textView处于加高状态，则变回原来的状态
        if (self.textView.frame.size.height>36) {
            self.groundView.frame = CGRectMake(0, self.groundView.frame.origin.y+38, SCREEN_WIDTH, 50);
            self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y,self.textView.bounds.size.width , 36);
        }
    }
}

-(void)sendVoice:(UILongPressGestureRecognizer *)longPress{
    UILabel *audioLable = (UILabel *)(longPress.view);
    audioLable.text = @"正在 录音";
    static int i = 1;
    self.micView.hidden = NO;
    self.micImageView.hidden = NO;
    UILabel *label = (UILabel *)[self.micView viewWithTag:300];
    //录音开始
    if (longPress.state == UIGestureRecognizerStateBegan){
        i = 1;
        self.redioView.backgroundColor = [UIColor grayColor];
        //录音初始化
        [self audioInit];
        //创建录音文件，准备录音
        if ([self.audioRecorder prepareToRecord]){
            //开始
            [self.audioRecorder record];
            //设置定时检测音量变化
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
        }
    }

    //取消录音
    if (longPress.state == UIGestureRecognizerStateChanged){
        
        CGPoint piont = [longPress locationInView:self.redioView];
        if (piont.y < -50){
            self.timer.fireDate = [NSDate distantFuture];
            self.redioView.backgroundColor = [UIColor whiteColor];
            self.micImageView.image = [UIImage imageNamed:@"cancelRecord"];
            label.backgroundColor = [UIColor colorWithRed:164/255.0f green:39/255.0f blue:48/255.0f alpha:1];
            label.font = [UIFont systemFontOfSize:15.0/375*SCREEN_WIDTH];
            label.text = @"松开手指,取消录音";
            i = 0;
        }else if(piont.y > 0){
            label.font = [UIFont systemFontOfSize:17];
            label.backgroundColor = [UIColor clearColor];
            self.timer.fireDate = [NSDate distantPast];
            self.redioView.backgroundColor = [UIColor grayColor];
            self.micImageView.hidden = NO;
            label.text = @"正在录音";
            i = 1;
        }
        
    }
    
    if (longPress.state == UIGestureRecognizerStateEnded) {
        
        if (i == 1){
            NSLog(@"录音结束");
            self.redioView.backgroundColor = [UIColor whiteColor];
            double time = self.audioRecorder.currentTime;
            if (time > 1&&time<=60){

                
                //创建语音类型的消息模型
                TextMessage *message = [[TextMessage alloc] init];
                message.text = self.voiceName;
                message.direction = To;
                message.type = Redio;
                message.readed = YES;
                message.played = YES;
                message.voiceLength = time;
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
                message.time =strDate;
                //将文本消息存入历史消息数据库
                ChatHistoryManager * historyManager = [[ChatHistoryManager alloc] init];
                historyManager.friendName = self.friend.userName;
                [historyManager addDataWithTextMessage:message];
                
                [self.dataArray addObject:message];
                [self.tableView reloadData];
                if (self.tableView.contentSize.height>self.tableView.frame.size.height) {
                    [self tableviewGoToBottom];
                }
                //将当前会话在会话记录数据库中置在最前
                ChatListManager *listManager = [[ChatListManager alloc] init];
                Chat *model = [[Chat alloc] init];
                model.userName = self.friend.userName;
                model.isTop = [listManager chatIsTopWithUserName:self.friend.userName];
                model.data = UIImagePNGRepresentation([UIImage imageNamed:@"touxiang"]);
                [listManager addDataWithChatModel:model];
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont systemFontOfSize:17];
                label.text = @"正在录音";
                self.micView.hidden = YES;
                
                //获取录音文件
                NSString *topPath =[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/ChatHistory/%@/%@/Audio",[XMPPManager shareManager].xmppStream.myJID.user,self.friend.userName]];
                if (![[NSFileManager defaultManager] fileExistsAtPath:topPath]) {
                    [[NSFileManager defaultManager] createDirectoryAtPath:topPath withIntermediateDirectories:YES attributes:nil error:nil];
                }
                if ([VoiceConverter ConvertWavToAmr:[NSString stringWithFormat:@"%@/%@.wav",topPath,self.voiceName] amrSavePath:[NSString stringWithFormat:@"%@/%@.amr",topPath,self.voiceName]]) {
                    NSData *audioData = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.amr",topPath,self.voiceName]];
                    //上传录音文件
                    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
                    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
                    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
                    NSString *fileName = [NSString stringWithFormat:@"%@.amr",self.voiceName];
                    [manager POST:UploadAudioURL parameters:nil  constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                        [formData appendPartWithFileData:audioData name:@"file" fileName:fileName mimeType:@"audio/amr"];
                    } success:^(NSURLSessionDataTask *task, id responseObject) {
                        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                        NSLog(@"%@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
                        NSDictionary *urlDic = dic[@"data"];
                        //上传成功后发送语音消息
                        if (urlDic[@"v"]) {
                            [[XMPPManager shareManager] xmppSendAudio:urlDic[@"v"] audioLength:time receiveName:self.friend.userName];
                            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@.amr",topPath,self.voiceName] error:nil];
                        }
                        
                        
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        //上传失败暂不做处理，保留操作
                    }];

                }
                
                
            }else{
                //删除记录的文件
                [self.audioRecorder deleteRecording];
                label.backgroundColor = [UIColor clearColor];
                label.font = [UIFont systemFontOfSize:12];
                label.text = @"录音时间少于1秒或者超过1分钟";
                [self performSelector:@selector(micViewHidden) withObject:nil afterDelay:1];
            }
            [self.audioRecorder stop];
        }else{
            [self.audioRecorder deleteRecording];
            [self.audioRecorder stop];
            label.backgroundColor = [UIColor clearColor];
            label.font = [UIFont systemFontOfSize:17];
            label.text = @"正在录音";
            self.micView.hidden = YES;
        }
        [_timer invalidate];
        audioLable.text = @"按住 说话";
    }
}

-(void)micViewHidden{
    UILabel *label = (UILabel *)[self.micView viewWithTag:300];
    self.micView.hidden = YES;
    label.font = [UIFont systemFontOfSize:17];
    label.text = @"正在录音";
    
}


//录音的音量探测,修改图片
- (void)detectionVoice{
    [self.audioRecorder updateMeters];//刷新音量数据
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];
    
    CGFloat lowPassResults = pow(10, (0.05 * [self.audioRecorder peakPowerForChannel:0]));
    
    //通过音量修改图片
    int index = (int)(lowPassResults*50)%7+1;
    [self.micImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"record_animate_0%d.png",index]]];
}

//初始化录音控件
-(void)audioInit
{
    NSError * err = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    
    [audioSession setActive:YES error:&err];
    
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %ld %@", [err domain], (long)[err code], [[err userInfo] description]);
        return;
    }
    
//    //通过可变字典进行配置项的加载
//    NSMutableDictionary *setAudioDic = [[NSMutableDictionary alloc] init];
//    
//    //设置录音格式(aac格式)
//    [setAudioDic setValue:@(kAudioFormatMPEG4AAC) forKey:AVFormatIDKey];
//    
//    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
//    [setAudioDic setValue:@(44100) forKey:AVSampleRateKey];
//    
//    //设置录音通道数1 Or 2
//    [setAudioDic setValue:@(2) forKey:AVNumberOfChannelsKey];
//    
//    //线性采样位数  8、16、24、32
//    [setAudioDic setValue:@(32) forKey:AVLinearPCMBitDepthKey];
//    //录音的质量
//    [setAudioDic setValue:@(AVAudioQualityHigh) forKey:AVEncoderAudioQualityKey];
    
    NSString *topPath =[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/ChatHistory/%@/%@/Audio",[XMPPManager shareManager].xmppStream.myJID.user,self.friend.userName]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:topPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:topPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fileName = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    self.voiceName = fileName;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@.wav",topPath,fileName]];
    NSLog(@"%@",[NSString stringWithFormat:@"%@/%@.wav",topPath,fileName]);
    NSError *error;
    //初始化
    self.audioRecorder = [[AVAudioRecorder alloc]initWithURL:url settings:[VoiceConverter GetAudioRecorderSettingDict] error:&error];
    //开启音量检测
    self.audioRecorder.meteringEnabled = YES;
    self.audioRecorder.delegate = self;
    
    //如果是真机,需要添加代码
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [session setActive:YES error:nil];
    
}

#pragma mark DXFaceView代理
-(void)sendFace{
    [self sendMessage];
}

-(void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete{
    NSMutableString *text = [NSMutableString stringWithString:self.textView.text];
    if (isDelete) {
        if (self.textView.text.length>=2) {
            NSRange range = {self.textView.text.length-2,2};
            [text deleteCharactersInRange:range];
        }else if(self.textView.text.length == 1){
            text = nil;
        }
        
    }else{
        [text appendString:str];
    }
    self.textView.text = text;
    NSDictionary *attrs = @{NSFontAttributeName:[UIFont systemFontOfSize:19]};
    CGSize  size = [self.textView.text  boundingRectWithSize:CGSizeMake(self.textView.bounds.size.width, 2000.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    if (size.height>=38) {
        if (self.textView.frame.size.height<74) {
            self.groundView.frame = CGRectMake(0, self.groundView.frame.origin.y-38, SCREEN_WIDTH, self.groundView.bounds.size.height+38);
            self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.bounds.size.width, self.textView.bounds.size.height+38);
        }
    }else{
        if (self.textView.frame.size.height>36) {
            self.groundView.frame = CGRectMake(0, self.groundView.frame.origin.y+38, SCREEN_WIDTH, self.groundView.bounds.size.height-38);
            self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.textView.frame.origin.y, self.textView.bounds.size.width, self.textView.bounds.size.height-38);
        }
    }

}

#pragma mark 创建底部多功能按钮
-(void)createBottmView{
    self.bottomView = [[MediaView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-100, SCREEN_WIDTH, 100)];
    self.bottomView.hidden = YES;
    self.bottomView.delegate = self;
    [self.view addSubview:self.bottomView];

}

#pragma mark 创建表情视图
-(void)createFaceView{
    self.faceView = [[DXFaceView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-200, SCREEN_WIDTH, 200)];
    self.faceView.delegate = self;
    self.faceView.backgroundColor = [UIColor whiteColor];
    self.faceView.hidden = YES;
    [self.view addSubview:self.faceView];
}

#pragma mark MediaViewDelegate
-(void)openAlbum{
    //打开相册
    [[XMPPManager shareManager] xmppUnavailable];
    UIImagePickerController *ctrl = [[UIImagePickerController alloc] init];
    ctrl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ctrl.delegate = self;

    [self presentViewController:ctrl animated:YES completion:nil];
}

-(void)takePhoto{
    //打开相机
    [[XMPPManager shareManager] xmppUnavailable];
    UIImagePickerController *ctrl = [[UIImagePickerController alloc] init];
    ctrl.sourceType = UIImagePickerControllerSourceTypeCamera;
    ctrl.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    ctrl.delegate = self;
    [self presentViewController:ctrl animated:YES completion:nil];
}

-(void)callReplayView{
    //显示快捷回复视图和覆盖变暗视图
    self.grayView.hidden = NO;
    self.replyView.hidden = NO;
}





#pragma mark UIImagePikerViewController代理方法
//点击取消按钮的时候调用
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [[XMPPManager shareManager] xmppAvailable];
}

//选择图片
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //获取选择的图片
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera){
        //如果为拍照模式，将拍摄的照片储存到相册
        UIImageWriteToSavedPhotosAlbum(image, self, nil, nil);
    }

    NSString *topPath =[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/ChatHistory/%@/%@/Image",[XMPPManager shareManager].xmppStream.myJID.user,self.friend.userName]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:topPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:topPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fileName = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.jpg",topPath,fileName];
    
    [UIImageJPEGRepresentation(image, 1) writeToFile:filePath atomically:YES];
    
    
    //创建图片类型的消息模型
    TextMessage *message = [[TextMessage alloc] init];
    message.text = fileName;
    message.direction = To;
    message.type = Image;
    message.readed = YES;
    message.imageSize = image.size;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    message.time =strDate;
    //将文本消息存入历史消息数据库
    ChatHistoryManager * historyManager = [[ChatHistoryManager alloc] init];
    historyManager.friendName = self.friend.userName;
    [historyManager addDataWithTextMessage:message];
    
    [self.dataArray addObject:message];
    [self.tableView reloadData];
    if (self.tableView.contentSize.height>self.tableView.frame.size.height) {
        [self tableviewGoToBottom];
    }
    //将当前会话在会话记录数据库中置在最前
    ChatListManager *listManager = [[ChatListManager alloc] init];
    Chat *model = [[Chat alloc] init];
    model.userName = self.friend.userName;
    model.isTop = [listManager chatIsTopWithUserName:self.friend.userName];
    model.data = UIImagePNGRepresentation([UIImage imageNamed:@"touxiang"]);
    [listManager addDataWithChatModel:model];
    
    //上传图片
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        image = [UIImage imageWithCGImage:image.CGImage scale:1 orientation:UIImageOrientationRight];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager POST:UploadImageURL parameters:nil  constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1) name:@"file" fileName:[NSString stringWithFormat:@"%@.jpg",fileName] mimeType:@"image/jpeg"];
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        //上传成功后解析返回值获取接口
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        NSLog(@"%@",[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        NSDictionary *urlDic = dic[@"data"];
        //发送图片消息
        [[XMPPManager shareManager] xmppSendLargeImage:urlDic[@"lkey"] smallImage:urlDic[@"skey"] imageSize:image.size receiveName:self.friend.userName];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //上传失败保留操作
        NSLog(@"图片上传失败");
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    [[XMPPManager shareManager] xmppAvailable];
}

#pragma mark 创建提示录音视图
-(void)createMicView{
    WS(weakSelf);
    self.micView = [[UIView alloc] init];
    self.micView.backgroundColor = [UIColor grayColor];
    self.micView.alpha = 0.8;
    self.micView.layer.cornerRadius = 10;
    self.micView.layer.masksToBounds = YES;
    [self.view addSubview:self.micView];
    [self.micView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).with.offset(367.0f/1242*SCREEN_WIDTH);
        make.right.equalTo(weakSelf.view).with.offset(-367.0f/1242*SCREEN_WIDTH);
        make.bottom.equalTo(weakSelf.view).with.offset(-900.0f/2208*SCREEN_HEIGHT);
        make.height.equalTo(weakSelf.micView.mas_width);
    }];
    
    self.micImageView = [[UIImageView alloc] init];
    self.micImageView.image = [UIImage imageNamed:@"record_animate_01"];
    [self.micView addSubview:self.micImageView];
    [self.micImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.micView).with.offset(40.0/375*SCREEN_WIDTH);
        make.right.equalTo(weakSelf.micView).with.offset(-40.0/375*SCREEN_WIDTH);
        make.top.equalTo(weakSelf.micView).with.offset(20.0f/375*SCREEN_WIDTH);
        make.height.equalTo(weakSelf.micImageView.mas_width).multipliedBy(154.0f/164);
    }];
    
    
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 155, 40)];
    textLabel.numberOfLines = 0;
    textLabel.text = @"正在录音";
    textLabel.textColor = [UIColor whiteColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.numberOfLines = 0;
    textLabel.tag = 300;
    [self.micView addSubview:textLabel];
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.micView).with.offset(10.0/375*SCREEN_WIDTH);
        make.right.equalTo(weakSelf.micView).with.offset(-10.0/375*SCREEN_WIDTH);
        make.bottom.equalTo(weakSelf.micView).with.offset(-12.0f/375*SCREEN_WIDTH);
        make.height.equalTo(@(30));
    }];
    self.micView.hidden = YES;
}

#pragma mark 创建快捷回复视图和覆盖变暗视图
-(void)createReplyView{
    self.replyView = [[ReplyView alloc] init];
    self.replyView.delegate = self;
    self.replyView.hidden = YES;
    [self.view addSubview:self.replyView];
    WS(weakSelf);
    [self.replyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).with.offset(49.0f/414*SCREEN_WIDTH);
        make.right.equalTo(weakSelf.view).with.offset(-49.0f/414*SCREEN_WIDTH);
        make.bottom.equalTo(weakSelf.view).with.offset(-797.0f/3);
        make.height.equalTo(@(794.0/2208*SCREEN_HEIGHT));
    }];
}

-(void)createGrayView{
    self.grayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT)];
    self.grayView.backgroundColor = [UIColor blackColor];
    self.grayView.alpha = 0.3;
    [self.view addSubview:self.grayView];
    self.grayView.hidden = YES;
}


#pragma mark ReplyView代理
-(void)sendQucikReply:(NSString *)reply{
    //当textView内有内容时发送文本消息
    [[XMPPManager shareManager] xmppSendTextMessageWithText:self.textView.text receiveName:self.friend.userName];
    //创建文本类型的消息模型
    TextMessage *message = [[TextMessage alloc] init];
    message.text = reply;
    message.direction = To;
    message.type = Text;
    message.readed = YES;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    message.time =strDate;
    //将文本消息存入历史消息数据库
    ChatHistoryManager * historyManager = [[ChatHistoryManager alloc] init];
    historyManager.friendName = self.friend.userName;
    [historyManager addDataWithTextMessage:message];
    
    [self.dataArray addObject:message];
    [self.tableView reloadData];
    if (self.tableView.contentSize.height>self.tableView.frame.size.height) {
        [self tableviewGoToBottom];
    }
    //将当前会话在会话记录数据库中置在最前
    ChatListManager *listManager = [[ChatListManager alloc] init];
    Chat *chat = [[Chat alloc] init];
    chat.userName = self.friend.userName;
    chat.isTop = [listManager chatIsTopWithUserName:self.friend.userName];
    chat.data = self.friend.data;
    [listManager addDataWithChatModel:chat];
    self.grayView.hidden = YES;
}

-(void)displayGrayView{
    //隐藏覆盖变暗视图
    self.grayView.hidden = YES;
}



#pragma mark 设置XMPP
-(void)xmppSetUP{
    [[XMPPManager shareManager].xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    [[XMPPManager shareManager] xmppAvailable];
}

#pragma mark XMPP代理方法
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
   //获取消息类型
    NSString *chatType = [message attributeStringValueForName:@"bodyType"];
    //创建消息模型
    TextMessage *receiveMessage = [[TextMessage alloc] init];
    receiveMessage.direction = From;
    NSString *strDate = [message attributeStringValueForName:@"sendTime"];
    receiveMessage.time = strDate;
    
    //获取消息来源用户名
    NSString *from = [message attributeStringValueForName:@"from"];
    NSString *userName = [from componentsSeparatedByString:@"@"].firstObject;

    //初始化消息文本为接收文本
    receiveMessage.text = message.body;
    if ([chatType isEqualToString:@"text"]) {
        //设置消息类型为文本，不修改消息文本
        receiveMessage.type = Text;
        if ([self.friend.userName isEqualToString:userName]) {
            //若消息来源为当前正在会话的用户，则设置消息的阅读状态为已读
            receiveMessage.readed = YES;
            //将消息消息模型加入当前会话的消息数组
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dataArray addObject:receiveMessage];
                [self.tableView reloadData];
                if (self.tableView.contentSize.height>self.tableView.frame.size.height) {
                    [self tableviewGoToBottom];
                }
                
                
            });
        }else{
            //若消息来源为其他用户，则设置消息的阅读状态为未读
            receiveMessage.readed = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                //            if (self.noticeCount<99) {
                //                self.noticeCount++;
                //                [self.navLeftBtn setTitle:[NSString stringWithFormat:@"会话(%ld)",self.noticeCount] forState:UIControlStateNormal];
                //            }
                //为来源用户刷新会话列表数据库
                ChatListManager *listManager = [[ChatListManager alloc] init];
                Chat *chat = [[Chat alloc] init];
                chat.userName = self.friend.userName;
                chat.isTop = [listManager chatIsTopWithUserName:self.friend.userName];
                chat.data = self.friend.data;
                [listManager addDataWithChatModel:chat];
            });
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //将消息模型存入历史消息数据库
            ChatHistoryManager *manager = [[ChatHistoryManager alloc] init];
            manager.friendName = userName;
            [manager addDataWithTextMessage:receiveMessage];
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        });

    }else if ([chatType isEqualToString:@"request"]){
        //设置消息类型为请求，根据接收文本设置消息的请求类型，不修改消息文本
        receiveMessage.type = Request;
        if ([message.body isEqualToString:@"微信"]) {
            receiveMessage.requestType = WeChat;
        }else{
            receiveMessage.requestType = Phone;
        }
        if ([self.friend.userName isEqualToString:userName]) {
            //若消息来源为当前正在会话的用户，则设置消息的阅读状态为已读
            receiveMessage.readed = YES;
            //将消息消息模型加入当前会话的消息数组
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dataArray addObject:receiveMessage];
                [self.tableView reloadData];
                if (self.tableView.contentSize.height>self.tableView.frame.size.height) {
                    [self tableviewGoToBottom];
                }
                
                
            });
        }else{
            //若消息来源为其他用户，则设置消息的阅读状态为未读
            receiveMessage.readed = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                //            if (self.noticeCount<99) {
                //                self.noticeCount++;
                //                [self.navLeftBtn setTitle:[NSString stringWithFormat:@"会话(%ld)",self.noticeCount] forState:UIControlStateNormal];
                //            }
                //为来源用户刷新会话列表数据库
                ChatListManager *listManager = [[ChatListManager alloc] init];
                Chat *chat = [[Chat alloc] init];
                chat.userName = self.friend.userName;
                chat.isTop = [listManager chatIsTopWithUserName:self.friend.userName];
                chat.data = self.friend.data;
                [listManager addDataWithChatModel:chat];
            });
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //将消息模型存入历史消息数据库
            ChatHistoryManager *manager = [[ChatHistoryManager alloc] init];
            manager.friendName = userName;
            [manager addDataWithTextMessage:receiveMessage];
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        });

    }else if ([chatType isEqualToString:@"reply"]){
        //设置消息类型为回复
        receiveMessage.type = Reply;
        BOOL agree = [message attributeBoolValueForName:@"agree"];
        if (agree) {
            //收到肯定回复时的设定
            NSString *requestType = [message attributeStringValueForName:@"requestType"];
            if ([requestType isEqualToString:@"weChat"]) {
                //根据传递消息的请求参数设置消息模型的请求类型为微信
                receiveMessage.requestType = WeChat;
                receiveMessage.text = [NSString stringWithFormat:@"%@的微信号为:%@",self.friend.userName,self.friend.weChat];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.topView agreeWithRequestType:WeChat];
                    FriendManager *friendManager = [[FriendManager alloc] init];
                    ChangeState oldState = [friendManager changeStateWithUserName:userName];
                    if (oldState == PhoneNumber) {
                        [friendManager updateFriend:userName WithChangeState:All];
                        self.friend.changeState = All;
                        self.topView.friend.changeState = All;
                    }else{
                        [friendManager updateFriend:userName WithChangeState:Weixin];
                        self.friend.changeState = Weixin;
                        self.topView.friend.changeState = Weixin;
                    }
                });

            }else{
                //根据传递消息的请求参数设置消息模型的请求类型为手机
                receiveMessage.requestType = Phone;
                receiveMessage.text = [NSString stringWithFormat:@"%@的微信号为:%@",self.friend.userName,self.friend.phoneNumber];

                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.topView agreeWithRequestType:Phone];
                    FriendManager *friendManager = [[FriendManager alloc] init];
                    ChangeState oldState = [friendManager changeStateWithUserName:userName];
                    if (oldState == Weixin) {
                        [friendManager updateFriend:userName WithChangeState:All];
                        self.friend.changeState = All;
                        self.topView.friend.changeState = All;
                    }else{
                        [friendManager updateFriend:userName WithChangeState:PhoneNumber];
                        self.friend.changeState = Weixin;
                        self.topView.friend.changeState = Weixin;
                    }
                });
            }
        }else{
            //收到否定回复时仅需要修改消息文本
            receiveMessage.text = @"很遗憾，对方拒绝了您的请求";
            NSString *requestType = [message attributeStringValueForName:@"requestType"];
            if ([requestType isEqualToString:@"weChat"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.topView refusedWithRequestType:WeChat];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.topView refusedWithRequestType:Phone];
                });
            }
        }
        if ([self.friend.userName isEqualToString:userName]) {
            //若消息来源为当前正在会话的用户，则设置消息的阅读状态为已读
            receiveMessage.readed = YES;
            //将消息消息模型加入当前会话的消息数组
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.dataArray addObject:receiveMessage];
                [self.tableView reloadData];
                if (self.tableView.contentSize.height>self.tableView.frame.size.height) {
                    [self tableviewGoToBottom];
                }
                
                
            });
        }else{
            //若消息来源为其他用户，则设置消息的阅读状态为未读
            receiveMessage.readed = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                //            if (self.noticeCount<99) {
                //                self.noticeCount++;
                //                [self.navLeftBtn setTitle:[NSString stringWithFormat:@"会话(%ld)",self.noticeCount] forState:UIControlStateNormal];
                //            }
                //为来源用户刷新会话列表数据库
                ChatListManager *listManager = [[ChatListManager alloc] init];
                Chat *chat = [[Chat alloc] init];
                chat.userName = self.friend.userName;
                chat.isTop = [listManager chatIsTopWithUserName:self.friend.userName];
                chat.data = self.friend.data;
                [listManager addDataWithChatModel:chat];
            });
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //将消息模型存入历史消息数据库
            ChatHistoryManager *manager = [[ChatHistoryManager alloc] init];
            manager.friendName = userName;
            [manager addDataWithTextMessage:receiveMessage];
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        });

    }else if ([chatType isEqualToString:@"image"]){
        receiveMessage.type = Image;
        //接收到图片类型的消息
        //获取小图接口
        NSString *url = [NSString stringWithFormat:@"%@%@",FileURL,[message attributeStringValueForName:@"sImage"]];
        NSLog(@"%@",url);
        //下载小图
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:url] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            //下载成功后将小图存入沙盒
            NSString *topPath =[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/ChatHistory/%@/%@/Image",[XMPPManager shareManager].xmppStream.myJID.user,userName]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:topPath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:topPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            NSString *fileName = [NSString stringWithFormat:@"RS%ld", (long)[[NSDate date] timeIntervalSince1970]];
            NSString *filePath = [NSString stringWithFormat:@"%@/%@.jpg",topPath,fileName];
            [UIImageJPEGRepresentation(image, 1) writeToFile:filePath atomically:YES];
            
            //设置图片消息的参数
            receiveMessage.sImgName = fileName;
            receiveMessage.imageSize = CGSizeMake([message attributeFloatValueForName:@"imageWidth"], [message attributeFloatValueForName:@"imageHeight"]);
            
            if ([self.friend.userName isEqualToString:userName]) {
                //若消息来源为当前正在会话的用户，则设置消息的阅读状态为已读
                receiveMessage.readed = YES;
                //将消息消息模型加入当前会话的消息数组
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.dataArray addObject:receiveMessage];
                    [self.tableView reloadData];
                    if (self.tableView.contentSize.height>self.tableView.frame.size.height) {
                        [self tableviewGoToBottom];
                    }
                    
                    
                });
            }else{
                //若消息来源为其他用户，则设置消息的阅读状态为未读
                receiveMessage.readed = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    //            if (self.noticeCount<99) {
                    //                self.noticeCount++;
                    //                [self.navLeftBtn setTitle:[NSString stringWithFormat:@"会话(%ld)",self.noticeCount] forState:UIControlStateNormal];
                    //            }
                    //为来源用户刷新会话列表数据库
                    ChatListManager *listManager = [[ChatListManager alloc] init];
                    Chat *chat = [[Chat alloc] init];
                    chat.userName = self.friend.userName;
                    chat.isTop = [listManager chatIsTopWithUserName:self.friend.userName];
                    chat.data = self.friend.data;
                    [listManager addDataWithChatModel:chat];
                });
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //将消息模型存入历史消息数据库
                ChatHistoryManager *manager = [[ChatHistoryManager alloc] init];
                manager.friendName = userName;
                [manager addDataWithTextMessage:receiveMessage];
                
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            });
            

        }];

    }else if ([chatType isEqualToString:@"audio"]){
        //接收到的消息为语音消息
        receiveMessage.type = Redio;
        //下载语音消息
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        //语音接口
        NSString *url = [NSString stringWithFormat:@"%@%@",FileURL,message.body];
         NSLog(@"%@",url);
        [manager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            //下载成功后将语音存入沙盒
            NSString *topPath =[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/ChatHistory/%@/%@/Audio",[XMPPManager shareManager].xmppStream.myJID.user,userName]];
            if (![[NSFileManager defaultManager] fileExistsAtPath:topPath]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:topPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            NSString *fileName = [NSString stringWithFormat:@"R%ld", (long)[[NSDate date] timeIntervalSince1970]];
            NSString *filePath = [NSString stringWithFormat:@"%@/%@.amr",topPath,fileName];
            [responseObject writeToFile:filePath atomically:YES];
            if([VoiceConverter ConvertAmrToWav:filePath wavSavePath:[NSString stringWithFormat:@"%@/%@.wav",topPath,fileName]]){
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                //设置语音消息参数
                receiveMessage.text = fileName;
                receiveMessage.voiceLength = [message attributeFloatValueForName:@"audioLength"];
                
                if ([self.friend.userName isEqualToString:userName]) {
                    //若消息来源为当前正在会话的用户，则设置消息的阅读状态为已读
                    receiveMessage.readed = YES;
                    //将消息消息模型加入当前会话的消息数组
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.dataArray addObject:receiveMessage];
                        [self.tableView reloadData];
                        if (self.tableView.contentSize.height>self.tableView.frame.size.height) {
                            [self tableviewGoToBottom];
                        }
                        
                        
                    });
                }else{
                    //若消息来源为其他用户，则设置消息的阅读状态为未读
                    receiveMessage.readed = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //            if (self.noticeCount<99) {
                        //                self.noticeCount++;
                        //                [self.navLeftBtn setTitle:[NSString stringWithFormat:@"会话(%ld)",self.noticeCount] forState:UIControlStateNormal];
                        //            }
                        //为来源用户刷新会话列表数据库
                        ChatListManager *listManager = [[ChatListManager alloc] init];
                        Chat *chat = [[Chat alloc] init];
                        chat.userName = self.friend.userName;
                        chat.isTop = [listManager chatIsTopWithUserName:self.friend.userName];
                        chat.data = self.friend.data;
                        [listManager addDataWithChatModel:chat];
                    });
                    
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //将消息模型存入历史消息数据库
                    ChatHistoryManager *manager = [[ChatHistoryManager alloc] init];
                    manager.friendName = userName;
                    [manager addDataWithTextMessage:receiveMessage];
                    
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                });
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"语音下载失败:%@",error);
        }];
    }
    
}

-(void)xmppStreamDidConnect:(XMPPStream *)sender{
    [[XMPPManager shareManager] xmppAuthenticateWithPassword:[[NSUserDefaults standardUserDefaults] objectForKey:@"password"]];
}

-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    [[XMPPManager shareManager] xmppAvailable];
}

-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    [[XMPPManager shareManager] xmppDisConnect];
}

#pragma mark UITableView代理方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    TextMessage *message = self.dataArray[indexPath.row];
    NSInteger height = 44;
    //根据不同的消息类型返回不同的Cell高度
    if (message.type == Text) {
        //文本消息还要根据文本长短动态设置高度
        NSDictionary *attrs = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
        CGSize  size = [message.text  boundingRectWithSize:CGSizeMake(SCREEN_WIDTH*0.5, 2000.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
        if (size.height>17) {
            height = size.height + 60;
        }else{
            height = 90;
        }
    }else if (message.type == Request){
        if (message.direction == To) {
            height = 90;
        }else{
            height = 120;
        }
    }else if (message.type == Reply){
        height = 93;
    }else if (message.type == Image){
        height = 175;
    }else{
        height = 100;
    }
    //根据消息时间动态设定高度
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *curDate = [NSDate date];
    NSDate *sendDate = [df dateFromString:message.time];
    NSTimeInterval time = [curDate timeIntervalSinceDate:sendDate];
    if (time <= 15 * 60) {
        //若消息时间与当前时间小于15分钟，Cell的时间Label被隐藏，则高度减去20
        height = height - 20 ;
    }
    return height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TextMessage *message = self.dataArray[indexPath.row];
    //根据不同类型的消息调用不同的Cell
    if (message.type == Text) {
        static NSString *textCellId = @"textCellId";
        TextCell *cell = [tableView dequeueReusableCellWithIdentifier:textCellId];
        if (nil == cell) {
            cell = [[TextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textCellId];
        }
        
        cell.message = message;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }else if (message.type == Request){
        static NSString *requestCellId = @"requestCellId";
        RequestCell *cell = [tableView dequeueReusableCellWithIdentifier:requestCellId];
        if (nil == cell) {
            cell = [[RequestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:requestCellId];
        }
        //请求类型的Cell要设置代理
        cell.delegate = self;
        cell.message = message;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }else if (message.type == Reply){
        static NSString *replyCellId = @"replyCellId";
        ReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:replyCellId];
        if (nil == cell) {
            cell = [[ReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:replyCellId];
        }
        cell.message = message;
        cell.delegate = self;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }else if (message.type == Image){
        static NSString *imageCellId = @"imageCellId";
        ImageCell *cell = [tableView dequeueReusableCellWithIdentifier:imageCellId];
        if (nil == cell) {
            cell = [[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:imageCellId];
        }
        [cell configWithMessage:message friendName:self.friend.userName];
        cell.backgroundColor = [UIColor clearColor];
        cell.delegate = self;
        return cell;

    }else{
        static NSString *redioCellId = @"redioCellId";
        RedioCell *cell = [tableView dequeueReusableCellWithIdentifier:redioCellId];
        if (nil == cell) {
            cell = [[RedioCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:redioCellId];
        }
        cell.indexPath = indexPath;
        cell.message = message;
        cell.delegate = self;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    return nil;
}

#pragma mark ImageCell代理方法
-(void)configDetailImageWithFileName:(NSString *)fileName Size:(CGSize)size{
    //点击图片查看大图
    ImageViewController *ctrl = [[ImageViewController alloc] init];
    ctrl.friendName = self.friend.userName;
    ctrl.fileName = fileName;
    [self presentViewController:ctrl animated:YES completion:^{
        [[XMPPManager shareManager] xmppUnavailable];
    }];
}

#pragma mark RedioCell代理方法
-(void)playRedioWithFileName:(NSString *)fileName indexPath:(NSIndexPath *)indexPath{
    if (self.lastPlayedIndexPath) {
        RedioCell *cell = (RedioCell *)[self.tableView cellForRowAtIndexPath:self.lastPlayedIndexPath];
        [cell.timer invalidate];
        [cell bubbleBecomeNormal];
    }
    
    //将播放的语音消息置为已播放
    for (TextMessage *message in self.dataArray) {
        if (message.type == Redio) {
            if ([message.text isEqualToString:fileName]) {
                message.played = YES;
            }
        }
    }
    
    //在消息数据库中更新语音消息的播放状态
    ChatHistoryManager *manager = [[ChatHistoryManager alloc] init];
    manager.friendName = self.friend.userName;
    [manager updateRedioMessagePlayedWithFileName:fileName];
    
    //获取语音路径
    NSString *topPath =[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/ChatHistory/%@/%@/Audio",[XMPPManager shareManager].xmppStream.myJID.user,self.friend.userName]];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.wav",topPath,fileName];
    NSLog(@"%@",filePath);
    NSURL *url = [NSURL URLWithString:filePath];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    //默认情况下扬声器播放
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    delegate.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    delegate.player.delegate = self;
    //通过红外感应设置扬声器与听筒播放
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if(![self isHeadsetPluggedIn]){
        [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    }
    //添加监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    [delegate.player play];
    
    self.lastPlayedIndexPath = indexPath;
}



//处理监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    }
    else
    {
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}


-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}

#pragma mark RequestCell代理方法
-(void)replyRequset:(BOOL)agree requestType:(RequestType)type{
    //初始化历史消息数据库
    ChatHistoryManager *manager = [[ChatHistoryManager alloc] init];
    manager.friendName = self.friend.userName;
    //创建回复类型的消息模型
    TextMessage *receiveMessage = [[TextMessage alloc] init];
    receiveMessage.direction = To;
    receiveMessage.type = Reply;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    receiveMessage.time = strDate;
    receiveMessage.readed = YES;
    if (agree) {
        //肯定回复根据请求类型修改朋友数据库的交换微信状态
        if(type == WeChat){
            FriendManager *friendManager = [[FriendManager alloc] init];
            ChangeState oldState = [friendManager changeStateWithUserName:self.friend.userName];
            if (oldState == PhoneNumber) {
                [friendManager updateFriend:self.friend.userName WithChangeState:All];
                self.friend.changeState = All;
                self.topView.friend.changeState = All;
            }else{
                [friendManager updateFriend:self.friend.userName WithChangeState:Weixin];
                self.friend.changeState = Weixin;
                self.topView.friend.changeState = Weixin;
            }
            receiveMessage.text = [NSString stringWithFormat:@"%@的微信号为:%@",self.friend.userName,self.friend.weChat];
            receiveMessage.requestType = WeChat;

        }else{
            FriendManager *friendManager = [[FriendManager alloc] init];
            ChangeState oldState = [friendManager changeStateWithUserName:self.friend.userName];
            if (oldState == Weixin) {
                [friendManager updateFriend:self.friend.userName WithChangeState:All];
                self.friend.changeState = All;
                self.topView.friend.changeState = All;
            }else{
                [friendManager updateFriend:self.friend.userName WithChangeState:PhoneNumber];
                self.friend.changeState = PhoneNumber;
                self.topView.friend.changeState = PhoneNumber;
            }
            receiveMessage.text = [NSString stringWithFormat:@"%@的手机号为:%@",self.friend.userName,self.friend.phoneNumber];
            receiveMessage.requestType = Phone;
        }
        [self.topView agreeWithRequestType:type];
    }else{
        //否定回复直接设置文本
        receiveMessage.text = @"您拒绝了对方的请求";
        [self.topView recoverWithRequestType:type];
    }
    //将回复消息模型加入消息数组
    [self.dataArray addObject:receiveMessage];
    for (TextMessage *model in self.dataArray) {
        if (model.type == Request && model.direction == From && model.requestType == type) {
            model.replyed = YES;
        }
    };
    //将回复消息模型加入历史消息数据库
    [manager addDataWithTextMessage:receiveMessage];
    //将请求消息的回复状态改为已回复
    [manager updateRequestMessageReplyedWithRequset:type];
    [self.tableView reloadData];
    if (self.tableView.contentSize.height>self.tableView.frame.size.height) {
        [self tableviewGoToBottom];
    }
    //发送回复消息
    [[XMPPManager shareManager] xmppReplyRequest:agree receiveName:self.friend.userName requestType:type];
}


#pragma mark ReplyCell代理
-(void)takeConnectionWay:(NSString *)connectText requestType:(RequestType)type{
    self.connectNumber = connectText;
    if (type == WeChat) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"需要将对方的微信号复制到剪贴板吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
        alert.tag = 1000;
        [alert show];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"想做什么呢" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"复制到剪贴板",@"打电话",@"发短信", nil];
        alert.tag = 2000;
        [alert show];
    }
}

#pragma mark AlertView 代理


-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 1000) {
        if (buttonIndex == 1) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = self.connectNumber;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"完成" message:@"对方的微信号已复制要您的剪贴板" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            [alert show];
        }
    }else if (alertView.tag == 2000){
        if (buttonIndex == 1) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = self.connectNumber;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"完成" message:@"对方的手机号已复制要您的剪贴板" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            [alert show];
        }else if (buttonIndex == 2){
            //调用电话
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",self.connectNumber]]];
        }else if (buttonIndex == 3){
            //调用短信
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"sms://%@",self.connectNumber]]];
        }
    }
}

#pragma mark 监听键盘高度
- (void) registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification *) notif
{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    
    NSLog(@"keyBoard:%f", keyboardSize.height);  //216
    CGFloat keyboardHeight = keyboardSize.height;
    if (self.replyView.hidden) {
        //调出键盘后改变输入栏和TableView的位置
        [UIView animateWithDuration:0.1 animations:^{
            self.groundView.frame = CGRectMake(0, SCREEN_HEIGHT-self.groundView.frame.size.height-keyboardHeight, SCREEN_WIDTH, self.groundView.frame.size.height);
        } completion:^(BOOL finished) {
            self.tableView.frame = CGRectMake(0, 64+self.topView.bounds.size.height , SCREEN_WIDTH , SCREEN_HEIGHT-self.groundView.frame.size.height-keyboardHeight-64-self.topView.bounds.size.height);
            if (self.tableView.contentSize.height>self.tableView.frame.size.height) {
                [self tableviewGoToBottom];
                self.bottomView.hidden = YES;
            }
        }];
     }
}

-(void)keyboardWasHidden:(NSNotification *) notif{
    if (self.bottomView.hidden&&self.faceView.hidden) {
        [UIView animateWithDuration:0.3   animations:^{
            self.groundView.frame = CGRectMake(0, SCREEN_HEIGHT-self.groundView.frame.size.height, SCREEN_WIDTH, self.groundView.frame.size.height);
        } completion:^(BOOL finished) {
            self.tableView.frame = CGRectMake(0, 64+self.topView.bounds.size.height , SCREEN_WIDTH , SCREEN_HEIGHT-self.groundView.frame.size.height-64-self.topView.bounds.size.height);
            if (self.tableView.contentSize.height>self.tableView.frame.size.height) {
                [self tableviewGoToBottom];
            }
        }];

    }
}

#pragma mark UITextView代理方法
-(void)textViewDidBeginEditing:(UITextView *)textView{
    UIButton *btn = (UIButton *)[self.groundView viewWithTag:500];
    [btn setBackgroundImage:[UIImage imageNamed:@"tianjia"] forState:UIControlStateNormal];
    self.bottomView.hidden = YES;
    self.faceView.hidden = YES;
}

-(void)textViewDidChange:(UITextView *)textView{
    //更具textView内的文本改变textView的宽度
    NSDictionary *attrs = @{NSFontAttributeName:[UIFont systemFontOfSize:19]};
    CGSize  size = [textView.text  boundingRectWithSize:CGSizeMake(textView.bounds.size.width, 2000.0f) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    if (size.height>=38) {
        if (textView.frame.size.height<74) {
            self.groundView.frame = CGRectMake(0, self.groundView.frame.origin.y-38, SCREEN_WIDTH, self.groundView.bounds.size.height+38);
            textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.bounds.size.width, textView.bounds.size.height+38);
        }
    }else{
        if (textView.frame.size.height>36) {
            self.groundView.frame = CGRectMake(0, self.groundView.frame.origin.y+38, SCREEN_WIDTH, self.groundView.bounds.size.height-38);
            textView.frame = CGRectMake(textView.frame.origin.x, textView.frame.origin.y, textView.bounds.size.width, textView.bounds.size.height-38);
        }
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self sendMessage];
        return NO;
    }
    return YES;
}


- (BOOL)isHeadsetPluggedIn{
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}
@end
