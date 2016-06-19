//
//  ChatReceiveTableViewCell.h
//  Chatter
//
//  Created by JW on H28/06/11.
//  Copyright © 平成28年 JumboStudio. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *ReceiverCell = @"ReceiverCell";
static NSString *SenderCell = @"SenderCell";

@interface ChatReceiveTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

-(CGFloat)cellHeight;

@end
