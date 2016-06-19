//
//  ChatViewController.m
//  Chatter
//
//  Created by JW on 5/8/28 H.
//  Copyright © 28 Heisei JumboStudio. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatReceiveTableViewCell.h"

@interface ChatViewController ()<UITableViewDataSource,UITableViewDelegate>


/** 输入工具条底部的约束**/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewButtonConstraint;

@property (nonatomic, strong) NSMutableArray *dataSources;

@property (nonatomic, strong) ChatReceiveTableViewCell *chatCellTool;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ChatViewController

- (NSMutableArray *)dataSources{
    
    if (! _dataSources) {
        _dataSources = [NSMutableArray array];
    }
    return _dataSources;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.dataSources addObject:@"xxxxxxxxxxxxxxxxxxxxxxxxx"];
    [self.dataSources addObject:@"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"];
    [self.dataSources addObject:@"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"];
    [self.dataSources addObject:@"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"];
    
    
    self.chatCellTool = [self.tableView dequeueReusableCellWithIdentifier:ReceiverCell];
    
    
    
    
    
    //1.监听键盘弹出，把inputToolbar(输入工具条)往上移
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    //2.监听键盘退出，inputToolbar恢复原位
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark 键盘显示时会触发的方法
-(void)kbWillShow:(NSNotification *)noti{
    
    //1.获取键盘高度
    //1.1获取键盘结束时候的位置
    CGRect kbEndFrm = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat kbHeight = kbEndFrm.size.height;
    
    
    //2.更改inputToolbar 底部约束
    self.inputViewButtonConstraint.constant = kbHeight;
    //添加动画
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    
}

-(void)kbWillHide:(NSNotification *)noti {
//    inputToolbar恢复原位
    self.inputViewButtonConstraint.constant=0;
    
}




- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark 表格数据源
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSources.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.chatCellTool.messageLabel.text = self.dataSources[indexPath.row];
    
    
    return [self.chatCellTool cellHeight];
}



-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ChatReceiveTableViewCell *cell = nil;

    
    if (indexPath.row % 2 == 0 ) { // senderCell
        
        cell = [tableView dequeueReusableCellWithIdentifier:SenderCell];
        
    } else {  // receieverCell
        
        cell = [tableView dequeueReusableCellWithIdentifier:ReceiverCell];
        
    }
    
    //显示内容
    cell.messageLabel.text = self.dataSources[indexPath.row];
    return cell;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
