//
//  AddressTableViewController.m
//  Chatter
//
//  Created by JW on 5/7/28 H.
//  Copyright © 28 Heisei JumboStudio. All rights reserved.
//

#import "AddressTableViewController.h"
#import "EaseMob.h"

@interface AddressTableViewController ()<EMChatManagerDelegate>

/** 好友列表数据源 **/
@property (nonatomic,strong) NSArray *buddyList;

@end

@implementation AddressTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加聊天管理器的代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    // 获取好友列表数据
    // 1. 好友列表需要在自动登录成功后才有值
    // 2. buddyList的数据是从本地数据库获取
    // 3. 要从服务器上获取，用asyncFetchBudddyListWithCompletion方法
    // 4. 如果程序删除或者用户第一次登陆，本地数据库buddyList表是没有记录的。
    //    解决方案1.要从服务器上获取数据。2.用户第一次登录后，自动从服务器获取好友列表。
    
    self.buddyList = [[EaseMob sharedInstance].chatManager buddyList];
    NSLog(@"%@",self.buddyList);
    
#warning buddylist没有值得情况，1.自动登录还没有完成。2.第一次登录。
    if (self.buddyList.count == 0 ) {
        
    }
    

}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.buddyList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"BuddyCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID ];
    
    // 1.获取“好友”模型
    EMBuddy *buddy = self.buddyList[indexPath.row];
    
    // 2.显示头像
    cell.imageView.image = [UIImage imageNamed:@"chatListCellHead"];
    
    // 3.显示名称
    cell.textLabel.text = buddy.username;
    
    
    return cell;
}

#pragma mark - charManger的代理
#pragma mark - 监听自动登录成功
-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error{
    
    if (!error) {
        //自动登录成功，此时buddylist就有值
        self.buddyList = [[EaseMob sharedInstance].chatManager buddyList];
        NSLog(@"===%@",self.buddyList);
        [self.tableView reloadData];
    }
}

#pragma mark 好友添加请求同意
- (void)didAcceptedByBuddy:(NSString *)username{
    // 把新的好友显示到表格
    NSArray *buddyList = [[EaseMob sharedInstance].chatManager buddyList];
    NSLog(@"好友添加请求同意 %@", buddyList);
    [self loadBuddyListFromServer];
    
}


#pragma mark 从服务器获取好友列表
-(void) loadBuddyListFromServer{
    [[EaseMob sharedInstance].chatManager asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
        
        NSLog(@"从服务器获取的好友列表 %@", buddyList);
        // 赋值数据源
        self.buddyList = buddyList;
        // 刷新列表
        [self.tableView reloadData];
        
    } onQueue:nil];
}

#pragma mark 好友列表数据被更新
- (void)didUpdateBuddyList:(NSArray *)buddyList changedBuddies:(NSArray *)changedBuddies isAdd:(BOOL)isAdd{
    
      NSLog(@"好友列表数据被更新 %@", buddyList);
       // 赋值数据源
      self.buddyList = buddyList;
       // 刷新列表
      [self.tableView reloadData];
    
    
}

#pragma mark 被好友删除
- (void)didRemovedByBuddy:(NSString *)username{
    // 刷新表格
    [self loadBuddyListFromServer];
    
}




#pragma mark 实现下面的方法就会出现表格的Delete按钮
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // 获取移除好友的名字
        EMBuddy *buddy = self.buddyList[indexPath.row];
        NSString *deleteUsername = buddy.username;
        
        //删除好友
        [[EaseMob sharedInstance].chatManager removeBuddy:deleteUsername removeFromRemote:YES error:nil];
    }
}

@end
