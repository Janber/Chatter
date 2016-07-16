//
//  ChatViewController.m
//  Chatter
//
//  Created by JW on 5/8/28 H.
//  Copyright © 28 Heisei JumboStudio. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatReceiveTableViewCell.h"

@interface ChatViewController ()<UITableViewDataSource>


/** 输入工具条底部的约束**/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewButtonConstraint;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    return 20;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"ReceiverCell";
    ChatReceiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    //显示内容
    cell.messageLabel.text = @"发生的范德萨发zadsdsfdgvdfvfdvvdfvdfb";
    return cell;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
