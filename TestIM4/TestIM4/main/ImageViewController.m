//
//  ImageViewController.m
//  TestIM4
//
//  Created by Apple on 15/12/5.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import "ImageViewController.h"
#import "ChatHistoryManager.h"
#import "XMPPManager.h"
#import "DetailImageCell.h"

#define kCellId (@"cellId")

@interface ImageViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,DetailImageCellDelegate,XMPPStreamDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, assign) NSInteger count;

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self xmppSetUp];
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self prepareDataArray];
    [self createCollectionView];
    [self createCountLabel];
    
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

#pragma mark 获取全部图片消息
-(void)prepareDataArray{
    ChatHistoryManager *manager = [[ChatHistoryManager alloc] init];
    manager.friendName = self.friendName;
    self.dataArray = [NSMutableArray arrayWithArray:[manager selectedAllImageMessage]];
}

#pragma mark 创建顶部计数Label
-(void)createCountLabel{
    self.count = 1;
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, 20)];
    self.countLabel.font = [UIFont systemFontOfSize:15];
    self.countLabel.font = [UIFont boldSystemFontOfSize:15];
    self.countLabel.textColor = [UIColor whiteColor];
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    for (TextMessage *message in self.dataArray) {
        if ([self.fileName isEqualToString:message.text]) {
            break;
        }else{
            self.count++;
        }
    }
    self.countLabel.text = [NSString stringWithFormat:@"%ld/%ld",self.count,self.dataArray.count];
    [self.view addSubview:self.countLabel];
}

#pragma mark 创建CollectionView;
-(void)createCollectionView{
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //布局对象
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.itemSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.bounces = NO;
    //注册Cell
    [self.collectionView registerClass:[DetailImageCell class] forCellWithReuseIdentifier:kCellId];
    //将CollectionView偏移到用户所需要查看的图片
    NSInteger count = 1;
    for (TextMessage *message in self.dataArray) {
        if ([self.fileName isEqualToString:message.text]) {
            break;
        }else{
            count++;
        }
    }
    self.collectionView.contentOffset = CGPointMake(self.collectionView.bounds.size.width*(count-1), 0);
    
    [self.view addSubview:self.collectionView];
}

#pragma mark collectionView代理
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DetailImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellId forIndexPath:indexPath];
    cell.delegate = self;
    TextMessage *message = self.dataArray[indexPath.item];
    [cell configWithImageName:message.text imageSize:message.imageSize selfName:[XMPPManager shareManager].xmppStream.myJID.user friendName:self.friendName];
    return cell;
}

-(void)xmppStreamDidConnect:(XMPPStream *)sender{
    [[XMPPManager shareManager] xmppAuthenticateWithPassword:[[NSUserDefaults standardUserDefaults] objectForKey:@"password"]];
}

-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    [[XMPPManager shareManager] xmppDisConnect];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index = scrollView.contentOffset.x/scrollView.bounds.size.width;
    self.countLabel.text = [NSString stringWithFormat:@"%ld/%ld",index+1,self.dataArray.count];
    self.count = index+1;
}

#pragma mark DemailCell代理
-(void)goBackToLastCtrl{
    [[XMPPManager shareManager].xmppStream removeDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    [self dismissViewControllerAnimated:YES completion:^{
        [[XMPPManager shareManager] xmppAvailable];
    }];
}




@end
