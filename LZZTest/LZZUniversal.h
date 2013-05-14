//
//  LZZUniversal.h
//  LZZTest
//
//  Created by lucas on 5/13/13.
//  Copyright (c) 2013 lucas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LZZUniversal : NSObject

+ (NSString *)newsSubTitleFromContent:(NSString *)content;
+ (NSString *)newsImageUrlFromContent:(NSString *)content;
+ (NSTimeInterval)dateFormatter:(NSString *)timeString;
+ (NSMutableArray *)getNewsContents:(NSString *)content;
+ (NSString *)timeIntervalToDate:(NSTimeInterval)timeInterval;
+ (NSString *)newsTitleFromXMLTitle:(NSString *)XMLTitle;

@end
