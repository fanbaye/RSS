//
//  LZZListViewController.m
//  LZZTest
//
//  Created by lucas on 5/13/13.
//  Copyright (c) 2013 lucas. All rights reserved.
//

#import "LZZListViewController.h"
#import "LZZNewsCell.h"
#import "GDataXMLNode.h"
#import "LZZUniversal.h"
#import "LZZNewsItem.h"
#import "LZZDatabaseManager.h"
#import "NSString+Hashing.h"
#import "LZZFrameViewController.h"
#import "LZZSettingViewController.h"

@interface LZZListViewController ()

@property (nonatomic, retain) NSMutableArray *dataArray;

@end

@implementation LZZListViewController

{
    LZZFrameViewController *_fvc;
    UITableView *_tableView;
    BOOL _isLoading;
    EGORefreshTableHeaderView *_refreshHeadView;
    LZZRefreshTableFooterView *_refreshFootView;
    LZZSettingViewController *_svc;
}

@synthesize dataArray = _dataArray;

- (void)dealloc
{
    [_fvc release];
    [_svc release];
    self.dataArray = nil;
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
    _isLoading = NO;
    
    _fvc = [[LZZFrameViewController alloc] init];
    _svc = [[LZZSettingViewController alloc] init];
    _svc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	// Do any additional setup after loading the view.
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, 480-44-20)];
    _tableView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:_tableView];
    [_tableView release];
    
    _refreshHeadView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -416, 320, 416)];
    [_refreshHeadView refreshLastUpdatedDate];
    _refreshHeadView.delegate = self;
    [_tableView addSubview:_refreshHeadView];
    [_refreshHeadView release];
    
    _refreshFootView = [[LZZRefreshTableFooterView alloc] initWithFrame:CGRectMake(0, 416, 320, 416)];
    [_refreshFootView refreshLastUpdatedDate];
    _refreshFootView.delegate = self;
    [_tableView addSubview:_refreshFootView];
    [_refreshFootView release];
    
    UIImageView *headView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"head"]];
    headView.userInteractionEnabled = YES;
    headView.frame = CGRectMake(0, 0, 320, 44);
    [self.view addSubview:headView];
    [headView release];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(287, 10, 21, 23);
    [btn setImage:[UIImage imageNamed:@"settingbottom"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(settingClick) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:btn];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![ud objectForKey:@"isFirstOpenApp"]) {
        _isLoading = YES;
        [self getNewsFromInternet];
        [ud setBool:YES forKey:@"isFirstOpenApp"];
        [ud synchronize];
    }else{
        [self getNewsFromDatabase];
    }
}

- (void)settingClick
{
    [self presentViewController:_svc animated:YES completion:^{
        
    }];
}

- (void)getNewsFromInternet
{
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:@"http://rss.dayoo.com/feed/news/ent.xml"]];
    request.delegate = self;
    request.tag = 1000;
    [request startAsynchronous];
}

- (void)getNewsFromDatabase
{
    LZZDatabaseManager *dbManager = [[LZZDatabaseManager alloc] init];
    self.dataArray = [dbManager newsFromDatabase];
    [dbManager close];
    [dbManager release];
}

- (void)updateData
{
    [self getNewsFromDatabase];
    [_tableView reloadData];
}

#pragma mark - ASIHTTPRequest Delegate Methods
- (void)requestFinished:(ASIHTTPRequest *)request
{
    if (request.tag == 1000) {
        LZZDatabaseManager *dbManager = [[LZZDatabaseManager alloc] init];
        [dbManager databaseResetTable];
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:request.responseData options:0 error:nil];
        GDataXMLElement *rootEle = [doc rootElement];
        GDataXMLElement *channel = [[rootEle elementsForName:@"channel"] objectAtIndex:0];
        NSArray *itemArray = [channel elementsForName:@"item"];
        int i = 0;
        for (GDataXMLElement *item in itemArray) {
            LZZNewsItem *news = [[LZZNewsItem alloc] init];
            
            news.newsId = i++;
            
            GDataXMLElement *title = [[item elementsForName:@"title"] objectAtIndex:0];
            news.newsTitle = [LZZUniversal newsTitleFromXMLTitle:title.stringValue];
            
            GDataXMLElement *time = [[item elementsForName:@"pubDate"] objectAtIndex:0];
            news.newsTime = [NSNumber numberWithDouble:[LZZUniversal dateFormatter:time.stringValue]];
            
            GDataXMLElement *content = [[item elementsForName:@"description"] objectAtIndex:0];
            news.newsContent = content.stringValue;
            
            news.newsSubTitle = [LZZUniversal newsSubTitleFromContent:content.stringValue];
            
            news.newsImageUrl = [LZZUniversal newsImageUrlFromContent:content.stringValue];
            
            GDataXMLElement *category = [[item elementsForName:@"category"] objectAtIndex:0];
            news.newsCategory = category.stringValue;
            
            [dbManager databaseInsertNews:news];
            [news release];
        }
        [dbManager close];
        [dbManager release];
        [doc release];
        
        [self updateData];
    }else{
        NSString *url = [NSString stringWithFormat:@"%@", request.url];
        NSString *path = [NSString stringWithFormat:@"%@/tmp/%@", NSHomeDirectory(), [url MD5Hash]];
        [request.responseData writeToFile:path atomically:NO];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:request.tag inSection:0];
        LZZNewsCell *cell = (LZZNewsCell *)[_tableView cellForRowAtIndexPath:indexPath];
        cell.newsImageView.image = [UIImage imageWithData:request.responseData];
    }
    
    [_refreshHeadView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
    [_refreshFootView lzzRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
    _isLoading = NO;
    
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [_refreshHeadView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
    [_refreshFootView lzzRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
    _refreshFootView.hidden = YES;
    _isLoading = NO;
    NSLog(@"下载失败");
}

#pragma mark - TableView Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 71.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"cell";
    LZZNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[[LZZNewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    LZZNewsItem *news = [_dataArray objectAtIndex:indexPath.row];
    cell.newsTitleLabel.text = news.newsTitle;
    cell.newsSubTitleLabel.text = news.newsSubTitle;
    cell.newsTimeLabel.text = [LZZUniversal timeIntervalToDate:[news.newsTime doubleValue]];
    
    cell.newsImageView.image = [UIImage imageNamed:@"imagePlaceholder"];
    if (news.newsImageUrl) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *path = [NSString stringWithFormat:@"%@/tmp/%@", NSHomeDirectory(), [news.newsImageUrl MD5Hash]];
        BOOL ret = [fm fileExistsAtPath:path];
        if (ret) {
            cell.newsImageView.image = [UIImage imageWithContentsOfFile:path];
        }else{
            ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:news.newsImageUrl]];
            
            request.delegate = self;
            request.tag = indexPath.row;
            [request startAsynchronous];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LZZNewsItem *news = [_dataArray objectAtIndex:indexPath.row];
    _fvc.newsOriginId = news.newsId;
    _fvc.tableView = _tableView;
    [self presentViewController:_fvc animated:YES completion:^{
        
    }];
}

#pragma mark - TableViewRefresh Delegate Methods
- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _isLoading;
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    _isLoading = YES;
    // 有网的时候打开
    [self getNewsFromInternet];
}

#pragma mark - TableViewRefresh Delegate Methods
- (NSDate *)lzzRefreshTableFooterDataSourceLastUpdated:(LZZRefreshTableFooterView *)view
{
    return [NSDate date];
}

- (BOOL)lzzRefreshTableFooterDataSourceIsLoading:(LZZRefreshTableFooterView *)view
{
    return _isLoading;
}

- (void)lzzRefreshTableFooterDidTriggerRefresh:(LZZRefreshTableFooterView *)view
{
    _isLoading = YES;
    // 有网的时候打开
    [self getNewsFromInternet];
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeadView egoRefreshScrollViewDidEndDragging:scrollView];
    _refreshFootView.hidden = NO;
    [_refreshFootView lzzRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeadView egoRefreshScrollViewDidScroll:scrollView];
    [_refreshFootView lzzRefreshScrollViewDidScroll:scrollView];
}


@end
