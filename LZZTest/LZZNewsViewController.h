//
//  LZZNewsViewController.h
//  LZZTest
//
//  Created by lucas on 5/13/13.
//  Copyright (c) 2013 lucas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@interface LZZNewsViewController : UIViewController <ASIHTTPRequestDelegate>

@property (nonatomic, copy) NSString *newsTitle;
@property (nonatomic, copy) NSString *newsCategory;
@property (nonatomic, retain) NSNumber *newsTime;
@property (nonatomic, copy) NSString *newsContent;

@end
