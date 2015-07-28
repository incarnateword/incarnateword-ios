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
    BPMarkdownView                          *_markdownView;
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
    [self setupCloseBtn];
    [self addMarkdownView];
}

-(void)setupCloseBtn
{
    _btnClose.layer.cornerRadius = 3.0;
    _btnClose.backgroundColor = COLOR_NAV_BAR;
}

-(void)addMarkdownView
{
    CGRect markdownRect = CGRectMake(MARKDOWNVIEW_SIDE_MARGIN,
                                     MARKDOWNVIEW_SIDE_MARGIN,
                                     [UIScreen mainScreen].bounds.size.width - MARKDOWNVIEW_SIDE_MARGIN - 15,
                                     _fContainerHeight - 80/*([IWUtility isNilOrEmptyString:_strDate] ? 50 : 85)*/);
    
    BPDisplaySettings *customBPSettings = [[BPDisplaySettings alloc] init];
    CGFloat systemFontSize = [UIFont systemFontSize];
    customBPSettings.defaultFont = [UIFont fontWithName:FONT_TITLE_REGULAR size:systemFontSize + 4.0];
    customBPSettings.boldFont = [UIFont fontWithName:FONT_TITLE_MEDIUM size:systemFontSize + 4.0];
    customBPSettings.italicFont =  [UIFont fontWithName:FONT_TITLE_ITALIC size:systemFontSize + 4.0];
    customBPSettings.monospaceFont = [UIFont fontWithName:FONT_TITLE_REGULAR size:systemFontSize - 2.f];
    customBPSettings.quoteFont = [UIFont fontWithName:FONT_TITLE_ITALIC size:systemFontSize + 4.0];

    
    
    _markdownView = [IWUtility getMarkdownViewOfFrame:markdownRect withCustomBPDisplaySettings:customBPSettings];
    _markdownView.translatesAutoresizingMaskIntoConstraints = NO;
    _viewForMarkdown.layer.cornerRadius = 3.0;
    [_markdownView setMarkdown:_strText];
    _markdownView.backgroundColor = [UIColor clearColor];
    _viewForMarkdown.backgroundColor = COLOR_NAV_BAR;
    [_viewForMarkdown addSubview:_markdownView];
    
    _constraintViewContainerBottom.constant = -_fContainerHeight;
    
    [_btnClose.titleLabel setFont:[UIFont fontWithName:FONT_TITLE_REGULAR size:[UIFont systemFontSize] + 4.0]];
    
    [UIView animateWithDuration:0.4 animations:
     ^{
         _constraintViewContainerBottom.constant = 0;
         [_viewContainer layoutIfNeeded];
         _markdownView.frame = markdownRect;
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
