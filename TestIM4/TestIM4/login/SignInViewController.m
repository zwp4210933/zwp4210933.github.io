//
//  SignInViewController.m
//  TestIM4
//
//  Created by Apple on 15/11/23.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import "SignInViewController.h"
#import "XMPPManager.h"
#import "AppDelegate.h"

#define MY_DOMAIN (@"app.gafear.com")

@interface SignInViewController ()<UIAlertViewDelegate,XMPPStreamDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *surePasswordTextField;
@property (weak, nonatomic) IBOutlet UILabel *warmLabel;
@property (weak, nonatomic) IBOutlet UIView *signInView;
- (IBAction)userSignIn:(id)sender;
- (IBAction)backToLogin:(id)sender;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //添加取消键盘的点击手势
    
    UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelFirstResponder:)];
    [self.view addGestureRecognizer:g];
    
    self.signInView.layer.cornerRadius = 10;
    self.signInView.layer.masksToBounds = YES;
    
    [self xmppStreamSetUp];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
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


//注册xmppStream
-(void)xmppStreamSetUp{
    [[XMPPManager shareManager].xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
}


- (IBAction)userSignIn:(id)sender {
    NSString *userName = self.userNameTextField.text;
    NSString *password = self.passwordTextField.text;
    NSString *surePassword = self.surePasswordTextField.text;
    if (userName.length&&password.length&&surePassword.length) {
        if ([self chineseExistIn:userName]||[self chineseExistIn:password]) {
            self.warmLabel.text = @"账户名或密码中不能存在中文";
            self.warmLabel.hidden = NO;
        }else{
            if([self errorLengthWithUserName:userName]||[self errorLengthWithPassword:password]){
                self.warmLabel.text = @"账户名长度为4-12个字符,密码长度为8-16个字符";
                self.warmLabel.hidden = NO;
            }else{
                if ([password isEqualToString:surePassword]) {
                    self.warmLabel.hidden = YES;
                    self.signInView.hidden = NO;
                    [[XMPPManager shareManager] xmppConnectWithUserName:self.userNameTextField.text];
                }else{
                    self.warmLabel.text = @"两次输入的密码不同";
                    self.warmLabel.hidden = NO;
                    
                }
            }
        }
    }else{
        self.warmLabel.text = @"请完整输入";
        self.warmLabel.hidden = NO;
    }
    
}

- (IBAction)backToLogin:(id)sender {
    [[XMPPManager shareManager].xmppStream removeDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)chineseExistIn:(NSString *)str{
    for(int i=0; i< [str length];i++){
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff){
            return YES;
        }
    }
    return NO;
}

-(BOOL)errorLengthWithUserName:(NSString *)str{
    if (str.length<4||str.length>12) {
        return YES;
    }
    return NO;
}

-(BOOL)errorLengthWithPassword:(NSString *)str{
    if (str.length<8||str.length>16) {
        return YES;
    }
    return NO;
}

-(void)cancelFirstResponder:(UITapGestureRecognizer *)g{
    if ([self.userNameTextField isFirstResponder]) {
        [self.userNameTextField resignFirstResponder];
    }
    if ([self.passwordTextField isFirstResponder]) {
        [self.passwordTextField resignFirstResponder];
    }
    if ([self.surePasswordTextField isFirstResponder]) {
        [self.surePasswordTextField resignFirstResponder];
    }
}



-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    [[XMPPManager shareManager] xmppAuthenticateWithPassword:self.passwordTextField.text];
}

#pragma mark xmppStream代理方法
-(void)xmppStreamDidConnect:(XMPPStream *)sender{
    [[XMPPManager shareManager] xmppRegisterWithPassword:self.passwordTextField.text];
}

-(void)xmppStreamDidRegister:(XMPPStream *)sender{
    self.signInView.hidden = YES;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"诶哟不错哦" message:@"你这智商竟然注册成功了" delegate:self cancelButtonTitle:@"登录" otherButtonTitles:nil, nil];
    [alertView show];
}

-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"开玩笑" message:@"这么大众的用户名能让你来取？" delegate:nil cancelButtonTitle:@"赶紧换一个" otherButtonTitles:nil, nil];
    [alertView show];
    [[XMPPManager shareManager].xmppStream disconnect];
}


-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    [[XMPPManager shareManager].xmppStream removeDelegate:self delegateQueue:dispatch_get_main_queue()];
     //密码进入userDefault
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






@end
