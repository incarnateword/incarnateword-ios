//
//  IWAboutViewController.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 30/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWAboutViewController.h"
#import "IWAboutStructure.h"
#import "IWAboutWebService.h"
#import "IWUtility.h"
#import "BPMarkdownView.h"
#import "IWCompilationStructure.h"
#import "IWUserActionManager.h"
#import "IWUIConstants.h"
#import <WebKit/WebKit.h>


@interface IWAboutViewController ()<WebServiceDelegate,UIScrollViewDelegate>
{
    IWAboutWebService       *_aboutWebService;
    IWAboutStructure        *_aboutDataStructure;
    
    BOOL                    _bShouldFlipHorizontally;
    NSTimer                 *_timerLoading;
}

@property (nonatomic, assign) CGFloat lastContentOffset;

@property (weak, nonatomic) IBOutlet UIView                     *viewLoading;
@property (weak, nonatomic) IBOutlet UIWebView                  *webView;
@property (weak, nonatomic) IBOutlet UIImageView                *imageView;
@property (weak, nonatomic) IBOutlet UIView                     *viewMiddle;
@property(strong,nonatomic) WKWebView                           *wkWebView;

-(void)setupUI;
-(void)getData;
-(void)updateUI;

@end

@implementation IWAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupWKWebView];
    [self setupUI];
    [self getData];
}

-(void)setupUI
{
    self.view.backgroundColor = COLOR_VIEW_BG;
    self.navigationItem.title = @"Loading...";
    _viewLoading.layer.cornerRadius = 3.0;
    _viewLoading.backgroundColor = COLOR_LOADING_VIEW;
//    _webView.scrollView.decelerationRate = 1.5;//UIScrollViewDecelerationRateFast;
    _wkWebView.scrollView.decelerationRate = SCROLL_DECELERATION_RATE;


    [self startLoadingAnimation];
}

-(void)setupWKWebView
{
    _wkWebView = [WKWebView new];
    [_viewMiddle addSubview:_wkWebView];
    _wkWebView.scrollView.delegate = self;

    
    _wkWebView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *subview = _wkWebView;
    
    [_viewMiddle addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[subview]-0-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(subview)]];
    
    [_viewMiddle addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[subview]-0-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(subview)]];
    

    
}

#pragma mark - Scrollview Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollView.decelerationRate = SCROLL_DECELERATION_RATE;
}


-(void)getData
{
    _aboutWebService = [[IWAboutWebService alloc] initWithPath:_strAboutPath AndDelegate:self];
    [_aboutWebService sendAsyncRequest];
}

#pragma mark - Webservice Callbacks


-(void)requestSucceed:(BaseWebService*)webService response:(id)responseModel
{
    NSLog(@"CompilationWebService Success.");
    _aboutDataStructure = (IWAboutStructure*)responseModel;
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}

-(void)requestFailed:(BaseWebService*)webService error:(WSError*)error
{
    NSLog(@"CompilationWebService Failed.");
    self.navigationItem.title = STR_WEB_SERVICE_FAILED;
    [IWUtility showWebserviceFailedAlert];
    [self stopLoadingAnimation];
}


#pragma mark - Update UI

-(void)updateUI
{
    self.navigationItem.title = @"About";
    self.navigationItem.title = _aboutDataStructure.strDescriptionTitle;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
   ^{
       //int width = (int)[[UIScreen mainScreen] bounds].size.width - 20;
       NSString *strImageTag = [NSString stringWithFormat:@"<img src=\"%@\" width=\"%d%@\" align=\"middle\">",_strImageName,100,@"%"];
       NSMutableString *strFinalString = [[NSMutableString alloc] initWithString:strImageTag];
       NSString *strHtmlString = [IWUtility getHtmlStringUsingJSLibForMarkdownText:_aboutDataStructure.strDescription forTypeHeading:NO];
       [strFinalString appendString:strHtmlString];
//       [_webView loadHTMLString:[strFinalString copy] baseURL:[IWUtility getCommonCssBaseURL]];
       [_wkWebView loadHTMLString:strFinalString baseURL:[IWUtility getCommonCssBaseURL]];

       [self performSelectorOnMainThread:@selector(stopLoadingAnimation) withObject:nil waitUntilDone:NO];
   });
}

#pragma mark - Loading Animation

-(void)startLoadingAnimation
{
    _viewLoading.hidden = NO;
    _timerLoading = [NSTimer scheduledTimerWithTimeInterval: 0.7
                                                     target: self
                                                   selector: @selector(animateLoading)
                                                   userInfo: nil
                                                    repeats: YES];
}

-(void)stopLoadingAnimation
{
    if(_timerLoading && [_timerLoading isValid])
        [_timerLoading invalidate];
    
    _timerLoading = nil;
    _viewLoading.hidden = YES;
    [self.navigationController setNavigationBarHidden: NO animated:NO];
}

-(void)animateLoading
{
    [UIView transitionWithView: _viewLoading
                      duration: 0.5
                       options: _bShouldFlipHorizontally ?  UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromBottom
                    animations:
                    ^{
                    }
                    completion:^(BOOL finished)
                    {
                        
                        _bShouldFlipHorizontally = ! _bShouldFlipHorizontally;
                    }
     ];
}


#pragma mark - Orientation

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}

@end
