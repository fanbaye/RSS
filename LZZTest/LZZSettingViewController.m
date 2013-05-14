//
//  LZZSettingViewController.m
//  LZZTest
//
//  Created by lucas on 5/14/13.
//  Copyright (c) 2013 lucas. All rights reserved.
//

#import "LZZSettingViewController.h"

@interface LZZSettingViewController ()

@end

@implementation LZZSettingViewController

{
    UILabel *_cacheLabel;
    double _size;
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
    _size = 0;
	// Do any additional setup after loading the view.
    
    UIImageView *headView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    headView.userInteractionEnabled = YES;
    headView.image = [UIImage imageNamed:@"settinghead"];
    [self.view addSubview:headView];
    [headView release];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(12, 13, 18, 18);
    [backBtn setImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToList) forControlEvents:UIControlEventTouchUpInside];
    [headView addSubview:backBtn];
    
    UIButton *clearCacheBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    clearCacheBtn.frame = CGRectMake(14, 62, 292, 49);
    [clearCacheBtn addTarget:self action:@selector(clearCache) forControlEvents:UIControlEventTouchUpInside];
    [clearCacheBtn setImage:[UIImage imageNamed:@"cache"] forState:UIControlStateNormal];
    [self.view addSubview:clearCacheBtn];
    
    _cacheLabel = [[UILabel alloc] initWithFrame:CGRectMake(190, 15, 52, 17)];
    _cacheLabel.textAlignment = NSTextAlignmentRight;
    _cacheLabel.backgroundColor = [UIColor clearColor];
    [clearCacheBtn addSubview:_cacheLabel];
    [_cacheLabel release];
}

// 回列表页
- (void)backToList
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

// 计算缓存大小
- (void)getFilesSize
{
    _size = 0;
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *arr = [fm contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/tmp", NSHomeDirectory()] error:nil];
    for (NSString *str in arr) {
        NSString *path = [NSString stringWithFormat:@"%@/tmp/%@", NSHomeDirectory(), str];
        NSDictionary *dic = [fm attributesOfItemAtPath:path error:nil];
        _size += [[dic objectForKey:@"NSFileSize"] intValue];
    }
    
    _cacheLabel.text = [NSString stringWithFormat:@"%0.1f", _size/1024/1024];
}

// 清缓存
- (void)clearCache
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *arr = [fm contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/tmp", NSHomeDirectory()] error:nil];
    for (NSString *str in arr) {
        [fm removeItemAtPath:[NSString stringWithFormat:@"%@/tmp/%@", NSHomeDirectory(), str] error:nil];
    }
    [self getFilesSize];
}

// 出现的时候计算一下缓存
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getFilesSize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
