//
//  ConversationTableViewController.m
//  Chatter
//
//  Created by JW on 5/7/28 H.
//  Copyright © 28 Heisei JumboStudio. All rights reserved.
//

#import "ConversationTableViewController.h"
#import "EaseMob.h"
#import "ChatViewController.h"

@interface ConversationTableViewController ()<EMChatManagerDelegate,UIAlertViewDelegate>

@property (nonatomic, copy) NSString *buddyname;

/* 历史会话记录 */
@property (nonatomic,strong) NSArray *conversations;

@end

@implementation ConversationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    //获取历史会话记录
    [self loadConversations];
}


-(void)loadConversations{
    //获取历史会话记录
    //1.从内存获取历史会话记录
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
//    NSLog(@"%@",conversations);
    //2.如果内存里没有会话记录，从数据库Conversation表获取
    if (conversations.count == 0) {
        conversations = [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES];
    }
    self.conversations = conversations;
    
    //显示总的未读数
    [self showTabBarBadge];
    
}



#pragma mark -chatManager代理方法
//1.监听网络状态
- (void)didConnectionStateChanged:(EMConnectionState)connectionState{
    
    if (connectionState == eEMConnectionDisconnected){
        NSLog(@"网络断开，未连接...");
        self.title = @"未连接.";
    }else{
        NSLog(@"网络通了，连接成功");
    }
}


//2.监听自动连接的状态
- (void)willAutoReconnect{
    NSLog(@"将自动连接...");
    self.title = @"连接中...";
}


- (void)didAutoReconnectFinishedWithError:(NSError *)error{
    if (!error) {
        NSLog(@"自动连接成功...");
        self.title = @"Conversation";
    }else{
        NSLog(@"自动连接失败...%@",error);
    }
}

#pragma mark - 好友添加的代理方法
#pragma mark 好友请求被同意
- (void)didAcceptedByBuddy:(NSString *)username{
    
    // 提醒用户，好友请求被同意
    NSString *message = [NSString stringWithFormat:@"%@ 同意了你的好友请求",username];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"好友添加消息"
                          message:message
                          delegate:nil
                          cancelButtonTitle:@"知道了"
                          otherButtonTitles:nil];
    
    [alert show];
}


#pragma mark 好友请求被拒绝
- (void)didRejectedByBuddy:(NSString *)username{
    
    // 提醒用户，好友请求被拒绝
    NSString *message = [NSString stringWithFormat:@"%@ 拒绝了你的好友请求",username];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"好友添加消息"
                          message:message
                          delegate:nil
                          cancelButtonTitle:@"知道了"
                          otherButtonTitles:nil];
    
    [alert show];
}


#pragma mark 接收到好友的请求
- (void)didReceiveBuddyRequest:(NSString *)username message:(NSString *)message{
    
    self.buddyname = username;
    
    // 对话框
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"好友添加请求" message:message delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"接受", nil];
    [alert show];
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0){
        [[EaseMob sharedInstance].chatManager rejectBuddyRequest:self.buddyname reason:@"我不认识你" error:nil];
        
    }else{
        
        [[EaseMob sharedInstance].chatManager acceptBuddyRequest:self.buddyname error:nil];
    }
}


#pragma mark -监听被好友删除
- (void)didRemovedByBuddy:(NSString *)username{
    
    NSString *message = [username stringByAppendingString:@" 把你删除了"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"被删除通知" message:message delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alert show];
    
}



-(void)dealloc {
    //移除聊天管理器的代理
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}


#pragma mark 历史会话列表更新
-(void)didUpdateConversationList:(NSArray *)conversationList{
    
    //给数据源重新赋值
    self.conversations = conversationList;
    //刷新表格
    [self.tableView reloadData];
    
    //显示总的未读数
    [self showTabBarBadge];
}




#pragma mark 未读消息数改变
-(void)didUnreadMessagesCountChanged{
    //更新表格
    [self.tableView reloadData];
    //显示总的未读数
    [self showTabBarBadge];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conversations.count;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"ConversationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    //获取会话模型
    EMConversation *conversation = self.conversations[indexPath.row];
    
    NSLog(@"conversation %@", conversation.chatter);
    //显示数据
    //1.显示用户名
    cell.textLabel.text = [NSString stringWithFormat:@"%@ === 未读消息数：%ld",
                           conversation.chatter,(unsigned long)[conversation unreadMessagesCount]];
    
    
    
    //conversation.chatter;
    
    
    //2.显示最新一条消息
    //获取消息体
    id body = conversation.latestMessage.messageBodies[0];
    if ([body isKindOfClass:[EMTextMessageBody class]]) {
        EMTextMessageBody *textBody = body;
        cell.detailTextLabel.text = textBody.text;
    }else if ([body isKindOfClass:[EMVoiceMessageBody class]]){
        EMVoiceMessageBody *voiceBody = body;
        cell.detailTextLabel.text = [voiceBody displayName];
    }else if ([body isKindOfClass:[EMImageMessageBody class]]){
        EMImageMessageBody *imgBody = body;
        cell.detailTextLabel.text = [imgBody displayName];
    }else{
        cell.detailTextLabel.text = @"未知消息类型";
    }
    return cell;
}


-(void)showTabBarBadge{
    //遍历所有的会话记录，将未读取的消息数进行累计
    NSInteger totalUnreadCount = 0;
    for (EMConversation *conversation in self.conversations) {
        totalUnreadCount += [conversation unreadMessagesCount];
    }
    self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",(long)totalUnreadCount];
}


@end
