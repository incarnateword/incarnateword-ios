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
#define MARKDOWNVIEW_MARGIN 5

@interface IWInfoViewController ()
{
    BPMarkdownView                          *_markdownView;
    UITapGestureRecognizer                  *_gestureTapForWholeView;
//    UIView                                  *_viewLine;

}
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBtnCloseTrailing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintBtnCloseTop;
@end

@implementation IWInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *bgView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha  = 0.5;
    
    [self.view addSubview:bgView];
    
    _btnClose.hidden = YES;
    
    
    
    CGRect markdownRect = CGRectMake(MARKDOWNVIEW_MARGIN,
                                   self.view.frame.size.height,
                                   self.view.frame.size.width - 2* MARKDOWNVIEW_MARGIN,
                                   MARKDOWNVIEW_HEIGHT);
    
    _markdownView = [IWUtility getMarkdownViewOfFrame:markdownRect];
    _markdownView.layer.cornerRadius = 3.0;
    [_markdownView setMarkdown:_strText];
    [self.view addSubview:_markdownView];
    _markdownView.alpha = 0;
    
//    _viewLine = [[UIView alloc] initWithFrame:CGRectMake(MARKDOWNVIEW_MARGIN +2,
//                                                         self.view.frame.size.height - MARKDOWNVIEW_HEIGHT ,
//                                                         self.view.frame.size.width - 2*MARKDOWNVIEW_MARGIN - 4,
//                                                         0.5)];
//    _viewLine.backgroundColor = [UIColor colorWithRed:190.0/255 green:190.0/255 blue:190.0/255 alpha:1.0];
//    [self.view addSubview:_viewLine];
//    _viewLine.alpha = 0;
    
    BOOL bIsiOS8AndAbove = NO;
    
    /*
    if ([UIVisualEffect class])
    {
        bIsiOS8AndAbove = YES;
        
        UIImageView *containerView = [[UIImageView alloc] initWithFrame:markdownRect];
        
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        
        visualEffectView.frame = containerView.bounds;
        [containerView addSubview:visualEffectView];
        [self.view addSubview:containerView];
        containerView.backgroundColor = [UIColor colorWithRed:119.0/255 green:119.0/255 blue:119.0/255 alpha:1.0];//[UIColor lightGrayColor];
        containerView.alpha = 0.95;
        _markdownView.backgroundColor = [UIColor clearColor];
        
        [self.view bringSubviewToFront:_markdownView];
    }
    else
     
     */
    {
        // Alternate code path to follow when the
        // class is not available.
        _markdownView.backgroundColor = COLOR_NAV_BAR;//[UIColor colorWithRed:200.0/255 green:200.0/255 blue:200.0/255 alpha:1.0];//[UIColor colorWithRed:119.0/255 green:119.0/255 blue:119.0/255 alpha:1.0];
    }
    

    [UIView animateWithDuration:0.2 animations:
     ^{
         _markdownView.alpha =1.0; //bIsiOS8AndAbove ? 1.0: 0.9;
         
         _markdownView.frame = CGRectMake(MARKDOWNVIEW_MARGIN,
                                                              self.view.frame.size.height - MARKDOWNVIEW_HEIGHT,
                                                              self.view.frame.size.width - 2* MARKDOWNVIEW_MARGIN,
                                                              MARKDOWNVIEW_HEIGHT - MARKDOWNVIEW_MARGIN);
     } completion:^(BOOL finished){
//         _viewLine.alpha = 1.0;

     
     } ];

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
    
//    _viewLine.alpha = 0;
    
    [UIView animateWithDuration:0.2 animations:
     ^{
         _markdownView.frame = CGRectMake(MARKDOWNVIEW_MARGIN,
                                          self.view.frame.size.height,
                                          self.view.frame.size.width - 2* MARKDOWNVIEW_MARGIN,
                                          MARKDOWNVIEW_HEIGHT);
     }
     completion:^(BOOL finished)
     {
         [self.view removeFromSuperview];
       
     } ];
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
