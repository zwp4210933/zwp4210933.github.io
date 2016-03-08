//
//  ChatSettingViewController.m
//  TestIM4
//
//  Created by Apple on 16/1/8.
//  Copyright © 2016年 lanjue. All rights reserved.
//

#import "ChatSettingViewController.h"
#import "ChatSettingCell.h"
#import "ChatListManager.h"
#import "XMPPManager.h"
#import "ChatHistoryViewController.h"

@interface ChatSettingViewController ()<UITableViewDataSource,UITableViewDelegate,ChatSettingCellDelegate,XMPPStreamDelegate>

@property (nonatomic, strong) NSArray<NSArray *>  *dataArray;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *reportView;
@property (nonatomic, strong) UIView *grayView;

@end

@implementation ChatSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:231/255.0f green:239/255.0f blue:241/255.0f alpha:1];
    [self setNav];
    [self xmppSetUp];
    [self prepareDataArray];
    [self createTabelView];
    [self createGrayView];
    [self createReportView];
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
    label.text = @"聊天设置";
    self.navigationItem.titleView = label;
    
    //左边返回按钮
    UIButton *navLeftBtn = [MyUtil createBtnFrame:CGRectMake(0, 0, 30, 30) title:nil bgImageName:@"fanhui" target:self action:@selector(goToChatView:)];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:navLeftBtn];
    self.navigationItem.leftBarButtonItem = item;
}

-(void)goToChatView:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
    [[XMPPManager shareManager] xmppAvailable];
}

#pragma mark 准备数据
-(void)prepareDataArray{
    self.dataArray = @[@[@"置顶聊天",@"查看历史聊天记录"],@[@"将对方加入黑名单",@"举报对方"]];
}

#pragma mark 创建举报视图
-(void)createReportView{
    self.reportView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 433)];
    [self.view addSubview:self.reportView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    titleLabel.text = @"举报对方";
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.textColor = [UIColor colorWithRed:151/255.0f green:197/255.0f blue:68/255.0f alpha:1];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.reportView addSubview:titleLabel];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, 1)];
    line.backgroundColor = [UIColor grayColor];
    [self.reportView addSubview:line];
    
    NSArray *textArray = @[@"广告",@"色情",@"违法/政治敏感内容",@"欺诈",@"侮辱诋毁",@"侵权举报（诽谤、抄袭、冒用）"];
    for (int i = 0; i<textArray.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(0, 51+52*i, SCREEN_WIDTH, 51);
        btn.backgroundColor = [UIColor whiteColor];
        btn.tag = 300 + i;
        btn.titleLabel.font = [UIFont systemFontOfSize:18];
        [btn setTitle:textArray[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:101/255.0f green:101/255.0f blue:101/255.0f alpha:1] forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(reportAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.reportView addSubview:btn];
        
        UIView *grayLine = [[UIView alloc] initWithFrame:CGRectMake(0, 102+52*i, SCREEN_WIDTH, 1)];
        grayLine.backgroundColor = [UIColor grayColor];
        [self.reportView addSubview:grayLine];
    }
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.frame = CGRectMake(0, 378, SCREEN_WIDTH, 55);
    cancelBtn.backgroundColor = [UIColor whiteColor];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor colorWithRed:151/255.0f green:197/255.0f blue:68/255.0f alpha:1] forState:UIControlStateNormal];
    
    [cancelBtn addTarget:self action:@selector(cancelReport:) forControlEvents:UIControlEventTouchUpInside];
    [self.reportView addSubview:cancelBtn];

}

-(void)reportAction:(UIButton *)btn{
    [self cancelReport:btn];
}

-(void)cancelReport:(UIButton *)btn{
    [UIView animateWithDuration:0.35 animations:^{
        self.reportView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 433);
    } completion:^(BOOL finished) {
        self.grayView.hidden = YES;
    }];
}

#pragma mark 创建灰色覆盖视图
-(void)createGrayView{
    self.grayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.grayView.backgroundColor = [UIColor blackColor];
    self.grayView.alpha = 0.3;
    self.grayView.hidden = YES;
    [self.view addSubview:self.grayView];
}

#pragma mark 创建TableView
-(void)createTabelView{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
}

#pragma mark TableView代理
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray[section].count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"chatSetId";
    ChatSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[ChatSettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.textLabel.text = self.dataArray[indexPath.section][indexPath.row];
    if (indexPath.row == 1) {
        [cell showSwitch:NO on:NO];
    }else{
        cell.delegate = self;
        cell.indexPath = indexPath;
        if (indexPath.section == 0) {
            [cell showSwitch:YES on:[[[ChatListManager alloc] init] chatIsTopWithUserName:self.friendName]];
        }else{
            [cell showSwitch:YES on:NO];
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        if (indexPath.section == 0) {
            ChatHistoryViewController *ctrl = [[ChatHistoryViewController alloc] init];
            ctrl.friendName = self.friendName;
            [self.navigationController pushViewController:ctrl animated:YES];
        }else{
            [UIView animateWithDuration:0.35 animations:^{
                self.reportView.frame = CGRectMake(0, SCREEN_HEIGHT-self.reportView.bounds.size.height, SCREEN_WIDTH, self.reportView.bounds.size.height);
            } completion:^(BOOL finished) {
                self.grayView.hidden = NO;
            }];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark ChatSettingCell代理
-(void)switchActionWitnOn:(BOOL)on indexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        [[[ChatListManager alloc] init] makeTop:on UserName:self.friendName];
    }else{
        
    }
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
