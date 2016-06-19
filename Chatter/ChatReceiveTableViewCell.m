//
//  ChatReceiveTableViewCell.m
//  Chatter
//
//  Created by JW on H28/06/11.
//  Copyright © 平成28年 JumboStudio. All rights reserved.
//

#import "ChatReceiveTableViewCell.h"

@implementation ChatReceiveTableViewCell

-(CGFloat)cellHeight{
    
    [self layoutIfNeeded];
    
    return 5 + 10 + self.messageLabel.bounds.size.height + 10 + 5;
    

}


@end
