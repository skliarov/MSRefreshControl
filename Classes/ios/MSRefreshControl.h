#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
	MSRefreshPulling,
	MSRefreshNormal,
	MSRefreshLoading,	
} MSRefreshState;

@class MSRefreshControl;

@protocol MSRefreshControlDelegate
- (void)tableHeaderDidTriggerRefresh:(MSRefreshControl*)view;
- (BOOL)tableDataSourceIsLoading:(MSRefreshControl*)view;
@end

@interface MSRefreshControl : UIView

@property(nonatomic, weak) NSObject <MSRefreshControlDelegate> *delegate;

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)dataSourceDidFinishLoading:(UIScrollView *)scrollView;

@end