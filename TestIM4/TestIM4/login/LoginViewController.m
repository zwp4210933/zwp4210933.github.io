//
//  LoginViewController.m
//  TestIM4
//
//  Created by Apple on 15/11/24.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import "LoginViewController.h"
#import "SignInViewController.h"
#import "XMPPManager.h"
#import "AppDelegate.h"


@interface LoginViewController ()<XMPPStreamDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *warmLabel;
- (IBAction)userLogin:(id)sender;
- (IBAction)userForgetPassword:(id)sender;
- (IBAction)userSignIn:(id)sender;


@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelFirstResponder:)];
    [self.view addGestureRecognizer:g];
}

-(void)viewWillAppear:(BOOL)animated{
    [self xmmpStreamSetUp];
    [self autoAuthenticate];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[XMPPManager shareManager].xmppStream removeDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
}

-(void)xmmpStreamSetUp{
    [[XMPPManager shareManager].xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
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

- (IBAction)userLogin:(id)sender {
    [[XMPPManager shareManager] xmppConnectWithUserName:self.userNameTextField.text];
}

- (IBAction)userForgetPassword:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"傻了吧" message:@"自己忘了密码找我干嘛╮(￣▽￣)╭再注册一个靠谱" delegate:nil cancelButtonTitle:@"日了狗了" otherButtonTitles:nil, nil];
    [alertView show];
}

- (IBAction)userSignIn:(id)sender {
    [[XMPPManager shareManager].xmppStream removeDelegate:self delegateQueue:dispatch_get_main_queue()];
    SignInViewController *signInView = [[SignInViewController alloc] init];
    [self presentViewController:signInView animated:YES completion:nil];
}

//自动登录
-(void)autoAuthenticate{
    NSUserDefaults *userDefult =[NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefult objectForKey:@"username"];
    NSString *password = [userDefult objectForKey:@"password"];
    NSLog(@"%@,%@",userName,password);
    self.userNameTextField.text = userName;
    self.passwordTextField.text = password;
    if (userName != nil && password != nil && ![userName isEqualToString:@""] && ![password isEqualToString:@""])
    {
        [[XMPPManager shareManager] xmppConnectWithUserName:userName];

    }

}

//取消第一响应手势方法
-(void)cancelFirstResponder:(UITapGestureRecognizer *)g{
    if ([self.userNameTextField isFirstResponder]) {
        [self.userNameTextField resignFirstResponder];
    }
    if ([self.passwordTextField isFirstResponder]) {
        [self.passwordTextField resignFirstResponder];
    }
}



#pragma mark XMPPFramework代理方法
-(void)xmppStreamDidConnect:(XMPPStream *)sender{
    [[XMPPManager shareManager] xmppAuthenticateWithPassword:self.passwordTextField.text];
}

-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSUserDefaults *userDefult = [NSUserDefaults standardUserDefaults];
    [userDefult setObject:self.userNameTextField.text forKey:@"username"];
    [userDefult setObject:self.passwordTextField.text forKey:@"password"];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    delegate.weixin = @"As***Sho";
    delegate.mobilePhone = @"139****2319";
    dispatch_async(dispatch_get_main_queue(), ^{
        // 1.获取Main.storyboard的第一个控制器
        id vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
        // 2.切换window的根控制器
        [UIApplication sharedApplication].keyWindow.rootViewController = vc;
    });
    
    
}

-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    self.warmLabel.text = @"账号或者密码错误";
    self.warmLabel.hidden = NO;
    NSLog(@"账号或者密码错误");
    [[XMPPManager shareManager].xmppStream disconnect];
}




@end
