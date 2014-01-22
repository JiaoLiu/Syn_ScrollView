//
//  SVScrollViewController.h
//  Syn_ScrollView
//
//  Created by Jiao Liu on 1/22/14.
//  Copyright (c) 2014 Jiao Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SVScrollViewController : UIViewController<UIGestureRecognizerDelegate>
{
    UIPageControl *_pageControl;
    UIScrollView *_scrollView;
    UIScrollView *_subScrollView;
    
    NSTimer *_timer;
}

@end
