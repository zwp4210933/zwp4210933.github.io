//
//  mainTabBarController.m
//  TestIM4
//
//  Created by Apple on 15/11/25.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import "mainTabBarController.h"
#import "MyUtil.h"

@interface mainTabBarController ()

@property (nonatomic, strong)NSArray *viewControllerArray;
@property (nonatomic, strong)NSArray *nameArray;
@property (nonatomic, strong)NSArray *imageArray;


@end

@implementation mainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self prepareViewControllerArray];
    [self prepareSubViewController];
    
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

#pragma mark 准备数据数组
-(void)prepareViewControllerArray{
    self.viewControllerArray = @[@"ChatListViewController",@"FriendViewController"];
    self.imageArray = @[@"7-01",@"8-01"];
    self.nameArray = @[@"聊天",@"好友"];
}

#pragma mark 创建TabBar控制的试图控制器
-(void)prepareSubViewController{
    NSMutableArray *ctrlArray = [NSMutableArray array];
    for (int i = 0; i<self.viewControllerArray.count;i++) {
        NSString *ctrlName = self.viewControllerArray[i];
        Class class = NSClassFromString(ctrlName);
        UIViewController *ctrl = [[class alloc] init];
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:ctrl];
        navCtrl.tabBarItem.image = [[UIImage imageNamed:self.imageArray[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        navCtrl.tabBarItem.selectedImage = [MyUtil changeImage:[UIImage imageNamed:self.imageArray[i]] withColor:[UIColor colorWithRed:111/255.0f green:174/255.0f blue:206/255.0f alpha:1]];
        navCtrl.tabBarItem.title = self.nameArray[i];
        [ctrlArray addObject:navCtrl];
    }
    self.viewControllers = ctrlArray;
}

@end
