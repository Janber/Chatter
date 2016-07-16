//
//  SettingTableViewController.m
//  Chatter
//
//  Created by JW on 5/8/28 H.
//  Copyright © 28 Heisei JumboStudio. All rights reserved.
//

#import "SettingTableViewController.h"
#import "EaseMob.h"

@interface SettingTableViewController ()

@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

@end

@implementation SettingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 当前登录用户名
    NSString *loginUsername = [[EaseMob sharedInstance].chatManager loginInfo][@"username"];
    
    NSString *title = [NSString stringWithFormat:@"log out(%@)",loginUsername];
    
    // 1.设置退出按钮的文字
    [self.logoutBtn setTitle:loginUsername forState:UIControlStateNormal];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)logoutAction:(id)sender {
    
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
        if (error) {
            NSLog(@"退出失败 %@",error);
        }else{
            NSLog(@"退出成功");
            //回到登录界面
            self.view.window.rootViewController = [UIStoryboard storyboardWithName:@"Login" bundle:nil].instantiateInitialViewController;
            
            
        }
    } onQueue:nil];
    
}

@end
