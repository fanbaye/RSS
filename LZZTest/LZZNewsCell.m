//
//  LZZNewsCell.m
//  LZZTest
//
//  Created by lucas on 5/13/13.
//  Copyright (c) 2013 lucas. All rights reserved.
//

#import "LZZNewsCell.h"

@implementation LZZNewsCell

@synthesize newsImageView = _newsImageView;
@synthesize newsSubTitleLabel = _newsSubTitleLabel;
@synthesize newsTimeLabel = _newsTimeLabel;
@synthesize newsTitleLabel = _newsTitleLabel;

- (void)dealloc
{
    self.newsTitleLabel = nil;
    self.newsSubTitleLabel = nil;
    self.newsImageView = nil;
    self.newsTitleLabel = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        UIImageView *topLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 2)];
        [topLine setImage:[UIImage imageNamed:@"topline"]];
        [self.contentView addSubview:topLine];
        [topLine release];
        
        UIImageView *buttomLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 69, 320, 2)];
        [buttomLine setImage:[UIImage imageNamed:@"buttomLine"]];
        [self.contentView addSubview:buttomLine];
        [buttomLine release];
        
        self.newsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(9, 12, 70, 52)];
        self.newsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(89, 12, 211, 16)];
        self.newsSubTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(89, 32.5, 211, 28)];
        self.newsTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(230, 53, 78, 11)];
        
        _newsTitleLabel.backgroundColor = [UIColor clearColor];
        _newsSubTitleLabel.backgroundColor = [UIColor clearColor];
        _newsTimeLabel.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:_newsImageView];
        [self.contentView addSubview:_newsTitleLabel];
        [self.contentView addSubview:_newsSubTitleLabel];
        [self.contentView addSubview:_newsTimeLabel];
        
        [_newsImageView release];
        [_newsTimeLabel release];
        [_newsSubTitleLabel release];
        [_newsTimeLabel release];
        
//        _newsImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        _newsTitleLabel.font = [UIFont systemFontOfSize:15];
        
        _newsSubTitleLabel.font = [UIFont systemFontOfSize:11];
        _newsSubTitleLabel.textColor = [UIColor grayColor];
        _newsSubTitleLabel.numberOfLines = 0;
        _newsSubTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        _newsTimeLabel.font = [UIFont systemFontOfSize:11];
        _newsTimeLabel.textColor = [UIColor lightGrayColor];
        _newsTimeLabel.textAlignment = NSTextAlignmentRight;
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
//    self.contentView.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:233.0/255.0 alpha:1];
    // Configure the view for the selected state
}

@end
