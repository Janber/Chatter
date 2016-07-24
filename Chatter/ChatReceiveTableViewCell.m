//
//  ChatReceiveTableViewCell.m
//  Chatter
//
//  Created by JW on H28/06/11.
//  Copyright © 平成28年 JumboStudio. All rights reserved.
//

#import "ChatReceiveTableViewCell.h"
#import "EMCDDeviceManager.h"
#import "AudioPlayTool.h"
#import "UIImageView+WebCache.h"

@interface ChatReceiveTableViewCell()
/** 聊天图片控件 */
@property(nonatomic, strong)UIImageView * chatImgView;

@end

@implementation ChatReceiveTableViewCell

-(UIImageView *)chatImgView{
    if (!_chatImgView) {
        _chatImgView = [[UIImageView alloc] init];
    }
    return _chatImgView;
}





-(void)awakeFromNib{
    // 初始化
    // 1.给label添加敲击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageLabelTap:)];
    [self.messageLabel addGestureRecognizer:tap];
    
}

#pragma mark messagelabel 点击的触发方法
-(void)messageLabelTap:(UITapGestureRecognizer *)recognizer{
    NSLog(@"%s",__func__);
    // 播放语音
    // 只有当前的类型是为语音的类型时，才播放
    // 1.获取消息体
    id body = self.message.messageBodies[0];
    if ([body isKindOfClass:[EMVoiceMessageBody class]]) {
        
        NSLog(@"播放语音");
        BOOL receiver = [self.reuseIdentifier isEqualToString:ReceiverCell];
        [AudioPlayTool playWithMessage:self.message msgLabel:self.messageLabel receiver:receiver];
    }
    
}


-(void)setMessage:(EMMessage *)message{
    
    //重用时，把聊天图片控件删除
    [self.chatImgView removeFromSuperview];
    
    
    _message = message;
    
    // 获取消息体
    id body = message.messageBodies[0];
    if ([body isKindOfClass:[EMTextMessageBody class] ]) { // 文本消息
        
        EMTextMessageBody * textBody = body;
        self.messageLabel.text = textBody.text;
    }else if ([body isKindOfClass:[EMVoiceMessageBody class]]){
//        self.messageLabel.text = @ "voice";
        self.messageLabel.attributedText = [self voiceAtt];
        
    }else if([body isKindOfClass:[EMImageMessageBody class]]){
        [self showImage];
        
    }else{
        self.messageLabel.text = @"未知的类型";
    }
    
}


-(void)showImage{
   
    //获取图片消息体
    EMImageMessageBody *imgBody = self.message.messageBodies[0];
    CGRect thumbnailFrm =(CGRect){0,0,imgBody.thumbnailSize};

    
    // 设置Label的尺寸足够显示UIImageView
    NSTextAttachment *imgAttach = [[NSTextAttachment alloc] init];
    imgAttach.bounds =thumbnailFrm;
    NSAttributedString *imgAtt  = [NSAttributedString attributedStringWithAttachment:imgAttach];
    self.messageLabel.attributedText =imgAtt;
    
    //1.cell里添加一个UIImageView
  //  UIImageView *chatImgView = [[UIImageView alloc] init];
    [self.messageLabel addSubview:self.chatImgView];
  //  chatImgView.backgroundColor = [UIColor redColor];
    
    //2.设置图片控件为缩略图的尺寸
     self.chatImgView.frame = thumbnailFrm;
    
    //3.下载图片
    NSLog(@"thumbnailLocalPath%@",imgBody.thumbnailLocalPath);
    NSLog(@"thumbnailRemotePath%@",imgBody.thumbnailRemotePath);
    
    NSFileManager *manager = [NSFileManager defaultManager];
    //如果本地的图片存在，直接从本地显示
    UIImage *palceImg = [UIImage imageNamed:@"imageDownloading"];
    
    if ([manager fileExistsAtPath:imgBody.thumbnailLocalPath]) {
        
        [self.chatImgView sd_setImageWithURL:[NSURL fileURLWithPath:imgBody.thumbnailLocalPath] placeholderImage:palceImg];
        
    }else{
        //如果本地的图片存在，直接从网络显示
        [self.chatImgView sd_setImageWithURL:[NSURL URLWithString:imgBody.thumbnailRemotePath] placeholderImage:palceImg];
    }
}


#pragma mark 返回语音的富文本
-(NSAttributedString *) voiceAtt{
    //创建一个可变的富文本
    NSMutableAttributedString *voiceAttM = [[NSMutableAttributedString alloc] init];
    
    //接受方：富文本 = 图片 + 时间
    if ([self.reuseIdentifier isEqualToString:ReceiverCell]) {
        //接受方的语音图片
        UIImage *receiverImg = [UIImage imageNamed:@"chat_receiver_audio_playing_full"];
        
        //创建图片附件
        NSTextAttachment *imgAttachment = [[NSTextAttachment alloc] init];
        imgAttachment.image = receiverImg;
        imgAttachment.bounds = CGRectMake(0, -7, 30, 30);
        
        //图片富文本
        NSAttributedString *imagAtt = [NSAttributedString attributedStringWithAttachment:imgAttachment];
        
        [voiceAttM appendAttributedString:imagAtt];
        
        //创建时间的富文本
            //获取时间
        EMVoiceMessageBody *voiceBody = self.message.messageBodies[0];
        NSInteger duration = voiceBody.duration;
        NSString *timeStr = [NSString stringWithFormat:@"%ld'",(long)duration];
        NSAttributedString *timeAtt = [[NSAttributedString alloc] initWithString:timeStr];
        [voiceAttM appendAttributedString:timeAtt];
        
        
    }else{
    //发送方：富文本 = 时间 + 图片
        //创建时间的富文本
        //获取时间
        EMVoiceMessageBody *voiceBody = self.message.messageBodies[0];
        NSInteger duration = voiceBody.duration;
        NSString *timeStr = [NSString stringWithFormat:@"%ld'",(long)duration];
        NSAttributedString *timeAtt = [[NSAttributedString alloc] initWithString:timeStr];
        [voiceAttM appendAttributedString:timeAtt];
        

        //接受方的语音图片
        UIImage *receiverImg = [UIImage imageNamed:@"chat_sender_audio_playing_full"];
        
        //创建图片附件
        NSTextAttachment *imgAttachment = [[NSTextAttachment alloc] init];
        imgAttachment.image = receiverImg;
        imgAttachment.bounds = CGRectMake(0, -7, 30, 30);
        
        //图片富文本
        NSAttributedString *imagAtt = [NSAttributedString attributedStringWithAttachment:imgAttachment];
        
        [voiceAttM appendAttributedString:imagAtt];
    }
    
    return [voiceAttM copy];
    
}
    


-(CGFloat)cellHeight{
    
    [self layoutIfNeeded];
    
    return 5 + 10 + self.messageLabel.bounds.size.height + 10 + 5;
    

}


@end
