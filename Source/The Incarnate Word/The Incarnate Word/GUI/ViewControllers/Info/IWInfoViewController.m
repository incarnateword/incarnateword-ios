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


@interface IWInfoViewController ()
{
    BPMarkdownView                          *_markdownView;
    UITapGestureRecognizer                  *_gestureTapForWholeView;
}

@property (weak, nonatomic) IBOutlet UIButton *btnClose;

@end

@implementation IWInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    [self setupTapGesture];
}

-(void)setupUI
{
    [self setupCloseBtn];
    [self addMarkdownView];
}

-(void)setupCloseBtn
{
    _btnClose.alpha = 0;
    _btnClose.layer.cornerRadius = 3.0;
    _btnClose.backgroundColor = COLOR_NAV_BAR;
}

-(void)addMarkdownView
{
    CGRect markdownRect = CGRectMake(MARKDOWNVIEW_SIDE_MARGIN,
                                     self.view.frame.size.height,
                                     self.view.frame.size.width - 2* MARKDOWNVIEW_SIDE_MARGIN,
                                     MARKDOWNVIEW_HEIGHT);
    
    _markdownView = [IWUtility getMarkdownViewOfFrame:markdownRect];
    _markdownView.layer.cornerRadius = 3.0;
    [_markdownView setMarkdown:_strText];
    _markdownView.alpha = 0;
    _markdownView.backgroundColor = COLOR_NAV_BAR;

    [self.view addSubview:_markdownView];
    
    [UIView animateWithDuration:0.25 animations:
     ^{
         _markdownView.alpha =1.0;
         _btnClose.alpha = 0.2;

         _markdownView.frame = CGRectMake(MARKDOWNVIEW_SIDE_MARGIN,
                                          self.view.frame.size.height - MARKDOWNVIEW_HEIGHT,
                                          self.view.frame.size.width - 2* MARKDOWNVIEW_SIDE_MARGIN,
                                          MARKDOWNVIEW_HEIGHT - MARKDOWNVIEW_BOTTOM_MARGIN);
     }  completion:
     ^(BOOL finished)
    {
        _btnClose.alpha = 1.0;
    }];
}

-(void)setupTapGesture
{
    _gestureTapForWholeView = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                      action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:_gestureTapForWholeView];
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
    _btnClose.alpha = 0;

    [UIView animateWithDuration:0.25 animations:
     ^{
         _markdownView.frame = CGRectMake(MARKDOWNVIEW_SIDE_MARGIN,
                                          self.view.frame.size.height,
                                          self.view.frame.size.width - 2* MARKDOWNVIEW_SIDE_MARGIN,
                                          MARKDOWNVIEW_HEIGHT);
     }
                     completion:^(BOOL finished)
     {
         [self.view removeFromSuperview];
         
     }];
}

@end
