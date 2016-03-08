//
//  ChatListViewController.m
//  TestIM4
//
//  Created by Apple on 15/11/25.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import "ChatListViewController.h"
#import "XMPPManager.h"
#import "MyUtil.h"
#import "ChatListManager.h"
#import "FriendManager.h"
#import "ChatCell.h"
#import "Chat.h"
#import "ChatViewController.h"
#import "ChatHistoryManager.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "SDWebImageManager.h"
#import <AudioToolbox/AudioToolbox.h>

@interface ChatListViewController ()<UITableViewDataSource,UITableViewDelegate,XMPPStreamDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<Chat *> *> *dataArray;
/*未读消息数量*/
@property (nonatomic, assign)NSInteger messageCount;


@end

@implementation ChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:231/255.0f green:239/255.0f blue:241/255.0f alpha:1];
    [self setNav];
    [self createTableView];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[XMPPManager shareManager].xmppStream removeDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self prepareDataArray];
    [self.tableView reloadData];
    [self xmppSetUP];
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

#pragma mark xmpp设置
-(void)xmppSetUP{
    [[XMPPManager shareManager].xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    [[XMPPManager shareManager] xmppAvailable];
}

#pragma mark 设置导航及其按钮方法的实现
-(void)setNav{
    //设置导航标题为会话对象的用户名
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*0.4, 20)];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:20];
    label.text = @"消息";
    self.navigationItem.titleView = label;
    //设置导航颜色
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:39/255.0f green:33/255.0f blue:40/255.0f alpha:1];
//    //创建注销按钮
//    UIButton *btn =[MyUtil createBtnFrame:CGRectMake(0, 0, 60, 30) title:@"注销" bgImageName:nil target:self action:@selector(UserlogOut:)];
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
//    self.navigationItem.rightBarButtonItem = item;

}

//注销方法实现
-(void)UserlogOut:(UIButton *)btn{
    [[XMPPManager shareManager] xmppDisConnect];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
    dispatch_async(dispatch_get_main_queue(), ^{
        // 1.获取Main.storyboard的第一个控制器
        id vc = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateInitialViewController];
        
        // 2.切换window的根控制器
        [UIApplication sharedApplication].keyWindow.rootViewController = vc;
    });
}

#pragma mark 准备数据数组
-(void)prepareDataArray{
    self.dataArray = [NSMutableArray array];
    //未读消息置0
    self.messageCount = 0;
    self.dataArray = [NSMutableArray array];
    Chat *chat = [[Chat alloc] init];
    chat.data = UIImagePNGRepresentation([UIImage imageNamed:@"tishi"]);
    chat.userName = @"kenya";
    NSMutableArray *array = [NSMutableArray arrayWithObject:chat];
    [self.dataArray addObject:array];
    //获取会话列表数据库的全部会话
    [self.dataArray addObject:[NSMutableArray arrayWithArray:[[[ChatListManager alloc] init] selectedAllChatModel]]];
}

#pragma mark 创建TableView
-(void)createTableView{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 375, 667-64-49) style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource =self;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 60, 0, 0);
    [self.view addSubview:self.tableView];
}



#pragma mark -UITableView代理方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray[section].count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 72;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"chatCellId";
    ChatCell *cell  = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[ChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }

    Chat *model = self.dataArray[indexPath.section][self.dataArray[indexPath.section].count-1-indexPath.row];
    [cell configWithChat:model];
    if (indexPath.section == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.numberLabel.hidden = YES;
    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    //设置未读消息数
    if (indexPath.section == 1) {
        self.messageCount = self.messageCount + cell.notReadedCount;
        if (self.messageCount) {
            self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",self.messageCount];
        }else{
            self.navigationController.tabBarItem.badgeValue = nil;
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        ChatViewController *ctrl = [[ChatViewController alloc] init];
        Chat *model = self.dataArray[1][self.dataArray[1].count-1-indexPath.row];
        ctrl.friend = [[[FriendManager alloc] init] friendWithUserName:model.userName];
        //    ChatCell *cell =[tableView cellForRowAtIndexPath:indexPath];
        //    //聊天界面导航显示的未读消息的数量 = 会话列表界面未读消息的数量 - 对应Cell即将被置为已读的未读消息数（大于99置为99）
        //    ctrl.noticeCount = (self.messageCount-cell.notReadedCount)<99?(self.messageCount-cell.notReadedCount):99;
        self.navigationController.tabBarController.tabBar.hidden = YES;
        [self.navigationController pushViewController:ctrl animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        Chat *model = self.dataArray[indexPath.section][self.dataArray[indexPath.section].count-1-indexPath.row];
        
        [[[ChatListManager alloc] init] removeDataWithUserName:model.userName];
        
        NSMutableArray *array = self.dataArray[1];
        [array removeObject:model];
        
        [self.tableView reloadData];
    }
    
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除会话";
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return @"最近联系的人";
    }
    return nil;
}

#pragma mark XMPP代理方法


-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSString *chatType = [message attributeStringValueForName:@"bodyType"];
    NSString *from = [message attributeStringValueForName:@"from"];
    NSString *userName = [from componentsSeparatedByString:@"@"].firstObject;
    //创建消息模型
    TextMessage *receiveMessage = [[TextMessage alloc] init];
    receiveMessage.text = message.body;
    receiveMessage.direction = From;
    NSString *strDate = [message attributeStringValueForName:@"sendTime"];
    receiveMessage.time = strDate;
    receiveMessage.readed = NO;
    //根据接收消息的类型设置消息模型类型
    if ([chatType isEqualToString:@"text"]) {
        receiveMessage.type = Text;
        dispatch_async(dispatch_get_main_queue(), ^{
            //将消息模型存入对应用户的历史消息数据库
            ChatHistoryManager *historyManager = [[ChatHistoryManager alloc] init];
            historyManager.friendName = userName;
            [historyManager addDataWithTextMessage:receiveMessage];
            
            Friend *friend = [[Friend alloc] init];
            friend.userName = userName;
            friend.data = UIImagePNGRepresentation([UIImage imageNamed:@"touxiang"]);
            friend.weChat = @"weixin";
            friend.phoneNumber = @"14383838438";
            friend.changeState = None;
            
            [[[FriendManager alloc] init] addDataWithFriendModel:friend];
            
            //将用户对应的会话在会话列表数据库中置前
            ChatListManager *listManager = [[ChatListManager alloc] init];
            Chat *model = [[Chat alloc] init];
            model.isTop =  [listManager chatIsTopWithUserName:userName];
            model.userName = userName;
            model.data = [[[FriendManager alloc] init] friendWithUserName:userName].data;
            [listManager addDataWithChatModel:model];
            
            [self prepareDataArray];
            [self.tableView reloadData];
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        });
    }else if ([chatType isEqualToString:@"request"]){
        NSLog(@"%@",message);
        receiveMessage.type = Request;
        NSString *requestType = [message attributeStringValueForName:@"requestType"];
        if ([requestType isEqualToString:@"weChat"]) {
            receiveMessage.requestType = WeChat;
        }else{
            receiveMessage.requestType = Phone;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //将消息模型存入对应用户的历史消息数据库
            ChatHistoryManager *historyManager = [[ChatHistoryManager alloc] init];
            historyManager.friendName = userName;
            [historyManager addDataWithTextMessage:receiveMessage];
            
            Friend *friend = [[Friend alloc] init];
            friend.userName = userName;
            friend.data = UIImagePNGRepresentation([UIImage imageNamed:@"touxiang"]);
            friend.weChat = @"weixin";
            friend.phoneNumber = @"14383838438";
            friend.changeState = None;
            
            [[[FriendManager alloc] init] addDataWithFriendModel:friend];
            
            //将用户对应的会话在会话列表数据库中置前
            ChatListManager *listManager = [[ChatListManager alloc] init];
            Chat *model = [[Chat alloc] init];
            model.isTop =  [listManager chatIsTopWithUserName:userName];
            model.userName = userName;
            model.data = [[[FriendManager alloc] init] friendWithUserName:userName].data;
            [listManager addDataWithChatModel:model];
            
            [self prepareDataArray];
            [self.tableView reloadData];
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        });
    }else if ([chatType isEqualToString:@"reply"]){
        //设置消息类型为回复
        receiveMessage.type = Reply;
        BOOL agree = [message attributeBoolValueForName:@"agree"];
        if (agree) {
            //收到肯定回复时的设定
            NSString *requestType = [message attributeStringValueForName:@"requestType"];
            receiveMessage.text = @"对方同意了你的请求";
            if ([requestType isEqualToString:@"weChat"]) {
                //根据传递消息的请求参数设置消息模型的请求类型为微信
                receiveMessage.requestType = WeChat;
                dispatch_async(dispatch_get_main_queue(), ^{
                    FriendManager *friendManager = [[FriendManager alloc] init];
                    ChangeState oldState = [friendManager changeStateWithUserName:userName];
                    if (oldState == PhoneNumber) {
                        [friendManager updateFriend:userName WithChangeState:All];
                    }else{
                        [friendManager updateFriend:userName WithChangeState:Weixin];
                    }
                });
             }else{
                //根据传递消息的请求参数设置消息模型的请求类型为手机
                receiveMessage.requestType = Phone;
                dispatch_async(dispatch_get_main_queue(), ^{
                    FriendManager *friendManager = [[FriendManager alloc] init];
                    ChangeState oldState = [friendManager changeStateWithUserName:userName];
                    if (oldState == Weixin) {
                        [friendManager updateFriend:userName WithChangeState:All];
                    }else{
                        [friendManager updateFriend:userName WithChangeState:PhoneNumber];
                    }
                });
             }
        }else{
            //收到否定回复时仅需要修改消息文本
            receiveMessage.text = @"很遗憾，对方拒绝了您的请求";
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //将消息模型存入对应用户的历史消息数据库
            ChatHistoryManager *historyManager = [[ChatHistoryManager alloc] init];
            historyManager.friendName = userName;
            [historyManager addDataWithTextMessage:receiveMessage];
            
            Friend *friend = [[Friend alloc] init];
            friend.userName = userName;
            friend.data = UIImagePNGRepresentation([UIImage imageNamed:@"touxiang"]);
            friend.weChat = @"weixin";
            friend.phoneNumber = @"14383838438";
            friend.changeState = None;
            
            [[[FriendManager alloc] init] addDataWithFriendModel:friend];
            
            //将用户对应的会话在会话列表数据库中置前
            ChatListManager *listManager = [[ChatListManager alloc] init];
            Chat *model = [[Chat alloc] init];
            model.isTop =  [listManager chatIsTopWithUserName:userName];
            model.userName = userName;
            model.data = [[[FriendManager alloc] init] friendWithUserName:userName].data;
            [listManager addDataWithChatModel:model];
            
            [self prepareDataArray];
            [self.tableView reloadData];
            
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
            dispatch_async(dispatch_get_main_queue(), ^{
                //将消息模型存入对应用户的历史消息数据库
                ChatHistoryManager *historyManager = [[ChatHistoryManager alloc] init];
                historyManager.friendName = userName;
                [historyManager addDataWithTextMessage:receiveMessage];
                
                Friend *friend = [[Friend alloc] init];
                friend.userName = userName;
                friend.data = UIImagePNGRepresentation([UIImage imageNamed:@"touxiang"]);
                friend.weChat = @"weixin";
                friend.phoneNumber = @"14383838438";
                friend.changeState = None;
                
                [[[FriendManager alloc] init] addDataWithFriendModel:friend];
                
                //将用户对应的会话在会话列表数据库中置前
                ChatListManager *listManager = [[ChatListManager alloc] init];
                Chat *model = [[Chat alloc] init];
                model.isTop =  [listManager chatIsTopWithUserName:userName];
                model.userName = userName;
                model.data = [[[FriendManager alloc] init] friendWithUserName:userName].data;
                [listManager addDataWithChatModel:model];
                
                [self prepareDataArray];
                [self.tableView reloadData];
                
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
            NSString *filePath = [NSString stringWithFormat:@"%@/%@.acc",topPath,fileName];
            [responseObject writeToFile:filePath atomically:YES];
            //设置语音消息参数
            receiveMessage.text = fileName;
            receiveMessage.voiceLength = [message attributeFloatValueForName:@"audioLength"];
  
            dispatch_async(dispatch_get_main_queue(), ^{
                //将消息模型存入对应用户的历史消息数据库
                ChatHistoryManager *historyManager = [[ChatHistoryManager alloc] init];
                historyManager.friendName = userName;
                [historyManager addDataWithTextMessage:receiveMessage];
                
                Friend *friend = [[Friend alloc] init];
                friend.userName = userName;
                friend.data = UIImagePNGRepresentation([UIImage imageNamed:@"touxiang"]);
                friend.weChat = @"weixin";
                friend.phoneNumber = @"14383838438";
                friend.changeState = None;
                
                [[[FriendManager alloc] init] addDataWithFriendModel:friend];
                
                //将用户对应的会话在会话列表数据库中置前
                ChatListManager *listManager = [[ChatListManager alloc] init];
                Chat *model = [[Chat alloc] init];
                model.isTop =  [listManager chatIsTopWithUserName:userName];
                model.userName = userName;
                model.data = [[[FriendManager alloc] init] friendWithUserName:userName].data;
                [listManager addDataWithChatModel:model];
                
                [self prepareDataArray];
                [self.tableView reloadData];
                
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            });
            
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

@end
