//
//  ChatViewController.m
//  Chatter
//
//  Created by JW on 5/8/28 H.
//  Copyright © 28 Heisei JumboStudio. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatReceiveTableViewCell.h"


@interface ChatViewController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,EMChatManagerDelegate>


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
   
    // 给计算高度的cell工具对象 赋值
    self.chatCellTool = [self.tableView dequeueReusableCellWithIdentifier:ReceiverCell];
    
    // 显示好友的名字
    self.title = self.buddy.username;
    
    // 加载本地数据库（MessageV1）聊天记录
    [self loadLocalChatRecords];
    
    
    // 设置聊天管理器的代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    
    //1.监听键盘弹出，把inputToolbar(输入工具条)往上移
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    //2.监听键盘退出，inputToolbar恢复原位
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)loadLocalChatRecords{
    // 要获取本地用户会话
    EMConversation * conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:self.buddy.username conversationType:eConversationTypeChat];
    
    // 加载当前聊天用户所以得聊天记录
    NSArray *messages = [conversation loadAllMessages];
    
    
    
    // 添加到数据源
    [self.dataSources addObjectsFromArray:messages];
    
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
    
    // 获取消息模型
    EMMessage *msg = self.dataSources[indexPath.row];
    
    
    self.chatCellTool.message = msg;
    
    
    return [self.chatCellTool cellHeight];
}



-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 获取消息模型
    EMMessage * message = self.dataSources[indexPath.row];
    
    ChatReceiveTableViewCell *cell = nil;

    if ([message.from isEqualToString:self.buddy.username]) { // 接收方
        
          cell = [tableView dequeueReusableCellWithIdentifier:ReceiverCell];
        
    }else{  // 发送方
        
          cell = [tableView dequeueReusableCellWithIdentifier:SenderCell];
    }
    
    //显示内容
    cell.message = message;
    return cell;
}

#pragma mark - UITextView代理
-(void)textViewDidChange:(UITextView *)textView{
    
    
 
 // 监听Send事件 -- 判断最后的一个字符是不是换行字符
    if ([textView.text hasSuffix:@"\n"]){
        
        NSLog(@"<<%@",textView.text);

        [self sendMessage:textView.text];
        
//         NSLog(@">>%@",textView.text);
        // 清空textView的文字
//        textView.text = nil;
        
        
    }
    
    
}

-(void)sendMessage:(NSString *)text{
    
    
//     NSLog(@">>%@",text);
    // 把最后一个换行字符去掉
    text = [text substringToIndex:text.length - 1];
    
    
    // 消息 = 消息头 + 消息体
    
//    NSLog(@"要发送给 %@",self.buddy.username);
    
    // 创建一个聊天文本对象
    EMChatText * chatText = [[EMChatText alloc] initWithText:text];
    
    // 创建一个文本消息体
    EMTextMessageBody * textBody = [[EMTextMessageBody alloc] initWithChatObject:chatText];
    
    // 创建一个消息对象
    EMMessage * msgObj = [[EMMessage alloc] initWithReceiver:self.buddy.username bodies:@[textBody]];
    
    //消息类型
    msgObj.messageType = eMessageTypeChat;
    
    // 发送消息
    [[EaseMob sharedInstance].chatManager asyncSendMessage:msgObj progress:nil prepare:^(EMMessage *message, EMError *error) {
        NSLog(@"准备发送消息");
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        NSLog(@"完成发送消息 %@",error);
    } onQueue:nil];
    
    
    // 把刚发的消息添加都数据源，并刷新表格
    [self.dataSources addObject:msgObj];
    [self.tableView reloadData];
    
    // 把刚发送的消息显示在最上面
    [self scrollToBottom];
    
}


-(void)scrollToBottom{
    
    if (self.dataSources.count == 0) {
        return;
    }
    // 获取最后一行
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:self.dataSources.count - 1 inSection:0];
    
    [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}



#pragma mark 接收好友回复信息
-(void)didReceiveMessage:(EMMessage *)message{
    
    // from 必须等于当前聊天用户
    if ([message.from isEqualToString:self.buddy.username]) {
    

    //1.把接收的消息添加到数据源
    [self.dataSources addObject:message];
    
    //2.刷新表格
    [self.tableView reloadData];
    
    //3.显示数据到底部
    [self scrollToBottom];
        
   
    }
}



@end
