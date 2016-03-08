//
//  ChatListManager.m
//  TestIM4
//
//  Created by Apple on 15/11/27.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import "ChatListManager.h"
#import "XMPPManager.h"
#import "FMDatabase.h"

@interface ChatListManager()

@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) NSString *selfName;

@end

@implementation ChatListManager


-(instancetype)init{
    self = [super init];
    if (self) {
        self.selfName = [XMPPManager shareManager].xmppStream.myJID.user;
        [self createDatabase];
    }
    return self;
}

-(void)createDatabase{
    NSString *topPath =[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ChatList"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:topPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:topPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/ChatList/%@.sqlite",self.selfName]];
    NSLog(@"%@",path);
    self.database = [[FMDatabase alloc] initWithPath:path];
    BOOL isOpen = [self.database open];
    if (isOpen) {
        NSString *createSql = [NSString stringWithFormat:@"create table if not exists %@ (number integer primary key autoincrement, userName text, headImage blob, top integer)",self.selfName];
        BOOL ret = [_database executeUpdate:createSql];
        if(!ret){
            NSLog(@"会话列表数据库创建失败");
            NSLog(@"%@",self.database.lastErrorMessage);
        }
    }
}

//添加会话
-(void)addDataWithChatModel:(Chat *)model{
    NSInteger top = model.isTop?1:0;
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where userName = ?",self.selfName];
    FMResultSet *rs = [self.database executeQuery:sql,model.userName];
    if ([rs next]) {
        [self removeDataWithUserName:model.userName];
    }
    NSString *addSql = [NSString stringWithFormat:@"insert into %@ (userName, headImage, top) values (?, ?, ?)",self.selfName];
    BOOL ret = [self.database executeUpdate:addSql,model.userName,model.data,@(top)];
    if (!ret) {
        NSLog(@"%@",self.database.lastErrorMessage);
    }

}

//删除会话
-(void)removeDataWithUserName:(NSString *)userName{
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where userName = ?",self.selfName];
    BOOL ret = [self.database executeUpdate:sql,userName];
    if (!ret) {
        NSLog(@"%@",self.database.lastErrorMessage);
    }
}


//判断会话置顶情况
-(BOOL)chatIsTopWithUserName:(NSString *)userName{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where userName = ?",self.selfName];
    FMResultSet *rs = [self.database executeQuery:sql,userName];
    if ([rs next]) {
        BOOL isTop = [rs intForColumn:@"top"];
        return isTop;
    }
    return 0;
}

//获取所有会话
-(NSArray *)selectedAllChatModel{
    NSString *sql = [NSString stringWithFormat:@"select * from %@",self.selfName];
    FMResultSet *rs = [self.database executeQuery:sql];
    NSMutableArray *array = [NSMutableArray array];
    NSMutableArray *topArray = [NSMutableArray array];
    while ([rs next]) {
        Chat *model = [[Chat alloc] init];
        model.userName = [rs stringForColumn:@"userName"];
        model.isTop = [rs intForColumn:@"top"];
        model.data = [rs dataForColumn:@"headImage"];
        if (model.isTop) {
            [topArray addObject:model];
        }else{
            [array addObject:model];
        }
    }
    [array addObjectsFromArray:topArray];
    return array;
}

//置顶会话
-(void)makeTop:(BOOL)top UserName:(NSString *)userName{
    NSInteger isTop = top?1:0;
    NSString *sql = [NSString stringWithFormat:@"update %@ set top = ? where userName = ?",self.selfName];
    BOOL ret = [self.database executeUpdate:sql,@(isTop),userName];
    if (!ret) {
        NSLog(@"%@",self.database.lastErrorMessage);
    }
}

@end
