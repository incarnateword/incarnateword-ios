//
//  IWInfoViewController.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/06/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWInfoViewController.h"
#import "IWUtility.h"
#import "IWGUIManager.h"
#import "BPMarkdownView.h"
#import "IWUIConstants.h"
#import <WebKit/WebKit.h>


#define DURATION_ANIMATION  0.25
#define CORNER_RADIUS       10.0

@interface IWInfoViewController ()<UIGestureRecognizerDelegate>
{
    UITapGestureRecognizer                  *_gestureTapForWholeView;
    float                                   _fContainerHeight;
}

@property (weak, nonatomic) IBOutlet UIButton           *btnClose;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintViewContainerHeight;
@property (weak, nonatomic) IBOutlet UIView             *viewForMarkdown;
@property (weak, nonatomic) IBOutlet UILabel            *lblDate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintViewContainerBottom;
@property (weak, nonatomic) IBOutlet UIView             *viewContainer;
@property (weak, nonatomic) IBOutlet UIView             *viewAlpha;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLblDateBottomSpace;
@property (weak, nonatomic) IBOutlet UIWebView          *webView;
@property(strong,nonatomic) WKWebView                   *wkWebView;


@end

@implementation IWInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupHeight];
    [self addWKWebView];
    [self setupUI];
    [self setupTapGesture];
}

-(void)setupHeight
{
    _fContainerHeight = _constraintViewContainerHeight.constant;
}

-(void)addWKWebView
{
    _wkWebView = [WKWebView new];
    [_viewForMarkdown addSubview:_wkWebView];
    
    
    _wkWebView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *subview = _wkWebView;
    
    [_viewForMarkdown addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[subview]-10-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(subview)]];
    
    [_viewForMarkdown addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[subview]-80-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(subview)]];
    
    _wkWebView.scrollView.decelerationRate = SCROLL_DECELERATION_RATE;
}



-(void)setupUI
{
    //Set Date
    _lblDate.text   = _strDate;
    _lblDate.font   = [UIFont fontWithName:FONT_TITLE_REGULAR size:[UIFont systemFontSize] + 4.0];
    
    //Configure Container
    _viewForMarkdown.layer.cornerRadius = CORNER_RADIUS;
    [_viewForMarkdown layoutIfNeeded];
    _viewForMarkdown.backgroundColor = [UIColor whiteColor];
    
    //WKWebView
    _wkWebView.backgroundColor = [UIColor whiteColor];
    _wkWebView.alpha = 0.0;
    
    //Close Button
    _btnClose.layer.cornerRadius = CORNER_RADIUS;
    [_btnClose layoutIfNeeded];
    _btnClose.backgroundColor = [UIColor whiteColor];
    [_btnClose.titleLabel setFont:[UIFont fontWithName:FONT_TITLE_REGULAR size:[UIFont systemFontSize] + 4.0]];
    
    if([IWUtility isNilOrEmptyString:_strText] == NO)
    {
        [self addMarkdownView];
    }
    else
    {
        _constraintViewContainerHeight.constant = 120;
        _fContainerHeight = _constraintViewContainerHeight.constant;
        _constraintLblDateBottomSpace.constant = 10;
        
        
        [UIView animateWithDuration:DURATION_ANIMATION animations:
         ^{
             _constraintViewContainerBottom.constant = 0;
             [_viewContainer layoutIfNeeded];
             _viewAlpha.alpha = 0.5;
         }
                         completion:
         ^(BOOL finished)
         {
             _wkWebView.alpha = 1.0;
         }];

    }
}



-(void)addMarkdownView
{


   NSString *strHtmlString = [IWUtility getHtmlStringUsingJSLibForMarkdownText:_strText forTypeHeading:YES];
   NSLog(@"Called loadHTMLString");
   [_wkWebView loadHTMLString:strHtmlString baseURL:[IWUtility getCommonCssBaseURL]];
    
    _constraintViewContainerBottom.constant = -_fContainerHeight;
    
    [UIView animateWithDuration:DURATION_ANIMATION
                          delay:0
                        options: UIViewAnimationOptionCurveEaseOut//Out - Slow at end
                     animations:
                                ^{
                                    _constraintViewContainerBottom.constant = 0;
                                    [_viewContainer layoutIfNeeded];
                                    _viewAlpha.alpha = 0.5;
                                }
                                completion:^(BOOL finished)
                                {
                                    [UIView animateWithDuration:0.4 animations:
                                     ^{
                                         _wkWebView.alpha = 1.0;
                                     }];
                                 }
     ];
}


#pragma mark - Gesture handling

-(void)setupTapGesture
{
    _gestureTapForWholeView = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                      action:@selector(handleSingleTap:)];
    _gestureTapForWholeView.delegate = self;
    [self.view addGestureRecognizer:_gestureTapForWholeView];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (gestureRecognizer == _gestureTapForWholeView && [touch.view isDescendantOfView:_viewContainer])
        return NO;
    
    return YES;
}

#pragma mark - Remove View Methods

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    [self removeView];
}

- (IBAction)btnCloseClicked:(id)sender
{
    [self removeView];
}

-(void)removeView
{
    if(_delegateInfoView &&
       [_delegateInfoView respondsToSelector:@selector(infoViewRemoved)])
    {
        [_delegateInfoView infoViewRemoved];
    }
    
    [UIView animateWithDuration:DURATION_ANIMATION
                          delay:0
                        options: UIViewAnimationOptionCurveEaseOut//Out - Slow at end
                     animations:
                                 ^{
                                     _constraintViewContainerBottom.constant = -_fContainerHeight;
                                     _viewAlpha.alpha = 0.0;
                                     [_viewContainer layoutIfNeeded];
                                 }
                                completion:^(BOOL finished)
                                 {
                                     [self.view removeFromSuperview];
                                 }
     ];
}

@end
