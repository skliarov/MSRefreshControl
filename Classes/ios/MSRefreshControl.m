#import "MSRefreshControl.h"

#define FLIP_ANIMATION_DURATION 0.18f
#define REFRESH_CONTROL_HEIGHT 40.0f

@interface MSRefreshControl()
- (void)setState:(MSRefreshState)aState;

@property (nonatomic) MSRefreshState state;
@property (nonatomic, strong) UILabel *lastUpdatedLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) CALayer *arrowImage;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@end

@implementation MSRefreshControl

@synthesize state = _state;
@synthesize lastUpdatedLabel = _lastUpdatedLabel;
@synthesize statusLabel = _statusLabel;
@synthesize arrowImage = _arrowImage;
@synthesize activityView = _activityView;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.backgroundColor = [UIColor clearColor];

		_statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height - REFRESH_CONTROL_HEIGHT, self.frame.size.width, REFRESH_CONTROL_HEIGHT)];
		_statusLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_statusLabel.font = [UIFont boldSystemFontOfSize:13.0f];
		_statusLabel.textColor = [UIColor whiteColor];
		_statusLabel.backgroundColor = [UIColor blackColor];
		_statusLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_statusLabel];
		
		CALayer *layer = [CALayer layer];
		layer.frame = CGRectMake(20.0f, frame.size.height - 28.0f, 15.0f, 15.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
		layer.contents = (id)[UIImage imageNamed:@"Arrow.png"].CGImage;
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		
		[[self layer] addSublayer:layer];
		_arrowImage = layer;
		
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		view.frame = CGRectMake(20.0f, frame.size.height - 30.0f, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;
		
		
		[self setState:MSRefreshNormal];
		
    }
	
    return self;
	
}


#pragma mark -
#pragma mark Setters

- (void)setState:(MSRefreshState)aState{
	
	switch (aState) {
		case MSRefreshPulling:
			
			_statusLabel.text = @"Release to refresh...";
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			
			break;
		case MSRefreshNormal:
			
			if (_state == MSRefreshPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
			
			_statusLabel.text = @"Pull down to refresh...";
			[_activityView stopAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			
			break;
		case MSRefreshLoading:
			
			_statusLabel.text = @"Updating...";
			[_activityView startAnimating];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = YES;
			[CATransaction commit];
			
			break;
		default:
			break;
	}
	
	_state = aState;
}


#pragma mark -
#pragma mark ScrollView Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {	
	
	if (_state == MSRefreshLoading) {
		
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
		offset = MIN(offset, REFRESH_CONTROL_HEIGHT);
		scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
		
	} else if (scrollView.isDragging) {
		
		BOOL _loading = NO;
		if ([self.delegate respondsToSelector:@selector(tableDataSourceIsLoading:)]) {
			_loading = [self.delegate tableDataSourceIsLoading:self];
		}
		
		if (_state == MSRefreshPulling && scrollView.contentOffset.y > -REFRESH_CONTROL_HEIGHT && scrollView.contentOffset.y < 0.0f && !_loading) {
			[self setState:MSRefreshNormal];
		} else if (_state == MSRefreshNormal && scrollView.contentOffset.y < -REFRESH_CONTROL_HEIGHT && !_loading) {
			[self setState:MSRefreshPulling];
		}
		
		if (scrollView.contentInset.top != 0) {
			scrollView.contentInset = UIEdgeInsetsZero;
		}
		
	}
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView {
	
	BOOL _loading = NO;
	if ([self.delegate respondsToSelector:@selector(tableDataSourceIsLoading:)]) {
		_loading = [self.delegate tableDataSourceIsLoading:self];
	}
	
	if (scrollView.contentOffset.y <= -REFRESH_CONTROL_HEIGHT && !_loading) {
		
		if ([self.delegate respondsToSelector:@selector(tableHeaderDidTriggerRefresh:)]) {
			[self.delegate tableHeaderDidTriggerRefresh:self];
		}
		
		[self setState:MSRefreshLoading];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.2];
		scrollView.contentInset = UIEdgeInsetsMake(REFRESH_CONTROL_HEIGHT, 0.0f, 0.0f, 0.0f);
		[UIView commitAnimations];
		
	}
	
}

- (void)dataSourceDidFinishLoading:(UIScrollView *)scrollView {	
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	[scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
	[UIView commitAnimations];
	
	[self setState:MSRefreshNormal];

}




@end