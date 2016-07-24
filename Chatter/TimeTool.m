//
//  TimeTool.m
//  Chatter
//
//  Created by JW on H28/07/24.
//  Copyright © 平成28年 JumboStudio. All rights reserved.
//

#import "TimeTool.h"

@implementation TimeTool

+(NSString *)timeStr:(long long)timestamp{
    // 返回时间格式
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    //1.获取当前时间
    NSDate *currentDate = [NSDate date];
    
    // 获取年月日
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
    NSInteger currentYear = components.year;
    NSInteger currentMonth = components.month;
    NSInteger currentDay = components.day;
    
//    NSLog(@"currentYear %ld",(long)components.year);
//    NSLog(@"currentMonth %ld",(long)components.month);
//    NSLog(@"currentDay %ld",(long)components.day);
    
    //2.获取消息发送时间
    NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:timestamp/1000.0];
    
    // 获取年月日
    components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:msgDate];
    CGFloat msgYear = components.year;
    CGFloat msgMonth = components.month;
    CGFloat msgDay = components.day;
//    NSLog(@"currentDate%@",currentDate);
//    NSLog(@"msgDate%@",msgDate);
    
    
    
    //3.判断
    /* 今天：（HH:mm）
     *  昨天：（昨天HH:mm）
     *  昨天以前：(2015-09-26 15:27)
     */
    
    NSDateFormatter *dateFmr = [[NSDateFormatter alloc]init];
    
    
    if (currentYear == msgYear &&
        currentMonth == msgMonth &&
        currentDay == msgDay) { //今天
        dateFmr.dateFormat = @"HH:mm";
        
    }else if (currentYear == msgYear &&
              currentMonth == msgMonth &&
              currentDay - 1 == msgDay) { //昨天
        dateFmr.dateFormat = @"昨天 HH:mm";
    }else{//昨天以前
        dateFmr.dateFormat = @"yyyy-MM-dd HH:mm";
    }
    
    
    
    return [dateFmr stringFromDate:msgDate];
}

@end
