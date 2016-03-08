//
//  AppDelegate.h
//  TestIM4
//
//  Created by Apple on 15/11/23.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSString *weixin;

@property (strong, nonatomic) NSString *mobilePhone;

@property (nonatomic, strong) AVAudioPlayer *player;

@end

