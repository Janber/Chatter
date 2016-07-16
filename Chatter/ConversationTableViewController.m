//
//  ConversationTableViewController.m
//  Chatter
//
//  Created by JW on 5/7/28 H.
//  Copyright © 28 Heisei JumboStudio. All rights reserved.
//

#import "ConversationTableViewController.h"
#import "EaseMob.h"

@interface ConversationTableViewController ()<EMChatManagerDelegate,UIAlertViewDelegate>

@property (nonatomic, copy) NSString *buddyname;

@end

@implementation ConversationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
  //设置代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
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



- (void)dealloc {
    //移除聊天管理器的代理
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 0;
}


@end
