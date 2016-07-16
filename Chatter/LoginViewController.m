//
//  LoginViewController.m
//  Chatter
//
//  Created by JW on 5/6/28 H.
//  Copyright © 28 Heisei JumboStudio. All rights reserved.
//

#import "LoginViewController.h"
#import "EaseMob.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)registerAction:(id)sender {
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    if (username.length == 0 || password.length == 0) {
        NSLog(@"请输入账号和密码");
        return;
    }
    
    //注册
   [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:username password:password withCompletion:^(NSString *username, NSString *password, EMError *error) {
    
       NSLog(@"%@",[NSThread currentThread]);
       if (!error) {
           NSLog(@"注册成功");
       }else{
           NSLog(@"注册失败 %@",error);
       }
       
   } onQueue:nil];
    
}

- (IBAction)loginAction:(id)sender {
    
   
    // 让环信SDK在登录完成之后，自动从服务器获取好友列表，添加到本地数据中。
    [[EaseMob sharedInstance].chatManager setAutoFetchBuddyList:YES];
    
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    if (username.length == 0 || password.length == 0) {
        NSLog(@"请输入账号和密码");
        return;
    }
    
    // 登录
     [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:username password:password completion:^(NSDictionary *loginInfo, EMError *error) {
         //登录请求完成后的Block回调
         if (!error) {
             NSLog(@"登录成功 %@", loginInfo);
             
             //设置自动登录
            [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
             
             //来到主界面
             self.view.window.rootViewController = [UIStoryboard storyboardWithName:@"Main" bundle:nil].instantiateInitialViewController;
             
         }else {
             NSLog(@"登录失败 %@", error);
         }
         
     } onQueue:dispatch_get_main_queue()];
    
}



@end
