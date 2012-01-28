#import <UIKit/UIKit.h>

@interface PageScrollView : UIView <UIScrollViewDelegate> {
	UIScrollView *scrollView;
	UIPageControl *pageControl;
	
	CGRect _pageRegion, _controlRegion;
	NSMutableArray *_pages;
	id _delegate;
	BOOL _showsPageControl;
	int _zeroPage;
}
-(void)layoutViews;
-(void)layoutScroller;
-(void)notifyPageChange;

@property(nonatomic,assign,getter=getPages) NSMutableArray *pages;		 /* UIView Subclases */
@property(nonatomic,assign,getter=getCurrentPage)      int  currentPage; 
@property(nonatomic,assign,getter=getDelegate)         id   delegate;     /* PageScrollViewDelegate */
@property(nonatomic,assign,getter=getShowsPageControl) BOOL showsPageControl;
@end

@protocol PageScrollViewDelegate<NSObject>

@optional

-(void) pageScrollViewDidChangeCurrentPage:(PageScrollView *)pageScrollView currentPage:(int)currentPage;

@end