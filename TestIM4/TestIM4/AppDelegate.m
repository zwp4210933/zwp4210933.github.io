//
//  AppDelegate.m
//  TestIM4
//
//  Created by Apple on 15/11/23.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import "AppDelegate.h"
#import "XMPPManager.h"


@interface AppDelegate ()<XMPPStreamDelegate>

@property (nonatomic, strong) NSTimer *timer;


@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(userOnline:) userInfo:nil repeats:YES];
    self.timer.fireDate = [NSDate distantFuture];
    //注册
    UIUserNotificationType type = UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
    
    UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:type categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    
    //APNS
    //apple push  notification serve
    //1、注册远程推送
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    return YES;
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"---Token--%@", deviceToken);
}

-(void)userOnline:(NSTimer *)timer{
    if ([[XMPPManager shareManager] xmppIsAvailable]) {
        timer.fireDate = [NSDate distantFuture];
    }
    
    if (![[XMPPManager shareManager].xmppStream isConnected]) {
        [[XMPPManager shareManager] xmppConnectWithUserName:[[NSUserDefaults standardUserDefaults] objectForKey:@"username"]];
    }
    
    [[XMPPManager shareManager] xmppAvailable];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[XMPPManager shareManager] xmppUnavailable];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if (self.player) {
        [self.player stop];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"password"] length]>0){
        self.timer.fireDate = [NSDate distantPast];
    }
}



- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
