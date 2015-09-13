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

#define MARKDOWNVIEW_HEIGHT 350
#define MARKDOWNVIEW_SIDE_MARGIN 5
#define MARKDOWNVIEW_BOTTOM_MARGIN 45


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

@end

@implementation IWInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupData];
    [self setupUI];
    [self setupTapGesture];
}

-(void)setupData
{
    _fContainerHeight = _constraintViewContainerHeight.constant;
}

-(void)setupUI
{
    _lblDate.text = _strDate;
    _lblDate.font = [UIFont fontWithName:FONT_TITLE_REGULAR size:[UIFont systemFontSize] + 4.0];
    _viewForMarkdown.layer.cornerRadius = 3.0;
    [_viewForMarkdown layoutIfNeeded];
    _viewForMarkdown.backgroundColor = [UIColor whiteColor];
    _webView.backgroundColor = [UIColor whiteColor];

    [self setupCloseBtn];
    
    if([IWUtility isNilOrEmptyString:_strText] == NO)
    {
        [self addMarkdownView];
    }
    else
    {
        _constraintViewContainerHeight.constant = 120;
        _fContainerHeight = _constraintViewContainerHeight.constant;
        _constraintLblDateBottomSpace.constant = 20;
        
        
        [UIView animateWithDuration:0.4 animations:
         ^{
             _constraintViewContainerBottom.constant = 0;
             [_viewContainer layoutIfNeeded];
             _viewAlpha.alpha = 0.5;
         }
                         completion:
         ^(BOOL finished)
         {
         }];

    }
}

-(void)setupCloseBtn
{
    _btnClose.layer.cornerRadius = 3.0;
    [_btnClose layoutIfNeeded];

    _btnClose.backgroundColor = COLOR_NAV_BAR;
    [_btnClose.titleLabel setFont:[UIFont fontWithName:FONT_TITLE_REGULAR size:[UIFont systemFontSize] + 4.0]];
}

-(void)addMarkdownView
{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
                   ^{
                       NSString *strHtmlString = [IWUtility getHtmlStringUsingJSLibForMarkdownText:_strText];
                       NSLog(@"Called loadHTMLString");
                       //       NSString *cssPath = [[NSBundle mainBundle] pathForResource:@"chapter" ofType:@"css"];
                       
                       [_webView loadHTMLString:strHtmlString baseURL:[IWUtility getCommonCssBaseURL]];
                   });
    
    _constraintViewContainerBottom.constant = -_fContainerHeight;
    
    
    [UIView animateWithDuration:0.4 animations:
     ^{
         _constraintViewContainerBottom.constant = 0;
         [_viewContainer layoutIfNeeded];
         _viewAlpha.alpha = 0.5;
     }
    completion:
     ^(BOOL finished)
    {
    }];
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

    [UIView animateWithDuration:0.4 animations:
     ^{
         _constraintViewContainerBottom.constant = -_fContainerHeight;
         _viewAlpha.alpha = 0.0;
         [_viewContainer layoutIfNeeded];
     }
    completion:^(BOOL finished)
     {
         [self.view removeFromSuperview];
     }];
}

@end
