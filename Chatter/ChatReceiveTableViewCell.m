//
//  ChatReceiveTableViewCell.m
//  Chatter
//
//  Created by JW on H28/06/11.
//  Copyright © 平成28年 JumboStudio. All rights reserved.
//

#import "ChatReceiveTableViewCell.h"

@implementation ChatReceiveTableViewCell


-(void)setMessage:(EMMessage *)message{
    
    _message = message;
    
    // 获取消息体
    id body = message.messageBodies[0];
    if ([body isKindOfClass:[EMTextMessageBody class] ]) { // 文本消息
        
        EMTextMessageBody * textBody = body;
        self.messageLabel.text = textBody.text;
    }else if ([body isKindOfClass:[EMVoiceMessageBody class]]){
        self.messageLabel.text = @ "voice";
    }else{
        self.messageLabel.text = @"未知的类型";
    }
    
}



-(CGFloat)cellHeight{
    
    [self layoutIfNeeded];
    
    return 5 + 10 + self.messageLabel.bounds.size.height + 10 + 5;
    

}


@end
