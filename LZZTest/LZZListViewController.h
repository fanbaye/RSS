//
//  LZZListViewController.h
//  LZZTest
//
//  Created by lucas on 5/13/13.
//  Copyright (c) 2013 lucas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "EGORefreshTableHeaderView.h"
#import "LZZRefreshTableFooterView.h"

@interface LZZListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate, EGORefreshTableHeaderDelegate, LZZRefreshTableFooterDelegate>

@end
