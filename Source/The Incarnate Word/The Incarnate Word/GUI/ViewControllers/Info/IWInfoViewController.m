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

#define MARKDOWNVIEW_HEIGHT 250


@interface IWInfoViewController ()
{
    BPMarkdownView                          *_markdownView;
    UITapGestureRecognizer                  *_gestureTapForWholeView;
    UIView                                  *_viewLine;

}
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBtnCloseTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBtnCloseTop;
@end

@implementation IWInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _btnClose.hidden = YES;
    
    CGRect markdownRect = CGRectMake(0,
                                   self.view.frame.size.height - MARKDOWNVIEW_HEIGHT ,
                                   self.view.frame.size.width,
                                   MARKDOWNVIEW_HEIGHT);
    
    _markdownView = [IWUtility getMarkdownViewOfFrame:markdownRect];
    [_markdownView setMarkdown:_strText];
    [self.view addSubview:_markdownView];
    _markdownView.alpha = 0;
    
    _viewLine = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                         self.view.frame.size.height - MARKDOWNVIEW_HEIGHT ,
                                                         self.view.frame.size.width,
                                                         1)];
    _viewLine.backgroundColor = [UIColor colorWithRed:170.0/255 green:170.0/255 blue:170.0/255 alpha:1.0];
    [self.view addSubview:_viewLine];
    _viewLine.alpha = 0;
    
    BOOL bIsiOS8AndAbove = NO;
    
    if ([UIVisualEffect class])
    {
        bIsiOS8AndAbove = YES;
        
        UIImageView *containerView = [[UIImageView alloc] initWithFrame:markdownRect];
        
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        
        visualEffectView.frame = containerView.bounds;
        [containerView addSubview:visualEffectView];
        [self.view addSubview:containerView];
        containerView.backgroundColor = [UIColor lightGrayColor];
        containerView.alpha = 0.95;
        _markdownView.backgroundColor = [UIColor clearColor];
        
        [self.view bringSubviewToFront:_markdownView];
    }
    else
    {
        // Alternate code path to follow when the
        // class is not available.
        _markdownView.backgroundColor = [UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0];
    }
    

    [UIView animateWithDuration:0.2 animations:
     ^{
         _markdownView.alpha = bIsiOS8AndAbove ? 1.0: 0.9;
         _viewLine.alpha = 1.0;
    }];

    [self.view bringSubviewToFront:_btnClose];
//    _btnClose.layer.cornerRadius = 7.0;
//    _constraintBtnCloseTop.constant = MARKDOWNVIEW_MARGIN_V - 15;
//    _constraintBtnCloseTrailing.constant = MARKDOWNVIEW_MARGIN_H - 15;
    
    
    _gestureTapForWholeView = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                      action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:_gestureTapForWholeView];
}


- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    if(_delegateInfoView && [_delegateInfoView respondsToSelector:@selector(infoViewRemoved)])
    {
        [_delegateInfoView infoViewRemoved];
    }
    
    [self.view removeFromSuperview];

}



- (IBAction)btnClosePressed:(id)sender {
    
    [self.view removeFromSuperview];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
