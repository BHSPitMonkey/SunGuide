#import "PageScrollView.h"

#define	MAX_PAGES	7

@implementation PageScrollView

-(id)initWithFrame:(CGRect)frame {
	self = [ super initWithFrame: frame ];
	if (self != nil) {
		_pages = nil;
		_zeroPage = 0;
		_pageRegion = CGRectMake(frame.origin.x, frame.origin.y, 320, 460);
		_controlRegion = CGRectMake(frame.origin.x, frame.size.height - 30.0, frame.size.width, 30.0);
		self.delegate = nil;
		
		scrollView = [ [ UIScrollView alloc ] initWithFrame: _pageRegion ];
		scrollView.pagingEnabled = YES;
		scrollView.delegate = self;
		scrollView.backgroundColor = [UIColor blackColor];
		[ self addSubview: scrollView ];
		
		pageControl = [ [ UIPageControl alloc ] initWithFrame: _controlRegion ];
		[ pageControl addTarget: self action: @selector(pageControlDidChange:) forControlEvents: UIControlEventValueChanged ];
		[ self addSubview: pageControl ];
	}
	return self;
}

-(void)setPages:(NSMutableArray *)pages {
	if (pages != nil) {
	    for(int i=0;i<[_pages count];i++) {
	    	[ [ _pages objectAtIndex: i ] removeFromSuperview ];
	    }
	}
	_pages = pages;
	scrollView.contentOffset = CGPointMake(0.0, 0.0);
	if ([ _pages count] < 3) {
	    scrollView.contentSize = CGSizeMake(_pageRegion.size.width * [ _pages count ], _pageRegion.size.height);
	} else {
		scrollView.contentSize = CGSizeMake(_pageRegion.size.width * 3, _pageRegion.size.height);
		scrollView.showsHorizontalScrollIndicator = NO;
	}
	pageControl.numberOfPages = [ _pages count ];
	pageControl.currentPage = 0;
	[ self layoutViews ];
}

- (void)layoutViews {
	if ([ _pages count ] <= 3) {
		for(int i=0;i<[ _pages count];i++) {
			UIView *page = [ _pages objectAtIndex: i ];
			CGRect bounds = page.bounds;
			CGRect frame = CGRectMake(_pageRegion.size.width * i, 0.0, _pageRegion.size.width, _pageRegion.size.height);
			page.frame = frame;
			page.bounds = bounds;
			[ scrollView addSubview: page ];
		}
		return;
	}
	
    /* For more than 3 views, add them all hidden, layout according to page */
	for(int i=0;i<[ _pages count];i++) {
		UIView *page = [ _pages objectAtIndex: i ];
		CGRect bounds = page.bounds;
		CGRect frame = CGRectMake(0.0, 0.0, _pageRegion.size.width, _pageRegion.size.height);
		page.frame = frame;
		page.bounds = bounds;
		page.hidden = YES;
		[ scrollView addSubview: page ];
	}
	[ self layoutScroller ];
}

- (void)layoutScroller {
	UIView *page;
	CGRect bounds, frame;
	int pageNum = [ self getCurrentPage ];
	
	if ([ _pages count ] <= 3)
		return;

	// NSLog(@"Laying out scroller for page %d\n", pageNum);

	/* Left boundary */
	if (pageNum == 0) {
		for(int i=0;i<3;i++) {
			page = [ _pages objectAtIndex: i ];
			bounds = page.bounds;
			frame = CGRectMake(_pageRegion.size.width * i, 0.0, _pageRegion.size.width, _pageRegion.size.height);
			// NSLog(@"\tOffset for Page %d = %f\n", i, frame.origin.x);
			page.frame = frame;
			page.bounds = bounds;
			page.hidden = NO;
		}
		page = [ _pages objectAtIndex: 3 ];
		page.hidden = YES;
		_zeroPage = 0;
	}
	
	/* Right boundary */
	else if (pageNum == [ _pages count ] -1) {
		for(int i=pageNum-2;i<=pageNum;i++) {
			page = [ _pages objectAtIndex: i ];
			bounds = page.bounds;
			frame = CGRectMake(_pageRegion.size.width * (2-(pageNum-i)), 0.0, _pageRegion.size.width, _pageRegion.size.height);
			// NSLog(@"\tOffset for Page %d = %f\n", i, frame.origin.x);
			page.frame = frame;
			page.bounds = bounds;
			page.hidden = NO;
		}
		page = [ _pages objectAtIndex: [ _pages count ]-3 ];
		page.hidden = YES;
		_zeroPage = pageNum - 2;
	}
	
	/* All middle pages */
	else {
		for(int i=pageNum-1; i<=pageNum+1; i++) {
			page = [ _pages objectAtIndex: i ];
			bounds = page.bounds;
			frame = CGRectMake(_pageRegion.size.width * (i-(pageNum-1)), 0.0, _pageRegion.size.width, _pageRegion.size.height);
			// NSLog(@"\tOffset for Page %d = %f\n", i, frame.origin.x);
			page.frame = frame;
			page.bounds = bounds;
			page.hidden = NO;
		}
		for(int i=0; i< [ _pages count ]; i++) {
			if (i < pageNum-1 || i > pageNum + 1) {
				page = [ _pages objectAtIndex: i ];
				page.hidden = YES;
			}
		}
		scrollView.contentOffset = CGPointMake(_pageRegion.size.width, 0.0);
		_zeroPage = pageNum-1;
	}
}

-(id)getDelegate {
	return _delegate;
}

- (void)setDelegate:(id)delegate {
	_delegate = delegate;
}

-(BOOL)getShowsPageControl {
	return _showsPageControl;
}

-(void)setShowsPageControl:(BOOL)showsPageControl {
	_showsPageControl = showsPageControl;
	if (_showsPageControl == NO) {
		_pageRegion = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
		pageControl.hidden = YES;
		scrollView.frame = _pageRegion;
	} else {
		_pageRegion = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height - 60.0);
		pageControl.hidden = NO;
		scrollView.frame = _pageRegion;
	}
}

-(NSMutableArray *)getPages {
	return _pages;
}

-(void)setCurrentPage:(int)page {
	[ scrollView setContentOffset: CGPointMake(0.0, 0.0) ];
	if ( (page >= 0) && (page < MAX_PAGES)) {
		_zeroPage = page;
		[ self layoutScroller ];
		pageControl.currentPage = page;
	}
}

-(int)getCurrentPage {
	return (int) (scrollView.contentOffset.x / _pageRegion.size.width) + _zeroPage;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControl.currentPage = self.currentPage;
	[ self layoutScroller ];
	[ self notifyPageChange ];
}

-(void) pageControlDidChange: (id)sender 
{
    UIPageControl *control = (UIPageControl *) sender;
    if (control == pageControl) {
		[ scrollView setContentOffset: CGPointMake(_pageRegion.size.width * (control.currentPage - _zeroPage), 0.0) animated: YES ];
	}
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	    [ self layoutScroller ];
	    [ self notifyPageChange ];
}

-(void) notifyPageChange {
	if (self.delegate != nil) {
	    if ([ _delegate conformsToProtocol:@protocol(PageScrollViewDelegate) ]) {
			if ([ _delegate respondsToSelector:@selector(pageScrollViewDidChangeCurrentPage:currentPage:) ]) {
    		    [ self.delegate pageScrollViewDidChangeCurrentPage: (PageScrollView *)self currentPage: self.currentPage ];
			}
		}
	}
}

@end
