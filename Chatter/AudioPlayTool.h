//
//  AudioPlayTool.h
//  Chatter
//
//  Created by JW on H28/07/18.
//  Copyright © 平成28年 JumboStudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioPlayTool : NSObject

+(void)playWithMessage:(EMMessage *)msg msgLabel:(UILabel *)msgLabel receiver:(BOOL)receiver;

@end
