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


@implementation ChatReceiveTableViewCell


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
    
    _message = message;
    
    // 获取消息体
    id body = message.messageBodies[0];
    if ([body isKindOfClass:[EMTextMessageBody class] ]) { // 文本消息
        
        EMTextMessageBody * textBody = body;
        self.messageLabel.text = textBody.text;
    }else if ([body isKindOfClass:[EMVoiceMessageBody class]]){
//        self.messageLabel.text = @ "voice";
        self.messageLabel.attributedText = [self voiceAtt];
  
        
    }else{
        self.messageLabel.text = @"未知的类型";
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
