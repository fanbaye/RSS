//
//  LZZNewsViewController.m
//  LZZTest
//
//  Created by lucas on 5/13/13.
//  Copyright (c) 2013 lucas. All rights reserved.
//

#import "LZZNewsViewController.h"
#import "LZZUniversal.h"
#import "NSString+Hashing.h"

@interface LZZNewsViewController ()

@end

@implementation LZZNewsViewController

{
    UIScrollView *_scrollView;
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
    _scrollView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    _scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_scrollView];
    [_scrollView release];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 18, 290, 21)];
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = _newsTitle;
    [_scrollView addSubview:titleLabel];
    [titleLabel release];
    
    UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 48, 70, 14)];
    categoryLabel.font = [UIFont systemFontOfSize:13];
    categoryLabel.textColor = [UIColor grayColor];
    categoryLabel.backgroundColor = [UIColor clearColor];
    categoryLabel.text = _newsCategory;
    [_scrollView addSubview:categoryLabel];
    [categoryLabel release];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(98, 48, 76, 14)];
    timeLabel.font = [UIFont systemFontOfSize:13];
    timeLabel.textColor = [UIColor grayColor];
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.text = [LZZUniversal timeIntervalToDate:[_newsTime doubleValue]];
    [_scrollView addSubview:timeLabel];
    [timeLabel release];
    
    
    int height = 82;
    NSArray *contentArray = [[NSArray alloc] initWithArray:[LZZUniversal getNewsContents:_newsContent]];
    for (int i = 0; i < [contentArray count]; i+=2) {
        if ([[contentArray objectAtIndex:i] isEqualToString:@"0"]) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, height, 290, 180)];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.tag = i;
            [imageView setImage:[UIImage imageNamed:@"imagePlaceholder"]];
            [_scrollView addSubview:imageView];
            [imageView release];
            
            NSString *imageUrl = [contentArray objectAtIndex:i + 1];
            NSString *path = [NSString stringWithFormat:@"%@/tmp/%@", NSHomeDirectory(), [imageUrl MD5Hash]];
            NSFileManager *fm = [NSFileManager defaultManager];
            BOOL ret = [fm fileExistsAtPath:path];
            if (ret) {
                imageView.image = [UIImage imageWithContentsOfFile:path];
            }else{
                // 发出下载图片请求
                ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageUrl]];
                request.tag = i;
                request.delegate = self;
                [request startAsynchronous];
            }
            
            
            height = height + 180 + 10;
        }else if ([[contentArray objectAtIndex:i] isEqualToString:@"1"]){
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, height, 290, 14)];
            label.font = [UIFont systemFontOfSize:12];
            label.text = [contentArray objectAtIndex:i + 1];
            label.textAlignment = NSTextAlignmentCenter;
            [_scrollView addSubview:label];
            [label release];
            height = height + 14 + 10;
        }else if ([[contentArray objectAtIndex:i] isEqualToString:@"2"]){
            NSString *string = [contentArray objectAtIndex:i + 1];
            CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(290, 1000) lineBreakMode:NSLineBreakByWordWrapping];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, height, 290, size.height)];
            label.font = [UIFont boldSystemFontOfSize:16];
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.text = string;
            [_scrollView addSubview:label];
            [label release];
            height = height + size.height + 10;
        }else{
            NSString *string = [contentArray objectAtIndex:i + 1];
            CGSize size = [string sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(290, 1000) lineBreakMode:NSLineBreakByWordWrapping];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, height, 290, size.height)];
            label.font = [UIFont systemFontOfSize:16];
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.text = string;
            [_scrollView addSubview:label];
            [label release];
            height = height + size.height + 10;
        }
    }
    
    _scrollView.contentSize = CGSizeMake(320, height);

}

#pragma mark - ASIHTTPRequest Delegate Methods
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *imageUrl = [NSString stringWithFormat:@"%@", request.url];
    NSString *path = [NSString stringWithFormat:@"%@/tmp/%@", NSHomeDirectory(), [imageUrl MD5Hash]];
    BOOL ret = [request.responseData writeToFile:path atomically:NO];
    if (!ret) {
        NSLog(@"缓存内页图片失败");
        return;
    }
    for (UIView *view in _scrollView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView *)view;
            if (imageView.tag == request.tag ) {
                [imageView setImage:[UIImage imageWithData:request.responseData]];
            }
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSLog(@"下载内页图片失败");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
