//
//  LZZDatabaseManager.m
//  LZZTest
//
//  Created by lucas on 5/13/13.
//  Copyright (c) 2013 lucas. All rights reserved.
//

#import "LZZDatabaseManager.h"
#import "FMDatabase.h"

@implementation LZZDatabaseManager

{
    FMDatabase *_database;
}

- (id)init
{
    if (self = [super init]) {
        NSString *path = NSHomeDirectory();
        path = [path stringByAppendingPathComponent:@"documents/data.db"];
        _database = [FMDatabase databaseWithPath:path];
        BOOL ret = [_database open];
        if (!ret) {
            NSLog(@"打开数据库失败");
            return self;
        }
        ret = [_database executeUpdate:@"create table if not exists news(id,imageUrl, title, subTitle, time, content, category)"];
        if (!ret) {
            NSLog(@"创建表失败");
            return self;
        }
    }
    return self;
}

- (BOOL)databaseInsertNews:(LZZNewsItem *)news
{
    BOOL ret = [_database executeUpdate:@"insert into news values(?,?,?,?,?,?,?)",[NSNumber numberWithInt:news.newsId], news.newsImageUrl, news.newsTitle, news.newsSubTitle, news.newsTime, news.newsContent, news.newsCategory];
    if (!ret) {
        NSLog(@"插入新闻失败");
        return NO;
    }
    return YES;
}

- (NSMutableArray *)newsFromDatabase
{
    NSMutableArray *array = [[[NSMutableArray alloc] initWithCapacity:10] autorelease];
    FMResultSet *set = [_database executeQuery:@"select * from news"];
    while ([set next]) {
        LZZNewsItem *news = [[LZZNewsItem alloc] init];
        [self getSetFrom:set ToNews:news];
        [array addObject:news];
        [news release];
    }
    return array;
}

- (NSMutableArray *)getThreeNews:(int)newsId
{
    NSMutableArray *array = [[[NSMutableArray alloc] initWithCapacity:3] autorelease];
    FMResultSet *set = [_database executeQuery:@"select * from news where id < ? order by id desc limit 1", [NSNumber numberWithInt:newsId]];
    [set next];
    LZZNewsItem *news = [[LZZNewsItem alloc] init];
    [self getSetFrom:set ToNews:news];
    [array addObject:news];
    [news release];
    
    FMResultSet *set2 = [_database executeQuery:@"select * from news where id >= ? limit 2", [NSNumber numberWithInt:newsId]];
    [set2 next];
    news = [[LZZNewsItem alloc] init];
    [self getSetFrom:set2 ToNews:news];
    [array addObject:news];
    [news release];
    
    [set2 next];
    news = [[LZZNewsItem alloc] init];
    [self getSetFrom:set2 ToNews:news];
    [array addObject:news];
    [news release];
    
    return array;
}

- (void)getSetFrom:(FMResultSet *)set ToNews:(LZZNewsItem *)news
{
    news.newsId = [set intForColumn:@"id"];
    news.newsImageUrl = [set stringForColumn:@"imageUrl"];
    news.newsTitle = [set stringForColumn:@"title"];
    news.newsSubTitle = [set stringForColumn:@"subTitle"];
    news.newsTime = [NSNumber numberWithDouble:[set doubleForColumn:@"time"]];
    news.newsContent = [set stringForColumn:@"content"];
    news.newsCategory = [set stringForColumn:@"category"];
}

- (int)getMaxNewsId
{
    FMResultSet *set = [_database executeQuery:@"select id from news order by id desc limit 1"];
    [set next];
    return [set intForColumn:@"id"];
}

- (BOOL)databaseResetTable
{
    BOOL ret = [_database executeUpdate:@"drop table news"];
    if (!ret) {
        NSLog(@"删除表格失败");
        return NO;
    }
    ret = [_database executeUpdate:@"create table if not exists news(id,imageUrl, title, subTitle, time, content, category)"];
    if (!ret) {
        NSLog(@"创建表失败");
        return NO;
    }
    return YES;
}

- (void)close
{
    [_database close];
}

@end
