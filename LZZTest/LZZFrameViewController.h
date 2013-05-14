//
//  LZZFrameViewController.h
//  LZZTest
//
//  Created by lucas on 5/13/13.
//  Copyright (c) 2013 lucas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LZZFrameViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, assign) int newsOriginId;
@property (nonatomic, assign) int newsId;
@property (nonatomic, retain) UITableView *tableView;

@end
