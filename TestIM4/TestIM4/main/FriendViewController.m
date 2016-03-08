//
//  FriendViewController.m
//  TestIM4
//
//  Created by Apple on 15/11/25.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import "FriendViewController.h"
#import "ChatViewController.h"
#import "Friend.h"
#import "XMPPManager.h"
#import "AppDelegate.h"
#import "TextMessage.h"
#import "ChatHistoryManager.h"
#import "ChatListManager.h"
#import "FriendManager.h"
#import <AudioToolbox/AudioToolbox.h>

@interface FriendViewController ()<UITableViewDataSource,UITableViewDelegate,XMPPStreamDelegate,XMPPRosterDelegate>

@property (nonatomic, strong) UITableView *tableView;
/*经过处理的好友数组*/
@property (nonatomic, strong) NSMutableArray *rosterArray;
/*请求到的好友数组*/
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation FriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNav];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createTableView];
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self prepareDataArray];
    [self xmppSetUP];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
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

//设置导航
#pragma mark 设置导航及其按钮方法
-(void)setNav{
    self.navigationItem.title = @"好友";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFriend:)];
}

-(void)addFriend:(UIButton *)btn{
    
}

#pragma mark 准备数据
-(void)prepareDataArray{
    self.dataArray = [NSMutableArray array];
    self.rosterArray = [NSMutableArray array];
}

#pragma mark 设置TableView
-(void)createTableView{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, 375, 667-64-49) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource =self;
    self.tableView.sectionIndexColor = [UIColor redColor];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
}


#pragma mark 设置XMPP
-(void)xmppSetUP{
    [[XMPPManager shareManager].xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    [[XMPPManager shareManager] xmppRosterSetUpWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    [[XMPPManager shareManager] xmppAvailable];
}

#pragma mark UITableView代理
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.rosterArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array = self.rosterArray[section];
    return array.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSArray *array = self.rosterArray[indexPath.section];
    Friend *friend = array[indexPath.row];
    cell.textLabel.text = friend.userName;
    cell.imageView.image = [UIImage imageNamed:@"touxiang"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatViewController *ctrl = [[ChatViewController alloc] init];
    NSArray *array = self.rosterArray[indexPath.section];
    Friend *friend = array[indexPath.row];
    ctrl.friend = [[[FriendManager alloc] init] friendWithUserName:friend.userName];
    //获取会话列表界面未读消息的数量
//    NSInteger count = self.navigationController.tabBarController.viewControllers.firstObject.tabBarItem.badgeValue.integerValue;
//    //遍历历史消息数据库获取即将置为已读的消息数量
//    ChatHistoryManager *manager = [[ChatHistoryManager alloc] init];
//    manager.friendName = array[indexPath.row];
//    NSArray *textArray = [manager selectedAllMessage];
//    NSInteger notReaded = 0;
//    for (TextMessage *message in textArray) {
//        if (message.readed == NO) {
//           notReaded++;
//        }
//    }
//    //聊天界面导航显示的未读消息的数量 = 会话列表界面未读消息的数量 - 历史消息数据库获取即将置为已读的消息数量（大于99置为99）
//    ctrl.noticeCount = (count-notReaded)<99?(count-notReaded):99;
    self.navigationController.tabBarController.tabBar.hidden = YES;
    [self.navigationController pushViewController:ctrl animated:YES];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSArray<Friend *> *array = self.rosterArray[section];
    NSString *str = [array.firstObject.userName substringToIndex:1];
    const char *A = [str UTF8String];
    if (((*A>90&&*A<97)||*A<65||*A>122)) {
        //数字和特殊符号头标题为"#"
        return @"#";
    }else{
        //字母头标题为其大写
        return [str uppercaseString];
    }
}

-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (self.rosterArray.count>0) {
        //设置索引同设置头标题
        NSMutableArray *array = [NSMutableArray array];
        for (NSArray<Friend *> *subArray in self.rosterArray) {
            NSString *str = nil;
            NSString *str1 = [subArray.firstObject.userName substringToIndex:1];
            const char *A = [str1 UTF8String];
            if (((*A>90&&*A<97)||*A<65||*A>122)) {
                str = @"#";
            }else{
                str = [str1 uppercaseString];
            }
            [array addObject:str];
            
        }
        return array;
    }
    return nil;
    
}


#pragma mark XMPPFramework代理


-(void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *jidStr = [[item attributeForName:@"jid"] stringValue];
        XMPPJID *jid = [XMPPJID jidWithString:jidStr];
        
        Friend *friend = [[Friend alloc] init];
        friend.userName = jid.user;
        friend.data = UIImagePNGRepresentation([UIImage imageNamed:@"touxiang"]);
        friend.weChat = @"weixin";
        friend.phoneNumber = @"14383838438";
        friend.changeState = None;

        //是否已经添加
        if ([self.dataArray containsObject:friend]) {
            return;
        }

        //将好友添加到数组中去
        [self.dataArray addObject:friend];
        [[[FriendManager alloc] init] addDataWithFriendModel:friend];
    });
    
}


-(void)xmppRosterDidEndPopulating:(XMPPRoster *)sender{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"userName" ascending:YES];
        NSMutableArray<Friend *> *array = [NSMutableArray array];
        //将好友列表按用户名顺序排序
        [array addObjectsFromArray:[self.dataArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd1]]];
        NSMutableArray *xArray = [NSMutableArray array];
        NSArray *lastArray = nil;
        //将排序好的列表按首字母存入好友数组
        while (array.count>0) {
            NSMutableArray<Friend *> *subArray = [NSMutableArray array];
            for (int i = 0; array.count>0 ; i=0) {
                if (subArray.count>0) {
                    NSString *str = subArray.firstObject.userName;
                    NSString *newStr = array[i].userName;
                    if ([[str substringToIndex:1] isEqualToString:[newStr substringToIndex:1]]) {
                        [subArray addObject:array[i]];
                        [array removeObject:array[i]];
                        lastArray = subArray;
                    }else{
                        const char *A = [[str substringToIndex:1] UTF8String];
                        const char *B = [[newStr substringToIndex:1] UTF8String];
                        if (((*A>90&&*A<97)||*A<65||*A>122)&&((*B>90&&*B<97)||*B<65||*B>122)) {
                            [subArray addObject:array[i]];
                            [array removeObject:array[i]];
                            lastArray = subArray;
                        }else{
                            const char *A = [[subArray.firstObject.userName substringToIndex:1] UTF8String];
                            if (((*A>90&&*A<97)||*A<65||*A>122)) {
                                [xArray addObjectsFromArray:subArray];
                                [array removeObject:array[i]];
                                lastArray = subArray;
                            }else{
                                [self.rosterArray addObject:subArray];
                            }
                            break;
                        }
                    }
                }else{
                    [subArray addObject:array[i]];
                    [array removeObjectAtIndex:0];
                    lastArray = subArray;
                }
            }
        }
        if (lastArray) {
            [self.rosterArray addObject:lastArray];
        }
        
        if (xArray.count>0) {
            [self.rosterArray addObject:xArray];
        }
        
        [self.tableView reloadData];
    });
    
 
    
   
}

-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSString *chatType = [message attributeStringValueForName:@"bodyType"];
    NSString *from = [message attributeStringValueForName:@"from"];
    NSString *userName = [from componentsSeparatedByString:@"@"].firstObject;
    //创建消息模型
    TextMessage *receiveMessage = [[TextMessage alloc] init];
    receiveMessage.direction = From;
    receiveMessage.readed = NO;
    receiveMessage.text = message.body;
    NSString *strDate = [message attributeStringValueForName:@"sendTime"];
    receiveMessage.time = strDate;
    //根据接收消息的类型设置消息模型类型
    if ([chatType isEqualToString:@"text"]) {
        receiveMessage.type = Text;
    }else if ([chatType isEqualToString:@"request"]){
        receiveMessage.type = Request;
        NSString *requestType = [message attributeStringValueForName:@"requestType"];
        if ([requestType isEqualToString:@"weChat"]) {
            receiveMessage.requestType = WeChat;
        }else{
            receiveMessage.requestType = Phone;
        }
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
                receiveMessage.text = [NSString stringWithFormat:@"对方同意了您的请求，\n对方的微信账号为%@",message.body];
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
                receiveMessage.text = [NSString stringWithFormat:@"对方同意了您的请求，\n对方的联系电话为为%@",message.body];
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
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //将消息模型存入对应用户的历史消息数据库
        ChatHistoryManager *historyManager = [[ChatHistoryManager alloc] init];
        historyManager.friendName = userName;
        [historyManager addDataWithTextMessage:receiveMessage];
        //将用户对应的会话在会话列表数据库中置前
        ChatListManager *listManager = [[ChatListManager alloc] init];
        Chat *model = [[Chat alloc] init];
        model.isTop =  [listManager chatIsTopWithUserName:userName];
        model.userName = userName;
        model.data = [[[FriendManager alloc] init] friendWithUserName:userName].data;
        [listManager addDataWithChatModel:model];
        //修改会话列表角标上未读消息的数量
        NSInteger count = [self.navigationController.tabBarController.viewControllers.firstObject.tabBarItem.badgeValue integerValue];
        count++;
        if (count) {
            self.navigationController.tabBarController.viewControllers.firstObject.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",count];
        }else{
            self.navigationController.tabBarController.viewControllers.firstObject.tabBarItem.badgeValue = nil;
        }
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    });
    
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
