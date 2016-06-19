//
//  AddFriendViewController.m
//  Chatter
//
//  Created by JW on 5/7/28 H.
//  Copyright © 28 Heisei JumboStudio. All rights reserved.
//

#import "AddFriendViewController.h"
#import "EaseMob.h"

@interface AddFriendViewController ()<EMChatManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 添加(聊天管理器)代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
}


- (IBAction)AddFriendAction:(id)sender {
    
    // 添加好友
    // 1.获取要添加好友的名字
    NSString * username = self.textField.text;
    
    //message:请求添加好友额外信息
    NSString * loginUsename = [[EaseMob sharedInstance].chatManager loginInfo][@"username"];
    NSString * message = [@"我是" stringByAppendingString:loginUsename];
    
    EMError * error = nil;
    
    // 2.向服务器发送一个添加好友的请求
    [[EaseMob sharedInstance].chatManager addBuddy:username message:message error:&error];
    
    if (error) {
        NSLog(@"添加好友有问题 %@",error);
    }else {
        NSLog(@"添加好友成功");
    }
}


- (void)dealloc {
    //移除聊天管理器的代理
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}


@end
