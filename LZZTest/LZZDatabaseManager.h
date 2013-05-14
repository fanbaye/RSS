//
//  LZZDatabaseManager.h
//  LZZTest
//
//  Created by lucas on 5/13/13.
//  Copyright (c) 2013 lucas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LZZNewsItem.h"

@interface LZZDatabaseManager : NSObject

- (BOOL)databaseInsertNews:(LZZNewsItem *)news;
- (NSMutableArray *)newsFromDatabase;
- (BOOL)databaseResetTable;
- (void)close;
- (NSMutableArray *)getThreeNews:(int)newsId;
- (int)getMaxNewsId;

@end
