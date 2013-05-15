//
//  LZZUniversal.m
//  LZZTest
//
//  Created by lucas on 5/13/13.
//  Copyright (c) 2013 lucas. All rights reserved.
//

#import "LZZUniversal.h"

@implementation LZZUniversal

+ (NSString *)newsTitleFromXMLTitle:(NSString *)XMLTitle
{
    // 恶心的特殊标题格式去除
    while ([XMLTitle hasPrefix:@"\n"]) {
        XMLTitle = [XMLTitle substringFromIndex:1];
    }
    while ([XMLTitle hasPrefix:@" "]) {
        XMLTitle = [XMLTitle substringFromIndex:1];
    }
    
    // 不恶心的标题格式去除
    NSCharacterSet *LCset = [NSCharacterSet characterSetWithCharactersInString:@"： "];
    NSRange range = [XMLTitle rangeOfCharacterFromSet:LCset];
    if (range.length) {
        XMLTitle = [XMLTitle substringToIndex:range.location];
    }
    return XMLTitle;
}

// 得到内容简介
+ (NSString *)newsSubTitleFromContent:(NSString *)content
{
    // 取正文第一句作为内容简介，先找正文
    
    NSRange rangeLeft = [content rangeOfString:@"<p"];
    NSRange rangeRight = [content rangeOfString:@"</p>"];
    NSString *tmp = [content substringWithRange:NSMakeRange(rangeLeft.location, rangeRight.location - rangeLeft.location + 4)];
    while ([tmp rangeOfString:@"img"].length || [tmp rangeOfString:@"center"].length) {
        content = [content substringFromIndex:rangeRight.location + 3];
        rangeLeft = [content rangeOfString:@"<p"];
        rangeRight = [content rangeOfString:@"</p>"];
        tmp = [content substringWithRange:NSMakeRange(rangeLeft.location, rangeRight.location - rangeLeft.location + 4)];
    }
    // 再找句号
    NSRange range = [tmp rangeOfString:@"。"];
    if (!range.length) {
        return @"只有图片，请欣赏图片吧";
    }
    tmp = [tmp substringToIndex:range.location + 1];
    // 倒序找第一个标识
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@";>"];
    range = [tmp rangeOfCharacterFromSet:set options:NSBackwardsSearch];
    tmp = [tmp substringFromIndex:range.location + 1];
    
    // 去除不知名的字符 和　（一共两个字符，后面那个不是空格，不知道是什么）
    NSCharacterSet *LCset = [NSCharacterSet characterSetWithCharactersInString:@" 　\n"];
    range = [tmp rangeOfCharacterFromSet:LCset];
    while (range.length) {
        tmp = [tmp substringFromIndex:1];
        range = [tmp rangeOfCharacterFromSet:LCset];
    }
    
    // 如果第一句太长就截断
    if ([tmp length] < 29) {
        return tmp;
    }else{
        return [NSString stringWithFormat:@"%@...", [tmp substringToIndex:28]];
    }
    
}

// 从正文得到第一张图片作为cell的图片
+ (NSString *)newsImageUrlFromContent:(NSString *)content
{
    NSRange range = [content rangeOfString:@"src=\""];
    if (!range.length) {
        return nil;
    }
    content = [content substringFromIndex:range.location + 5];
    range = [content rangeOfString:@"\""];
    content = [content substringToIndex:range.location];
    return content;
}

// 将正文分类型保存为数组，4类，0是图片，1是图片的标题，2是粗体文本，3是普通文本
+ (NSMutableArray *)getNewsContents:(NSString *)content
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSRange rangeLeft = [content rangeOfString:@"<p"];
    while (rangeLeft.length) {
        NSRange rangeRight = [content rangeOfString:@"</p>"];
        NSString *tmp = [content substringWithRange:NSMakeRange(rangeLeft.location, rangeRight.location - rangeLeft.location + 4)];
        
        if ([tmp rangeOfString:@"chcom"].length) {
            content = [content substringFromIndex:rangeRight.location + 3];
            rangeLeft = [content rangeOfString:@"<p"];
            continue;
        }
        
        NSRange rangeImage = [tmp rangeOfString:@"src"];
        if (rangeImage.length) {
            [array addObject:@"0"];
            [array addObject:[self newsImageUrlFromContent:tmp]];
        }else{
            NSRange rangeDescription = [tmp rangeOfString:@"center"];
            if (rangeDescription.length) {
                [array addObject:@"1"];
                tmp = [self getDescriptionFromContent:tmp];
                [array addObject:[self deleteSpecialString:tmp]];
            }else{
                NSRange rangeStrong = [tmp rangeOfString:@"strong"];
                if (rangeStrong.length) {
                    NSRange rangeStrongLeft = [tmp rangeOfString:@"<strong>"];
                    NSRange rangeStrongRight = [tmp rangeOfString:@"</strong>"];
                    tmp = [tmp substringWithRange:NSMakeRange(rangeStrongLeft.location + 8, rangeStrongRight.location - rangeStrongLeft.location - 8)];
                    [array addObject:@"2"];
                    [array addObject:[self deleteSpecialString:tmp]];
                }else{
                    [array addObject:@"3"];
                    tmp = [self getDescriptionFromContent:tmp];
                    [array addObject:[self deleteSpecialString:tmp]];
                }
            }
            
        }
        content = [content substringFromIndex:rangeRight.location + 3];
        rangeLeft = [content rangeOfString:@"<p"];
    }
    return array;
}



// 将时间戳转换为想显示的格式
+ (NSString *)timeIntervalToDate:(NSTimeInterval)timeInterval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    // 一般的显示格式
//    NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
//    [df setDateFormat:@"MM-d hh:mm"];
//    return [df stringFromDate:date];
    
    // 有趣些的时间显示格式
    NSTimeInterval time = [date timeIntervalSinceNow];
    time = -time;
    if (time < 60*60) {
        return @"刚刚";
    }else if (time < 60*60*24){
        return [NSString stringWithFormat:@"%d个小时前", (int)time/(60*60)];
    }else{
        return [NSString stringWithFormat:@"%d天前", (int)time/(60*60*24)];
    }

}

// 将从xml得到的时间格式转换为可识别的格式的时间戳
+ (NSTimeInterval)dateFormatter:(NSString *)timeString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE, d MM yyyy hh:mm:ss +S"];
    NSDate *date = [formatter dateFromString:timeString];
    [formatter release];
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    return timeInterval;
}

// 删除奇怪字符
+ (NSString *)deleteSpecialString:(NSString *)string
{
    NSMutableString *mStr = [NSMutableString stringWithString:string];
    NSRange range = [mStr rangeOfString:@"&#160;"];
    while (range.length) {
        [mStr deleteCharactersInRange:range];
        range = [mStr rangeOfString:@"&#160;"];
    }
    return mStr;
}

// 得到正文一个段落
+ (NSString *)getDescriptionFromContent:(NSString *)content
{
    NSRange rangeLeft = [content rangeOfString:@">"];
    NSRange rangeRight = [content rangeOfString:@"</p>"];
    return [content substringWithRange:NSMakeRange(rangeLeft.location + 1, rangeRight.location - rangeLeft.location - 1)];
}


@end
