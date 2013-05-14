

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
	LZZOPullRefreshPulling = 0,
	LZZOPullRefreshNormal,
	LZZOPullRefreshLoading,
} LZZPullRefreshState;

@protocol LZZRefreshTableFooterDelegate;
@interface LZZRefreshTableFooterView : UIView {
	
	id _delegate;
	LZZPullRefreshState _state;

	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
	

}

@property(nonatomic,assign) id <LZZRefreshTableFooterDelegate> delegate;

- (void)refreshLastUpdatedDate;
- (void)lzzRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)lzzRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)lzzRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;

@end
@protocol LZZRefreshTableFooterDelegate
- (void)lzzRefreshTableFooterDidTriggerRefresh:(LZZRefreshTableFooterView*)view;
- (BOOL)lzzRefreshTableFooterDataSourceIsLoading:(LZZRefreshTableFooterView*)view;
@optional
- (NSDate*)lzzRefreshTableFooterDataSourceLastUpdated:(LZZRefreshTableFooterView*)view;
@end
