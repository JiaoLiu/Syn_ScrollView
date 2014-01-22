//
//  SVScrollViewController.m
//  Syn_ScrollView
//
//  Created by Jiao Liu on 1/22/14.
//  Copyright (c) 2014 Jiao Liu. All rights reserved.
//

#import "SVScrollViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define isIphone4  [UIScreen mainScreen].bounds.size.height < 500

@interface SVScrollViewController ()

@end

@implementation SVScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [UIApplication sharedApplication].statusBarHidden = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // add Gesture Control
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] init];
    panGes.maximumNumberOfTouches = 1;
    [panGes addTarget:self action:@selector(moveViewWithGesture:)];
    [self.view addGestureRecognizer:panGes];
    
    // add scrollView & pagecontrol
    _scrollView =[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 5, SCREEN_HEIGHT);
    _scrollView.tag = 0;
    _scrollView.scrollEnabled = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
    float yOffset, height, width;
    if (isIphone4) {
        yOffset = 303 / 2.0;
        width = 268 / 2.0;
        height = 472 / 2.0;
    }
    else
    {
        yOffset = 365 / 2.0;
        width = 306 / 2.0;
        height = 540 / 2.0;
    }
    
    _subScrollView =[[UIScrollView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2.0 - width / 2.0 + 1, yOffset, width, height)];
    _subScrollView.contentSize = CGSizeMake(width * 5, height);
    _subScrollView.scrollEnabled = NO;
    _subScrollView.tag = 1;
    _subScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_subScrollView];
    
    for (int i = 0; i < 5; i++) {
        UIImageView *imageView =[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * i, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        imageView.backgroundColor = [UIColor colorWithRed:i / 5.0 green:(5 - i) / 5.0 blue:0.4 alpha:1];
        [_scrollView addSubview:imageView];
    }
    
    for (int i = 0; i < 5; i++) {
        UIImageView *imageView =[[UIImageView alloc] initWithFrame:CGRectMake(width * i, 0, width, height)];
        imageView.backgroundColor = [UIColor colorWithRed:0.2 green:i / 5.0 blue:(5 - i) / 5.0 alpha:1];
        [_subScrollView addSubview:imageView];
    }
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 50, SCREEN_HEIGHT - 50, 100, 30)];
    _pageControl.numberOfPages = 5;
    _pageControl.userInteractionEnabled = YES;
    [_pageControl addTarget:self action:@selector(pageScroll) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_pageControl];
    
    // start autoScroll timer
    _timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(autoScroll) userInfo:Nil repeats:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - panGes delegate

- (void)moveViewWithGesture:(UIPanGestureRecognizer *)panGes
{
    // stop autoScroll
    [_timer invalidate];
    
    if (panGes.state == UIGestureRecognizerStateChanged) { // inScrolling update View
        CGPoint location = [panGes translationInView: self.view];
        long page = _pageControl.currentPage;
        if (location.x < 0 && _scrollView.contentOffset.x < SCREEN_WIDTH * 4 ) {
            [UIView animateWithDuration:0 animations:^{
                _scrollView.contentOffset = CGPointMake(-location.x + SCREEN_WIDTH * page, 0);
                _subScrollView.contentOffset = CGPointMake(- location.x * _subScrollView.frame.size.width / SCREEN_WIDTH  + _subScrollView.frame.size.width * page, 0);
            }];
        }
        else if (location.x > 0 &&_scrollView.contentOffset.x > 0)
        {
            [UIView animateWithDuration:0 animations:^{
                _scrollView.contentOffset = CGPointMake(-location.x + SCREEN_WIDTH * page, 0);
                _subScrollView.contentOffset = CGPointMake(- location.x * _subScrollView.frame.size.width / SCREEN_WIDTH + _subScrollView.frame.size.width * page, 0);
            }];
        }
    }
    if (panGes.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity;
        velocity = [panGes velocityInView:self.view];
        CGPoint offset;
        offset = [panGes translationInView:self.view];
        
        if (ABS(velocity.x) >= 1000) { // if swip very fast, show next page
            if (offset.x < 0) {
                _pageControl.currentPage += 1;
                long page = _pageControl.currentPage;
                [UIView animateWithDuration:0.3 animations:^{
                    _scrollView.contentOffset = CGPointMake(SCREEN_WIDTH * page, 0);
                    _subScrollView.contentOffset = CGPointMake(_subScrollView.frame.size.width * page, 0);
                }];
                return;
            }
            else
            {
                _pageControl.currentPage -= 1;
                long page = _pageControl.currentPage;
                [UIView animateWithDuration:0.3 animations:^{
                    _scrollView.contentOffset = CGPointMake(SCREEN_WIDTH * page, 0);
                    _subScrollView.contentOffset = CGPointMake(_subScrollView.frame.size.width * page, 0);
                }];
                return;
            }
        }
        
        if (offset.x < 0) {
            if (offset.x < - SCREEN_WIDTH / 2) { //swip right
                _pageControl.currentPage += 1;
                long page = _pageControl.currentPage;
                [UIView animateWithDuration:0.3 animations:^{
                    _scrollView.contentOffset = CGPointMake(SCREEN_WIDTH * page, 0);
                    _subScrollView.contentOffset = CGPointMake(_subScrollView.frame.size.width * page, 0);
                }];
            }
            else {
                long page = _pageControl.currentPage;
                [UIView animateWithDuration:0.3 animations:^{
                    _scrollView.contentOffset = CGPointMake(SCREEN_WIDTH * page, 0);
                    _subScrollView.contentOffset = CGPointMake(_subScrollView.frame.size.width * page, 0);
                }];
            }
        }
        else if (offset.x > 0)
        {
            if (offset.x > SCREEN_WIDTH / 2) { //swip left
                _pageControl.currentPage -= 1;
                long page = _pageControl.currentPage;
                [UIView animateWithDuration:0.3 animations:^{
                    _scrollView.contentOffset = CGPointMake(SCREEN_WIDTH * page, 0);
                    _subScrollView.contentOffset = CGPointMake(_subScrollView.frame.size.width * page, 0);
                }];
            }
            else {
                long page = _pageControl.currentPage;
                [UIView animateWithDuration:0.3 animations:^{
                    _scrollView.contentOffset = CGPointMake(SCREEN_WIDTH * page, 0);
                    _subScrollView.contentOffset = CGPointMake(_subScrollView.frame.size.width * page, 0);
                }];
            }
        }
    }
}

# pragma mark - pageControl

- (void)pageScroll
{
    long page = _pageControl.currentPage;
    [UIView animateWithDuration:0.5 animations:^{
        _scrollView.contentOffset = CGPointMake(SCREEN_WIDTH * page, 0);
        _subScrollView.contentOffset = CGPointMake(_subScrollView.frame.size.width * page, 0);
    }];
}

- (void)autoScroll
{
    _pageControl.currentPage += 1;
    [self pageScroll];
}

@end
