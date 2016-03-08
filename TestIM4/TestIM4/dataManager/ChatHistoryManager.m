//
//  ChatHistoryManager.m
//  TestIM4
//
//  Created by Apple on 15/11/27.
//  Copyright © 2015年 lanjue. All rights reserved.
//

#import "ChatHistoryManager.h"
#import "XMPPManager.h"
#import "FMDatabase.h"

@interface ChatHistoryManager()

@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) NSString *selfName;

@end

@implementation ChatHistoryManager

-(instancetype)init{
    self = [super init];
    if (self) {
        self.selfName = [XMPPManager shareManager].xmppStream.myJID.user;
        
    }
    return self;
}

-(void)setFriendName:(NSString *)friendName{
    _friendName = [NSString stringWithFormat:@"%@History",friendName];
    [self createDatabase];
}

-(void)createDatabase{
    if (self.friendName.length>0) {
        NSString *topPath =[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/ChatHistory/%@",self.selfName]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:topPath]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:topPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Documents/ChatHistory/%@/%@.sqlite",self.selfName,self.friendName]];
        NSLog(@"%@",path);
        self.database = [[FMDatabase alloc] initWithPath:path];
        BOOL isOpen = [self.database open];
        if (isOpen) {
            NSString *createSql = [NSString stringWithFormat:@"create table if not exists %@ (number integer primary key autoincrement, text text, time text,type text, direction integer, requestType text, timeLength float, imageWidth float, imageHeight float, sImageName text, readed boolean, played boolean, replyed boolean)",self.friendName];
            BOOL ret = [_database executeUpdate:createSql];
            if(!ret){
                NSLog(@"历史消息数据库创建失败");
                NSLog(@"%@",self.database.lastErrorMessage);
            }
        }

    }
}

//增加消息条
-(void)addDataWithTextMessage:(TextMessage *)model{
    NSInteger direction = model.direction;
    NSArray *array = [self selectedAllMessage];
    if (array.count==200) {
        NSString *sql = [NSString stringWithFormat:@"delete from %@ where number = (Select  Min(number) From %@)",self.friendName,self.friendName];
        BOOL ret=[self.database executeUpdate:sql];
        if (!ret) {
            NSLog(@"%@",self.database.lastErrorMessage);
        }
    }
    if (model.type == Text) {
        NSString *addSql = [NSString stringWithFormat:@"insert into %@ (text, time, type, direction, readed) values (?, ?, ?, ?, ?)",self.friendName];
        BOOL ret = [self.database executeUpdate:addSql,model.text,model.time,@"text",@(direction),@(model.readed)];
        if (!ret) {
            NSLog(@"%@",self.database.lastErrorMessage);
        }
    }else if (model.type == Request){
        NSString *addSql = [NSString stringWithFormat:@"insert into %@ (text, time, type, direction, requestType,readed,replyed) values (?, ?, ?, ?, ?, ?,?)",self.friendName];
        BOOL ret;
        if (model.requestType == WeChat) {
            ret = [self.database executeUpdate:addSql,model.text,model.time,@"request",@(direction),@"weChat", @(model.readed),@(model.replyed)];
        }else{
            ret = [self.database executeUpdate:addSql,model.text,model.time,@"request",@(direction),@"phone", @(model.readed),@(model.replyed)];
        }
        if (!ret) {
            NSLog(@"%@",self.database.lastErrorMessage);
        }
    }else if (model.type == Reply){
        NSString *addSql = [NSString stringWithFormat:@"insert into %@ (text, time, type, direction, requestType, readed) values (?, ?, ?, ?, ?, ?)",self.friendName];
        BOOL ret;
        if (model.requestType == WeChat) {
            ret = [self.database executeUpdate:addSql,model.text,model.time,@"reply",@(direction),@"weChat", @(model.readed)];
        }else{
            ret = [self.database executeUpdate:addSql,model.text,model.time,@"reply",@(direction),@"phone", @(model.readed)];
        }
        if (!ret) {
            NSLog(@"%@",self.database.lastErrorMessage);
        }
    }else if (model.type == Image){
        NSString *addSql = [NSString stringWithFormat:@"insert into %@ (text, time, type, direction, imageWidth, imageHeight,sImageName, readed) values (?, ?, ?, ?, ?, ?, ?,?)",self.friendName];
        BOOL ret = [self.database executeUpdate:addSql,model.text,model.time,@"image",@(direction),@(model.imageSize.width),@(model.imageSize.height),model.sImgName, @(model.readed)];
        if (!ret) {
            NSLog(@"%@",self.database.lastErrorMessage);
        }
    }else{
        NSString *addSql;
        BOOL ret;
        addSql = [NSString stringWithFormat:@"insert into %@ (text, time, type, direction, timeLength, readed, played) values (?, ?, ?, ?, ?, ?, ?)",self.friendName];
        ret = [self.database executeUpdate:addSql,model.text,model.time,@"rideo",@(direction),@(model.voiceLength), @(model.readed),@(model.played)];
        if (!ret) {
            NSLog(@"%@",self.database.lastErrorMessage);
        }

    }
    
    
}

//删除消息条
-(void)deleteMessageWithText:(NSString *)text Type:(MessageType)type{
    NSString *messageType = nil;
    if (type == Request) {
        messageType = @"request";
    }else if (type == Reply){
        messageType = @"reply";
    }else if (type == Text){
        messageType = @"text";
    }else if (type == Image){
        messageType = @"image";
    }else if (type == Redio){
        messageType = @"redio";
    }
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where type = ? and text = ?",self.friendName];
    BOOL ret=[self.database executeUpdate:sql,messageType,text];
    if (!ret) {
        NSLog(@"%@",self.database.lastErrorMessage);
    }

}

//获取所有消息条
-(NSArray *)selectedAllMessage{
    NSString *sql = [NSString stringWithFormat:@"select * from %@",self.friendName];
    FMResultSet *rs = [self.database executeQuery:sql];
    NSMutableArray *array = [NSMutableArray array];
    while ([rs next]) {
        TextMessage *model = [[TextMessage alloc] init];
        model.text = [rs stringForColumn:@"text"];
        model.direction = [rs intForColumn:@"direction"];
        NSString *type = [rs stringForColumn:@"type"];
        
        if ([type isEqualToString:@"text"]) {
            model.type = Text;
        }else if ([type isEqualToString:@"request"]){
            NSString *requestType = [rs stringForColumn:@"requestType"];
            if ([requestType isEqualToString:@"weChat"]) {
                model.requestType = WeChat;
            }else{
                model.requestType = Phone;
            }
            model.type = Request;
            model.replyed = [rs boolForColumn:@"replyed"];
        }else if ([type isEqualToString:@"reply"]){
            NSString *requestType = [rs stringForColumn:@"requestType"];
            if ([requestType isEqualToString:@"weChat"]) {
                model.requestType = WeChat;
            }else{
                model.requestType = Phone;
            }
            model.type = Reply;
        }else if([type isEqualToString:@"image"]){
            CGFloat imageWidth = [rs doubleForColumn:@"imageWidth"];
            CGFloat imageHeight = [rs doubleForColumn:@"imageHeight"];
            model.imageSize = CGSizeMake(imageWidth, imageHeight);
            model.type = Image;
            model.sImgName = [rs stringForColumn:@"sImageName"];
        }else{
            CGFloat length = [rs doubleForColumn:@"timeLength"];
            model.voiceLength = length;
            model.type = Redio;
            model.played = [rs boolForColumn:@"played"];
        }
        model.time = [rs stringForColumn:@"time"];
        model.readed = [rs boolForColumn:@"readed"];
        [array addObject:model];
    }
    return array;
}

//获取所有语音消息
-(NSArray *)selectedAllImageMessage{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where type = 'image'",self.friendName];
    FMResultSet *rs = [self.database executeQuery:sql];
    NSMutableArray *array = [NSMutableArray array];
    while ([rs next]) {
        TextMessage *model = [[TextMessage alloc] init];
        model.text = [rs stringForColumn:@"text"];
        model.direction = [rs intForColumn:@"direction"];
        CGFloat imageWidth = [rs doubleForColumn:@"imageWidth"];
        CGFloat imageHeight = [rs doubleForColumn:@"imageHeight"];
        model.sImgName = [rs stringForColumn:@"sImageName"];
        model.imageSize = CGSizeMake(imageWidth, imageHeight);
        model.type = Image;
        model.time = [rs stringForColumn:@"time"];
        model.readed = [rs boolForColumn:@"readed"];
        [array addObject:model];
    }
    return array;
}


//获取最后一条消息的文本
-(NSString *)selectedLastMessage{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where number = (select max(number) from %@)",self.friendName,self.friendName];
    FMResultSet *rs = [self.database executeQuery:sql];
    while ([rs next]) {
        NSString *type = [rs stringForColumn:@"type"];
        BOOL direction = [rs intForColumn:@"direction"];
        if ([type isEqualToString:@"text"]) {
            NSString *str = [rs stringForColumn:@"text"];
            return str;
        }else if ([type isEqualToString:@"request"]){
            if (direction) {
                return @"对方向您发送了一条请求信息";
            }else{
                return @"您向对方发送了一条请求信息";
            }
        }else if ([type isEqualToString:@"reply"]){
            if (direction) {
                return @"对方回复了您的请求";
            }else{
                return @"您回复了对方的请求";
            }
        }else if ([type isEqualToString:@"image"]){
            if (direction) {
                return @"对方发来一张图片";
            }else{
                return @"您发送了一张图片";
            }
        }else{
            if (direction) {
                return @"对方发来一段语音";
            }else{
                return @"您发送了一段语音";
            }
        }
    }
    return @"";
    
}

//获取最后一条消息的发送时间
-(NSString *)selectedLastMessageTime{
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where number = (select max(number) from %@)",self.friendName,self.friendName];
    FMResultSet *rs = [self.database executeQuery:sql];
    while ([rs next]) {
        return [rs stringForColumn:@"time"];
    }
    return @"";

}

//将未读消息条置为已读
-(void)updateAllMessageReaded{
    NSString *sql = [NSString stringWithFormat:@"update %@ set readed = ? where readed = ?",self.friendName];
    BOOL ret = [self.database executeUpdate:sql,@(YES),@(NO)];
    if (!ret) {
        NSLog(@"%@",self.database.lastErrorMessage);
    }
}
//将未播放的录音消息置为已播放
-(void)updateRedioMessagePlayedWithFileName:(NSString *)fileName{
    NSString *sql = [NSString stringWithFormat:@"update %@ set played = ? where text = ? ",self.friendName];
    BOOL ret = [self.database executeUpdate:sql,@(YES),fileName];
    if (!ret) {
        NSLog(@"%@",self.database.lastErrorMessage);
    }
}

//将未回复的消息设置为已回复
-(void)updateRequestMessageReplyedWithRequset:(RequestType)type{
    NSString *sql = [NSString stringWithFormat:@"update %@ set replyed = ? where direction = 1 and requestType = ? and type = 'request'",self.friendName];
    NSString *requestType;
    if (type == WeChat) {
        requestType = @"weChat";
    }else{
        requestType = @"phone";
    }
    BOOL ret = [self.database executeUpdate:sql,@(YES),requestType];
    if (!ret) {
        NSLog(@"%@",self.database.lastErrorMessage);
    }
}

-(void)updateImageMessageOldName:(NSString *)oldName newName:(NSString *)newName{
    NSString *sql = [NSString stringWithFormat:@"update %@ set text = ? where type = 'image' and direction = 1 and text = ?",self.friendName];
    BOOL ret = [self.database executeUpdate:sql,newName,oldName];
    if (!ret) {
        NSLog(@"%@",self.database.lastErrorMessage);
    }

}

@end
