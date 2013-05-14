//
//  LZZFrameViewController.m
//  LZZTest
//
//  Created by lucas on 5/13/13.
//  Copyright (c) 2013 lucas. All rights reserved.
//

#import "LZZFrameViewController.h"
#import "LZZNewsViewController.h"
#import "LZZDatabaseManager.h"
#import "LZZNewsItem.h"
#import "LZZDatabaseManager.h"

@interface LZZFrameViewController ()

@end

@implementation LZZFrameViewController

{
    UIScrollView *_scrollView;
    UILabel *_pageLabel;
    int _newsMaxId;
}

@synthesize newsId = _newsId;
@synthesize tableView = _tableView;
@synthesize newsOriginId = _newsOriginId;

- (void)dealloc
{
    self.tableView = nil;
    [super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(320*3, 460);
    _scrollView.contentOffset = CGPointMake(320, 0);
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    [_scrollView release];
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    headView.backgroundColor = [UIColor whiteColor];
    headView.alpha = 0.9;
    [self.view addSubview:headView];
    [headView release];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(hideFrameViewController) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 5, 50, 34);
    [headView addSubview:btn];

    UIImageView *headBottomLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 42, 320, 2)];
    [headBottomLine setImage:[UIImage imageNamed:@"headBottomLine"]];
    [headView addSubview:headBottomLine];
    [headBottomLine release];
    
    UIImageView *headRight = [[UIImageView alloc] initWithFrame:CGRectMake(238, 9, 68, 27)];
    headRight.image = [UIImage imageNamed:@"pageShow"];
    [headView addSubview:headRight];
    [headRight release];
    
    _pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 48, 17)];
    _pageLabel.textAlignment = NSTextAlignmentCenter;
    _pageLabel.font = [UIFont systemFontOfSize:14];
    _pageLabel.textColor = [UIColor whiteColor];
    _pageLabel.backgroundColor = [UIColor clearColor];
    [headRight addSubview:_pageLabel];
    [_pageLabel release];
    
    
    LZZDatabaseManager *db = [[LZZDatabaseManager alloc] init];
    _newsMaxId = [db getMaxNewsId];
    [db close];
    [db release];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![ud objectForKey:@"isFirstOpenDetail"]) {
        UIImageView *guideView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
        guideView.userInteractionEnabled = YES;
        guideView.image = [UIImage imageNamed:@"guide"];
        guideView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:guideView];
        [guideView release];
        
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideGuideView:)];
        [guideView addGestureRecognizer:tgr];
        [tgr release];
        
        [ud setBool:YES forKey:@"isFirstOpenDetail"];
        [ud synchronize];
    }
}

- (void)hideGuideView:(UITapGestureRecognizer *)sender
{
    [UIView animateWithDuration:1.5 animations:^{
        sender.view.alpha = 0;
    } completion:^(BOOL finished) {
        [sender.view removeFromSuperview];
    }];

}

- (void)showAlert
{
    if (_newsId == 0) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"到头了" message:@"亲，前面没有更多的文章了" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [av show];
        [av release];
    }else if (_newsId == _newsMaxId) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"到头了" message:@"亲，后面没有更多的文章了" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [av show];
        [av release];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _newsId = _newsOriginId;
    _pageLabel.text = [NSString stringWithFormat:@"第%d条", _newsId + 1];
    [self changeViewController:_newsId];
    [self showAlert];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_newsOriginId inSection:0];
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)changeViewController:(int)newsId
{
    LZZDatabaseManager *db = [[LZZDatabaseManager alloc] init];
    NSArray *array = [[NSArray alloc] initWithArray:[db getThreeNews:newsId]];

    [db close];
    [db release];
    for (int i = 0; i < 3; i++) {
        LZZNewsViewController *nvc = [[LZZNewsViewController alloc] init];
        LZZNewsItem *news = [array objectAtIndex:i];
        nvc.newsTitle = news.newsTitle;
        nvc.newsCategory = news.newsCategory;
        nvc.newsTime = news.newsTime;
        nvc.newsContent = news.newsContent;
        nvc.view.frame = CGRectMake(i*320, 0, 320, 460);
        [_scrollView addSubview:nvc.view];
        [self addChildViewController:nvc];
        [nvc release];
    }
    [array release];
}


- (void)hideFrameViewController
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    int index = 1;
    int currentIndex = (int)scrollView.contentOffset.x/320;
    if (currentIndex == index) {
        return;
    }else{
        [scrollView setContentOffset:CGPointMake(320, 0)];
        if (currentIndex > index) {
            _newsId = _newsId + 1;
            [self changeViewController:_newsId];
        }else{
            _newsId = _newsId - 1;
            [self changeViewController:_newsId];
        }
    }
    _pageLabel.text = [NSString stringWithFormat:@"第%d条", _newsId + 1];
    [self showAlert];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float currentOffSizeX = scrollView.contentOffset.x;
    if (_newsId == 0 && currentOffSizeX < 320) {
        scrollView.contentOffset = CGPointMake(320, 0);
    }else if (_newsId == _newsMaxId && currentOffSizeX > 320){
        scrollView.contentOffset = CGPointMake(320, 0);
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
