//
//  FriendManager.m
//  TestIM4
//
//  Created by Apple on 15/12/10.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import "FriendManager.h"
#import "XMPPManager.h"
#import "FMDatabase.h"

@interface FriendManager()

@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) NSString *selfName;

@end

@implementation FriendManager

-(instancetype)init{
    self = [super init];
    if (self) {
        self.selfName = [XMPPManager shareManager].xmppStream.myJID.user;
        [self createDatabase];
    }
    return self;
}

-(void)createDatabase{
    NSString *topPath =[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Friends"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:topPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:topPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/Friends/%@Friends.sqlite",self.selfName]];
    NSLog(@"%@",path);
    self.database = [[FMDatabase alloc] initWithPath:path];
    BOOL isOpen = [self.database open];
    if (isOpen) {
        NSString *createSql = [NSString stringWithFormat:@"create table if not exists %@Friends (number integer primary key autoincrement, userName text, headImage blob, weChat text, phoneNumber text, changeState integer, weChatRequsetTime text, phoneNumberRequsetTime text)",self.selfName];
        BOOL ret = [_database executeUpdate:createSql];
        if(!ret){
            NSLog(@"会话列表数据库创建失败");
            NSLog(@"%@",self.database.lastErrorMessage);
        }
    }
}

//增加好友
-(void)addDataWithFriendModel:(Friend *)model{
    NSString *sql = [NSString stringWithFormat:@"select * from %@Friends where userName = ?",self.selfName];
    FMResultSet *rs = [self.database executeQuery:sql,model.userName];
    if (![rs next]) {
        NSString *addSql = [NSString stringWithFormat:@"insert into %@Friends (userName, headImage, weChat, phoneNumber, changeState, weChatRequsetTime,phoneNumberRequsetTime) values (?, ?, ?, ?, ?, ?, ?)",self.selfName];
        BOOL ret = [self.database executeUpdate:addSql,model.userName,model.data,model.weChat,model.phoneNumber,@(model.changeState),model.changeWechatTime,model.changePhoneNumberTime];
        if (!ret) {
            NSLog(@"%@",self.database.lastErrorMessage);
        }
    }
    
}
//查询好友联系方式交换情况
-(int)changeStateWithUserName:(NSString *)userName{
    NSString *sql = [NSString stringWithFormat:@"select * from %@Friends where userName = ?",self.selfName];
    FMResultSet *rs = [self.database executeQuery:sql,userName];
    if ([rs next]) {
        return [rs intForColumn:@"changeState"];
    }
    return 0;

}
//通过用户名查询好友
-(Friend *)friendWithUserName:(NSString *)userName{
    NSString *sql = [NSString stringWithFormat:@"select * from %@Friends where userName = ?",self.selfName];
    FMResultSet *rs = [self.database executeQuery:sql,userName];
    Friend *friend = nil;
    if ([rs next]) {
        friend = [[Friend alloc] init];
        friend.userName = [rs stringForColumn:@"userName"];
        friend.data = [rs dataForColumn:@"headImage"];
        friend.weChat = [rs stringForColumn:@"weChat"];
        friend.phoneNumber = [rs stringForColumn:@"phoneNumber"];
        friend.changeState = [rs intForColumn:@"changeState"];
        friend.changeWechatTime = [rs stringForColumn:@"weChatRequsetTime"];
        friend.changePhoneNumberTime = [rs stringForColumn:@"phoneNumberRequsetTime"];
    }
    return friend;
}

-(void)updateFriend:(NSString *)username WithChangeState:(ChangeState)state{
    NSString *sql = [NSString stringWithFormat:@"update %@Friends set changeState = ? where userName = ?",self.selfName];
    BOOL ret = [self.database executeUpdate:sql,@(state),username];
    if (!ret) {
        NSLog(@"%@",self.database.lastErrorMessage);
    }
}

-(void)updateFriend:(NSString *)username WithPhoneNumberTime:(NSString *)time{
    NSString *sql = [NSString stringWithFormat:@"update %@Friends set phoneNumberRequsetTime = ? where userName = ?",self.selfName];
    BOOL ret = [self.database executeUpdate:sql,time,username];
    if (!ret) {
        NSLog(@"%@",self.database.lastErrorMessage);
    }
}

-(void)updateFriend:(NSString *)username WithWechatTime:(NSString *)time{
    NSString *sql = [NSString stringWithFormat:@"update %@Friends set weChatRequsetTime = ? where userName = ?",self.selfName];
    BOOL ret = [self.database executeUpdate:sql,time,username];
    if (!ret) {
        NSLog(@"%@",self.database.lastErrorMessage);
    }
}

@end
