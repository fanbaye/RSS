//
//  LZZNewsItem.h
//  LZZTest
//
//  Created by lucas on 5/13/13.
//  Copyright (c) 2013 lucas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LZZNewsItem : NSObject

@property (nonatomic, assign) int newsId;
@property (nonatomic, copy) NSString *newsImageUrl;
@property (nonatomic, copy) NSString *newsTitle;
@property (nonatomic, copy) NSString *newsSubTitle;
@property (nonatomic, copy) NSString *newsContent;
@property (nonatomic, retain) NSNumber *newsTime;
@property (nonatomic, copy) NSString *newsCategory;

@end
