//
//  LZZNewsItem.m
//  LZZTest
//
//  Created by lucas on 5/13/13.
//  Copyright (c) 2013 lucas. All rights reserved.
//

#import "LZZNewsItem.h"

@implementation LZZNewsItem

@synthesize newsId = _newsId;
@synthesize newsContent = _newsContent;
@synthesize newsImageUrl = _newsImageUrl;
@synthesize newsSubTitle = _newsSubTitle;
@synthesize newsTime = _newsTime;
@synthesize newsTitle = _newsTitle;
@synthesize newsCategory = _newsCategory;

- (void)dealloc
{
    self.newsImageUrl = nil;
    self.newsTitle = nil;
    self.newsSubTitle = nil;
    self.newsContent = nil;
    self.newsTime = nil;
    self.newsCategory = nil;
    [super dealloc];
}

@end
