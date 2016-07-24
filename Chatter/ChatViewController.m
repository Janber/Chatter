//
//  ChatViewController.m
//  Chatter
//
//  Created by JW on 5/8/28 H.
//  Copyright © 28 Heisei JumboStudio. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatReceiveTableViewCell.h"
#import "EMCDDeviceManager.h"
#import "AudioPlayTool.h"
#import "TimeCell.h"
#import "TimeTool.h"


@interface ChatViewController ()<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,EMChatManagerDelegate,
UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

/** 输入工具条底部的约束**/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewButtonConstraint;

@property (nonatomic, strong) NSMutableArray *dataSources;

@property (nonatomic, strong) ChatReceiveTableViewCell *chatCellTool;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

/** InputTool Bar 高度的约束 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputToolBarHeightConstraint;

@property (weak, nonatomic) IBOutlet UIButton *recordBtn;


/** 当前添加的时间 */
@property (nonatomic, copy) NSString *currentTimeStr;

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
    
    //设置背景颜色
    self.tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
    
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
    //假设在数组的第一位置添加时间
    //[self.dataSources addObject:@"16:06"];
    
    // 要获取本地用户会话
    EMConversation * conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:self.buddy.username conversationType:eConversationTypeChat];
    
    // 加载当前聊天用户所以得聊天记录
    NSArray *messages = [conversation loadAllMessages];
    
    
    
    // 添加到数据源
 //   [self.dataSources addObjectsFromArray:messages];
    for (EMMessage *msgObj in messages) {
        [self addDateSourcesWithMessage:msgObj];
    }
    
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
    // 时间cell的高度是固定
    if ([self.dataSources[indexPath.row] isKindOfClass:[NSString class]]) {
        
        return 15;
    }

    
    
    
    
    // 获取消息模型
    EMMessage *msg = self.dataSources[indexPath.row];
    
    
    self.chatCellTool.message = msg;
    
    
    return [self.chatCellTool cellHeight];
}



-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //判断数据源类型
    if ([self.dataSources[indexPath.row] isKindOfClass:[NSString class]]) { //显示时间cell
        TimeCell *timeCell = [tableView dequeueReusableCellWithIdentifier:@"TimeCell"];
        timeCell.timeLabel.text = self.dataSources[indexPath.row];
        return timeCell;
    }
    
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
   // 1.计算TextView的高度，调整整个InputToolBar 高度
    CGFloat textViewH = 0;
    CGFloat minHeight = 33; //textView最小高度
    CGFloat maxHeight = 68; //textView最大高度
    
    // 2.获取contentSize的高度
    CGFloat contentHeight = textView.contentSize.height;
    
    if (contentHeight < minHeight) {
        textViewH = minHeight;
    }else if (contentHeight > maxHeight){
        textViewH = maxHeight;
    }else{
        textViewH = contentHeight;
    }
 
    // 3.监听Send事件 -- 判断最后的一个字符是不是换行字符
    if ([textView.text hasSuffix:@"\n"]){
        

        [self sendMessage:textView.text];
        
        // 清空textView的文字
        textView.text = nil;
        
        // 发送时，textViewH的高度为33
        textViewH = minHeight;
    }
    
    // 4.调整整个InputToolBar高度
    self.inputToolBarHeightConstraint.constant = 6 + 7 + textViewH;
    
    // 加个动画
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    
    // 5.让光标回到原位
    [textView setContentOffset:CGPointZero animated:YES];
    [textView scrollRangeToVisible:textView.selectedRange];
    
    
}


#pragma mark 发送文本
-(void)sendMessage:(NSString *)text{
    
    // 把最后一个换行字符去掉
    text = [text substringToIndex:text.length - 1];
    
    // 消息 = 消息头 + 消息体
    
    // 创建一个聊天文本对象
    EMChatText * chatText = [[EMChatText alloc] initWithText:text];
    
    // 创建一个文本消息体
    EMTextMessageBody * textBody = [[EMTextMessageBody alloc] initWithChatObject:chatText];
    
    [self sendMessageBase:textBody];
    
}


#pragma mark 发送语音
-(void)sendVoice:(NSString *)recordPath duration:(NSInteger)duration{

    //1.构造一个语音的消息体
    EMChatVoice *chatVoice = [[EMChatVoice alloc] initWithFile:recordPath displayName:@"[语音]"];
    
    EMVoiceMessageBody *voiceBody = [[EMVoiceMessageBody alloc] initWithChatObject:chatVoice];
    
    voiceBody.duration = duration;
    
    [self sendMessageBase:voiceBody];
    
}

#pragma mark 发送图片
-(void)sendImg:(UIImage *)selectedImg{
    //1.构造图片消息体
    /*
     * 第一个参数：原始大小的图片对象
     * 第二个参数：缩略图的图片对象
     */
    EMChatImage *orginalChatImg = [[EMChatImage alloc] initWithUIImage:selectedImg displayName:@"图片"];
    
    EMImageMessageBody *imgBody = [[EMImageMessageBody alloc] initWithImage:orginalChatImg thumbnailImage:nil];
    
    [self sendMessageBase:imgBody];

}


-(void)sendMessageBase:(id<IEMMessageBody>)body{
    //1.构造消息对象
    EMMessage *msgObj = [[EMMessage alloc] initWithReceiver:self.buddy.username bodies:@[body]];
    msgObj.messageType = eMessageTypeChat;
    
    //2.发送消息
    [[EaseMob sharedInstance].chatManager asyncSendMessage:msgObj progress:nil prepare:^(EMMessage *message, EMError *error) {
        NSLog(@"准备发送");
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        NSLog(@"发送成功 %@",error);
    } onQueue:nil];
    
    // 把刚发的消息添加都数据源，并刷新表格
    [self addDateSourcesWithMessage:msgObj];
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


#pragma mark - Action

- (IBAction)voiceAction:(UIButton *)sender {
    
    //1.显示录音按钮
    self.recordBtn.hidden = !self.recordBtn.hidden;
    self.textView.hidden = !self.textView.hidden;
    
    if (self.recordBtn.hidden == NO ) { //录音按钮显示
        
        // InputToolBar 的高度要回到默认（46）
        self.inputToolBarHeightConstraint.constant = 46;
        
        // 隐藏键盘
        [self.view endEditing:YES];
    }else{
        // 当不录音的时候，键盘显示
        [self.textView becomeFirstResponder];
        
        [self textViewDidChange:self.textView];
        
    }
    
}


#pragma mark 按下去就开始录音
- (IBAction)beginRecordAction:(id)sender {
    
    // 文件名以时间命名
    int x = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *filename = [NSString stringWithFormat:@"%d%d",(int)time,x];
    
    [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:filename completion:^(NSError *error) {
        if (!error) {
            NSLog(@"开始录音");
        }
        
    }];


}

#pragma mark 手指从按钮范围内松开结束录音，并发送给服务器
- (IBAction)endRecordAction:(id)sender {
    
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
       
        if (!error) {
            NSLog(@"录音成功");
            //发送语音给服务器
            [self sendVoice:recordPath duration:aDuration];
            
        }
        
    }];

}


#pragma mark 手指从按钮范围外松开取消录音
- (IBAction)cancelRecordAction:(id)sender {
    
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
    
}

- (IBAction)showImgPicker:(id)sender {
    //显示图片选择的控制器
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    
    //设置源
    imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imgPicker.delegate = self;
    
    [self presentViewController:imgPicker animated:YES completion:NULL];
    
}

/*用户选择图片后的回调*/
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //1.获取用户选中的图片
    UIImage *selectedImg = info[UIImagePickerControllerOriginalImage];
    
    //2.发送图片
    [self sendImg:selectedImg];
    
    //3.隐藏当前图片选择控制器
    [self dismissViewControllerAnimated:YES completion:NULL];
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //停止语音播放
    [AudioPlayTool stop];
    
}

-(void)addDateSourcesWithMessage:(EMMessage *) msg{
    // 1.判断EMMessage对象前面是否要加“时间”
    NSString *timeStr = [TimeTool timeStr:msg.timestamp];
    if (![self.currentTimeStr isEqualToString:timeStr]) {
        [self.dataSources addObject:timeStr];
        self.currentTimeStr = timeStr;
    }
    
    // 2.再添加EMMessage对象
    [self.dataSources addObject:msg];
    
}

@end
