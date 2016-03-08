//
//  ChatHistoryViewController.m
//  TestIM4
//
//  Created by Apple on 16/1/8.
//  Copyright © 2016年 lanjue. All rights reserved.
//

#import "ChatHistoryViewController.h"
#import "ChatHistoryManager.h"
#import "TextCell.h"
#import "RequestCell.h"
#import "ReplyCell.h"
#import "ImageCell.h"
#import "RedioCell.h"
#import "ImageViewController.h"
#import "XMPPManager.h"
#import "AppDelegate.h"


@interface ChatHistoryViewController ()<UITableViewDataSource,UITableViewDelegate,RedioCellDelegate,RequestCellDelegate,ImageCellDelegate,AVAudioPlayerDelegate,XMPPStreamDelegate,ReplyCellDelegete>

@property (nonatomic, strong) NSArray  *dataArray;
@property (nonatomic, strong) UITableView *tableView;
/*当前点击的联系方式*/
@property (nonatomic, strong) NSString *connectNumber;

@end

@implementation ChatHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    self.view.backgroundColor = [UIColor colorWithRed:231/255.0f green:239/255.0f blue:241/255.0f alpha:1];
    [self xmppSetUp];
    [self setNav];
    [self prepareDataArray];
    [self createTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[XMPPManager shareManager].xmppStream removeDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark 设置代理
-(void)xmppSetUp{
    [[XMPPManager shareManager].xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
}

#pragma mark 设置导航
-(void)setNav{
    //设置导航颜色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:59/255.0f green:63/255.0f blue:74/255.0f alpha:1];
    
    //设置导航标题为会话对象的用户名
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*0.4, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:20];
    label.text = @"聊天记录";
    self.navigationItem.titleView = label;
    
    //左边返回按钮
    UIButton *navLeftBtn = [MyUtil createBtnFrame:CGRectMake(0, 0, 30, 30) title:nil bgImageName:@"fanhui" target:self action:@selector(goToChatView:)];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:navLeftBtn];
    self.navigationItem.leftBarButtonItem = item;
}

-(void)goToChatView:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}

//准备数据
#pragma mark 准备数据
-(void)prepareDataArray{
    self.dataArray = [NSMutableArray array];
    //获取用户对应的历史消息数据库
    ChatHistoryManager *manager = [[ChatHistoryManager alloc] init];
    NSLog(@"%@",self.friendName);
    manager.friendName = self.friendName;
    self.dataArray = [manager selectedAllMessage];
}

//设置TableView
#pragma mark 设置TableView及其手势方法
-(void)createTableView{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:231/255.0f green:239/255.0f blue:241/255.0f alpha:1];
    [self.view addSubview:self.tableView ];
    [self.view sendSubviewToBack:self.tableView];
    if (self.tableView.contentSize.height>self.tableView.bounds.size.height) {
        [self tableviewGoToBottom];
    }
    
}

//将tableView滑到底部
-(void)tableviewGoToBottom{
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentSize.height -self.tableView.bounds.size.height) animated:YES];
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
        NSLog(@"%f",size.height);
        if (size.height>17) {
            height = size.height + 50;
        }else{
            height = 80;
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
        height = 90;
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
        [cell configWithMessage:message friendName:self.friendName];
        cell.backgroundColor = [UIColor clearColor];
        cell.delegate = self;
        return cell;
        
    }else{
        static NSString *redioCellId = @"redioCellId";
        RedioCell *cell = [tableView dequeueReusableCellWithIdentifier:redioCellId];
        if (nil == cell) {
            cell = [[RedioCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:redioCellId];
        }
        cell.message = message;
        cell.delegate = self;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    return nil;
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

#pragma mark ImageCell代理方法
-(void)configDetailImageWithFileName:(NSString *)fileName Size:(CGSize)size{
    ImageViewController *ctrl = [[ImageViewController alloc] init];
    ctrl.friendName = self.friendName;
    ctrl.fileName = fileName;
    [self presentViewController:ctrl animated:YES completion:^{
        [[XMPPManager shareManager] xmppUnavailable];
    }];
}

#pragma mark RedioCell代理方法
-(void)playRedioWithFileName:(NSString *)fileName{
    for (TextMessage *message in self.dataArray) {
        if (message.type == Redio) {
            if ([message.text isEqualToString:fileName]) {
                message.played = YES;
            }
        }
    }
    
    ChatHistoryManager *manager = [[ChatHistoryManager alloc] init];
    manager.friendName = self.friendName;
    [manager updateRedioMessagePlayedWithFileName:fileName];
    
    NSString *topPath =[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/ChatHistory/%@/%@/Audio",[XMPPManager shareManager].xmppStream.myJID.user,self.friendName]];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.acc",topPath,fileName];
    NSLog(@"%@",filePath);
    NSURL *url = [NSURL URLWithString:filePath];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    delegate.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    delegate.player.delegate = self;
    //初始化播放器的时候如下设置
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
                            sizeof(sessionCategory),
                            &sessionCategory);
    
    UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,
                             sizeof (audioRouteOverride),
                             &audioRouteOverride);
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //默认情况下扬声器播放
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    //添加监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
    [delegate.player play];
}

#pragma mark RequestCell代理
-(void)replyRequset:(BOOL)agree requestType:(RequestType)type{
    
}

#pragma mark XMPP代理
-(void)xmppStreamDidConnect:(XMPPStream *)sender{
    [[XMPPManager shareManager] xmppAuthenticateWithPassword:[[NSUserDefaults standardUserDefaults] objectForKey:@"password"]];
}

-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    [[XMPPManager shareManager] xmppAvailable];
}

-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    [[XMPPManager shareManager] xmppDisConnect];
}


@end
