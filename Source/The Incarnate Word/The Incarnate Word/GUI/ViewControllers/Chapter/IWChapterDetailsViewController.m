//
//  IWChapterViewController.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWChapterDetailsViewController.h"
#import "IWChapterWebService.h"
#import "IWUtility.h"
#import "IWPathStructure.h"
#import "BPMarkdownView.h"
#import "BPDisplaySettings.h"
#import "IWUIConstants.h"
#import "IWGUIManager.h"
#import "IWInfoViewController.h"
#import "WebServiceConstants.h"
#import "IWUserActionManager.h"
#import <WebKit/WebKit.h>
#import "IWGUIManager.h"


@interface IWChapterDetailsViewController ()<WebServiceDelegate,UIScrollViewDelegate,InfoViewDelegate,UIWebViewDelegate,WKNavigationDelegate>
{
    IWChapterWebService                     *_chapterWebService;
    
    BOOL                                    _bShouldFlipHorizontally;
    NSTimer                                 *_timerLoading;
    
    BPMarkdownView                          *_markdownView;
    UITapGestureRecognizer                  *_gestureTapForTop;
    UITapGestureRecognizer                  *_gestureTapForWholeView;
    BOOL                                    _bIsScrollingInProgress;
    UISwipeGestureRecognizer                *_swipeleft,*_swiperight;
    IWInfoViewController                    *_infoVC;
    NSString                                *_strDate;
    
    IWDetailChapterStructure                *_detailChapterStructure;
    BOOL                                    _bIsWebviewLoadingWithActualData;
}

@property (nonatomic, assign) CGFloat                           lastContentOffset;
@property (weak, nonatomic) IBOutlet UIView                     *viewBottom;
@property (weak, nonatomic) IBOutlet UIView                     *viewLoading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *constraintViewBottomTopSpace;
@property (weak, nonatomic) IBOutlet UIButton                   *btnPrevChapter;
@property (weak, nonatomic) IBOutlet UIButton                   *btnNextChapter;
@property (weak, nonatomic) IBOutlet UIView                     *viewForTap;
@property (weak, nonatomic) IBOutlet UIButton                   *btnInfo;
@property (weak, nonatomic) IBOutlet UIView                     *viewToolbar;
@property (weak, nonatomic) IBOutlet UIButton                   *btnShare;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *constraintHorizontalSpaceBtnsBackNext;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *constraintHorizontalSpaceBtnsInfoShare;
//@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView                     *containerWebVIew;
@property(strong,nonatomic) WKWebView                           *wkWebView;

- (IBAction)btnPrevChapterPressed:(id)sender;
- (IBAction)btnNextChapterPressed:(id)sender;
- (IBAction)btnSharePressed:(id)sender;

-(void)setupUI;
-(void)addMarkdownView;
-(void)getData;
-(void)updateUI;

@end

@implementation IWChapterDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupWKWebView];
    [self setupVC];
}


-(void)setupWKWebView
{
    _wkWebView = [WKWebView new];
    _wkWebView.scrollView.delegate = self;
    _wkWebView.navigationDelegate = self;
    [_containerWebVIew addSubview:_wkWebView];
    
    
    _wkWebView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *subview = _wkWebView;
    
    [_containerWebVIew addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[subview]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(subview)]];
    
    [_containerWebVIew addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[subview]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(subview)]];

}
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    
    [self stopLoadingAnimation];
    
    if (_iParagraphIndex > 0 && _bIsWebviewLoadingWithActualData)
    {
        NSLog(@"WKWebView didFinishNavigation, Jumping to para: %d",_iParagraphIndex);

        NSString *strScrllToPara = [NSString stringWithFormat:@"document.getElementsByTagName('p')[%d].scrollIntoView();",_iParagraphIndex];
        _iParagraphIndex = 0;
        _bIsWebviewLoadingWithActualData = NO;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
        ^{
            dispatch_async(dispatch_get_main_queue(),
            ^{
                [_wkWebView evaluateJavaScript:strScrllToPara completionHandler:nil];
            });
        });
    }
    
}

- (IBAction)btnPrevChapterPressed:(id)sender
{
    _strChapterPath = _detailChapterStructure.strPrevChapterUrl;
    _offlineDetailChapterStructure = nil;

    _iItemIndex = 0;
    _btnInfo.hidden = YES;
    _btnShare.hidden = YES;
    _btnNextChapter.hidden = YES;

    [self setupVC];
    
    
    /* PAGE CURL

    UIView *tempUIView=[[UIView alloc]initWithFrame:self.view.bounds];
    tempUIView.backgroundColor=[UIColor whiteColor];
    
    [UIView animateWithDuration:1.0
                     animations:
     ^{
         CATransition  * animation = [CATransition animation];
         [animation setDelegate:self];
         [animation setDuration:1.2f];
         animation.startProgress =0.0;
         animation.endProgress   = 1.0;
         [animation setTimingFunction:UIViewAnimationCurveEaseInOut];
         [animation setType:@"pageCurl"];
         [animation setSubtype:@"fromLeft"];
         [animation setRemovedOnCompletion:YES];
         [animation setFillMode: @"extended"];
         [animation setRemovedOnCompletion: YES];
         [[_wkWebView layer] addAnimation:animation
                                   forKey:@"pageFlipAnimation"];
         [_wkWebView addSubview:tempUIView];
     }
                     completion:^(BOOL finished)
     {
         [tempUIView removeFromSuperview];
     }
     ];
     
     */
}

- (IBAction)btnNextChapterPressed:(id)sender
{
    [self hideNavigationBar:NO];
    
    if([IWUtility isNilOrEmptyString:_detailChapterStructure.strNextChapterUrl])
        return;
    
    _strChapterPath = _detailChapterStructure.strNextChapterUrl;
    _offlineDetailChapterStructure = nil;
    _iItemIndex = 0;
    _btnInfo.hidden = YES;
    _btnShare.hidden = YES;
    _btnNextChapter.hidden = YES;


    [self setupVC];
    
    /* PAGE CURL
     
    UIView *tempUIView=[[UIView alloc]initWithFrame:self.view.bounds];
    tempUIView.backgroundColor=[UIColor whiteColor];
    
    [UIView animateWithDuration:1.0
                     animations:
                                ^{
                                     CATransition  * animation = [CATransition animation];
                                     [animation setDelegate:self];
                                     [animation setDuration:1.2f];
                                     animation.startProgress =0.0;
                                     animation.endProgress   = 1.0;
                                     [animation setTimingFunction:UIViewAnimationCurveEaseInOut];
                                     [animation setType:@"pageCurl"];
                                     [animation setSubtype:@"fromRight"];
                                     [animation setRemovedOnCompletion:YES];
                                     [animation setFillMode: @"extended"];
                                     [animation setRemovedOnCompletion: YES];
                                     [[_wkWebView layer] addAnimation:animation
                                                                        forKey:@"pageFlipAnimation"];
                                     [_wkWebView addSubview:tempUIView];
                                }
                                completion:^(BOOL finished)
                                {
                                    [tempUIView removeFromSuperview];
                                }
     ];
     
     */
}

- (IBAction)btnSharePressed:(id)sender
{
    NSString *textToShare = @"";//_detailChapterStructure.strTitle;
    NSURL *myWebsite = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",BASE_URL,_strChapterPath]];
    
    NSArray *objectsToShare = @[/*textToShare,*/ myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
//    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
//                                   UIActivityTypePrint,
//                                   UIActivityTypeAssignToContact,
//                                   UIActivityTypeSaveToCameraRoll,
//                                   UIActivityTypeAddToReadingList,
//                                   UIActivityTypePostToFlickr,
//                                   UIActivityTypePostToVimeo];
//    
//    activityVC.excludedActivityTypes = excludeActivities;
    
    if([IWUtility isDeviceTypeIpad])
    {
        UIPopoverController *pop = [[UIPopoverController alloc] initWithContentViewController:activityVC];
        
        CGRect screenBound = [[UIScreen mainScreen] bounds];
        CGRect rect = CGRectMake(screenBound.size.width - 65 , screenBound.size.height - 100 , 30, 30);
        
        [pop presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    }
    else
    {
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

-(void)setupVC
{
    [self setupUI];
    [self getData];
}

-(void)setupUI
{

    [self setBottomBarButtonSpacing];
   
    _viewLoading.layer.cornerRadius = 3.0;
    _viewLoading.backgroundColor = COLOR_LOADING_VIEW;
    self.view.backgroundColor = COLOR_VIEW_BG;
    _viewBottom.backgroundColor = COLOR_VIEW_BG;
    _viewToolbar.backgroundColor = COLOR_NAV_BAR;
    
    _btnInfo.titleLabel.font = [UIFont fontWithName:FONT_BODY_ITALIC size:28.0];
    
//    [_webView loadHTMLString:@"" baseURL:nil];
    
    [_wkWebView loadHTMLString:@"" baseURL:nil];
    
//    [self startLoadingAnimation];

    _viewBottom.hidden = YES;
    self.navigationItem.title = @"Loading...";
    UIBarButtonItem *backButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
    
    _btnNextChapter.hidden = YES;
    _btnShare.hidden = YES;
    
    _gestureTapForWholeView = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                action:@selector(handleSingleTap:)];
    _gestureTapForWholeView.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:_gestureTapForWholeView];
    
    _gestureTapForTop = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                action:@selector(handleSingleTap:)];
    [_viewForTap addGestureRecognizer:_gestureTapForTop];
    
    
    _swipeleft =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    _swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:_swipeleft];
    
    _swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    _swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:_swiperight];
    
//    _webView.delegate = self;
    
}

-(void)setBottomBarButtonSpacing
{
    float space = [IWUtility getHorizontalSpaceBetweenButtons];
    
    _constraintHorizontalSpaceBtnsBackNext.constant = space;
    _constraintHorizontalSpaceBtnsInfoShare.constant = space ;
}

-(void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [self btnNextChapterPressed:nil];
    }
}

-(void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [self btnBackPressed:nil];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    if(recognizer == _gestureTapForTop)
    {
        if(_markdownView)
        {
            [_markdownView scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:YES];
        }
    }
    else if(recognizer ==_gestureTapForWholeView && _bIsScrollingInProgress == NO)
    {
        [self hideNavigationBar:!_viewToolbar.hidden];
    }
}

-(void)getData
{
    if(_offlineDetailChapterStructure == nil)
    {
        NSString *strPath = [_strChapterPath hasPrefix:@"/"] ? _strChapterPath : [NSString stringWithFormat:@"/%@",_strChapterPath];
        _offlineDetailChapterStructure = [[IWUserActionManager sharedManager] getOfflineChapterWithUrl:strPath];
    }
    
    [self performSelectorOnMainThread:@selector(startLoadingAnimation) withObject:nil waitUntilDone:NO];

    if(_offlineDetailChapterStructure)
    {
        _detailChapterStructure = _offlineDetailChapterStructure;
        [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
    }
    else
    {
        _chapterWebService = [[IWChapterWebService alloc] initWithPath:_strChapterPath AndDelegate:self];
        [_chapterWebService sendAsyncRequest];
    }
}

#pragma mark - Webservice Callbacks


-(void)requestSucceed:(BaseWebService*)webService response:(id)responseModel
{
    NSLog(@"ChapterWebService Success.");
    _detailChapterStructure = (IWDetailChapterStructure*)responseModel;
    

    
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}

-(void)requestFailed:(BaseWebService*)webService error:(WSError*)error
{
    self.navigationItem.title = STR_WEB_SERVICE_FAILED;
    [IWUtility showWebserviceFailedAlert];

    NSLog(@"ChapterWebService Failed.");
    [self performSelectorOnMainThread:@selector(stopLoadingAnimation) withObject:nil waitUntilDone:NO];
}


#pragma mark - Update UI


-(void)updateUI
{
    _viewBottom.hidden = NO;
//    _webView.scrollView.decelerationRate = 1.5;//UIScrollViewDecelerationRateFast;
    
    _wkWebView.scrollView.decelerationRate = SCROLL_DECELERATION_RATE;
    
    NSString *navBarTitle = @"";
    
    if(_detailChapterStructure.arrPath.count >= 2)
    {
        IWPathStructure *path = [_detailChapterStructure.arrPath objectAtIndex:1];
        navBarTitle = path.strTitle;
    }
    self.navigationItem.title = navBarTitle;//_detailChapterStructure.strTitle;
    
    
        
    

    [self addMarkdownView];
    
    NSArray *arrDate = [_detailChapterStructure.strDate componentsSeparatedByString:@"-"];
    
    if(arrDate.count == 3)
    {
        NSString *strYear = [arrDate objectAtIndex:0];
        NSArray *months = [[NSArray alloc] initWithObjects:@"Jan",@"Feb",@"March",@"April",@"May",@"June",@"July",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec", nil ];
        
        int iMonth = [[arrDate objectAtIndex:1] intValue];
        NSString *strMonth =  (iMonth > 0 && iMonth <=12 )? [months objectAtIndex: iMonth -1] :@"";
        NSString *strDay = [arrDate objectAtIndex:2];
        
        _strDate = [NSString stringWithFormat:@"%@ %@ %@",strDay,strMonth,strYear];
    }
    else
    {
         _strDate = @"";
    }
    

    
    NSMutableString *strPath = [[NSMutableString alloc] init];
    
    for (IWPathStructure *path in _detailChapterStructure.arrPath)
    {
        [strPath appendString:path.strTitle];

        if([_detailChapterStructure.arrPath lastObject] != path)
            [strPath appendString:@" / "];
    }
    

    
//    [self stopLoadingAnimation];
}

-(void)showButtonsBasedOnContent
{
    _btnNextChapter.hidden = [IWUtility isNilOrEmptyString:_detailChapterStructure.strNextChapterUrl];
    _btnShare.hidden = NO;
    if([IWUtility isNilOrEmptyString:_detailChapterStructure.strDescription] == NO ||
       [IWUtility isNilOrEmptyString:_strDate] == NO)
    {
        _btnInfo.hidden = NO;
    }
}




-(void)addMarkdownView
{
//    [self performSelectorOnMainThread:@selector(startLoadingAnimation) withObject:nil waitUntilDone:NO];

    if([IWUtility isNilOrEmptyString:_detailChapterStructure.strTextParsed])
    {
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
       ^{
            NSString *strHtmlString = [IWUtility getHtmlStringUsingJSLibForMarkdownText:_detailChapterStructure.strText forTypeHeading:NO];
            NSLog(@"Called loadHTMLString");
    //       NSString *cssPath = [[NSBundle mainBundle] pathForResource:@"chapter" ofType:@"css"];

//            [_webView loadHTMLString:strHtmlString baseURL:[IWUtility getCommonCssBaseURL]];
           
           _bIsWebviewLoadingWithActualData = YES;
           [_wkWebView loadHTMLString:strHtmlString baseURL:[IWUtility getCommonCssBaseURL]];
           
           _detailChapterStructure.strTextParsed = strHtmlString;
            [[IWUserActionManager sharedManager] saveChapter:_detailChapterStructure];
           
//           dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void)
//           {
//               [self stopLoadingAnimation];
//           });
           
           [self performSelectorOnMainThread:@selector(showButtonsBasedOnContent) withObject:nil waitUntilDone:NO];

        });
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
           ^{
//               [_webView loadHTMLString:_offlineDetailChapterStructure.strTextParsed baseURL:[IWUtility getCommonCssBaseURL]];
               _bIsWebviewLoadingWithActualData = YES;
               [_wkWebView loadHTMLString:_offlineDetailChapterStructure.strTextParsed baseURL:[IWUtility getCommonCssBaseURL]];

//               dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^(void)
//               {
//                   [self stopLoadingAnimation];
//               });
               
               [self performSelectorOnMainThread:@selector(showButtonsBasedOnContent) withObject:nil waitUntilDone:NO];
           });
    }
    return;
    
    [_markdownView removeFromSuperview];
    _markdownView.delegate = nil;
    _markdownView = nil;
    
    _markdownView  = [IWUtility getMarkdownViewOfFrame:[self getMarkdownViewRect] withCustomBPDisplaySettings:nil];
    [_viewBottom addSubview:_markdownView];
    [_markdownView setMarkdown:_detailChapterStructure.strText];
    _markdownView.delegate = self;
    _markdownView.scrollsToTop = YES;
}

/*

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad");
}
 
*/
-(CGRect)getMarkdownViewRect
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
   return CGRectMake(5,
               -3,
               screenWidth -4,
               screenHeight - 20 - 44  + 6 - 44 );
}


- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView
{
    return YES;
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
    [[IWGUIManager sharedManager] removeActivityIndicatorOverWindow];
    
    if(_timerLoading && [_timerLoading isValid])
        [_timerLoading invalidate];
    
    _timerLoading = nil;
    _viewLoading.hidden = YES;
}

-(void)animateLoading
{
    [UIView transitionWithView: _viewLoading
                      duration: 0.5
                       options: _bShouldFlipHorizontally ?  UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromBottom
                    animations:^{
                    }
                    completion:^(BOOL finished) {
                        
                        _bShouldFlipHorizontally = ! _bShouldFlipHorizontally;
                    }
     ];
}



#pragma mark - Scrollview Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollView.decelerationRate = SCROLL_DECELERATION_RATE;
}


-(void)hideNavigationBar:(BOOL) bShouldHide
{
    return;
    
    if(_viewToolbar.hidden == NO && bShouldHide == YES )
    {
      [self.navigationController setNavigationBarHidden: bShouldHide animated:YES];
      _viewToolbar.hidden = bShouldHide;
      [[UIApplication sharedApplication] setStatusBarHidden:bShouldHide];
    }
    else if (_viewToolbar.hidden == YES && bShouldHide == NO)
    {
      [self.navigationController setNavigationBarHidden: bShouldHide animated:YES];
      _viewToolbar.hidden = bShouldHide;
      [[UIApplication sharedApplication] setStatusBarHidden:bShouldHide];
    }
 }

- (IBAction)btnBackPressed:(id)sender
{
    
    [self hideNavigationBar:NO];
    
    if([IWUtility isNilOrEmptyString:_detailChapterStructure.strPrevChapterUrl])
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self btnPrevChapterPressed:nil];
}

- (IBAction)btnInfoPressed:(id)sender
{
    _infoVC = [[IWGUIManager sharedManager] getInfoViewControllerForText:_detailChapterStructure.strDescription];
    _infoVC.delegateInfoView = self;
    _infoVC.strDate = _strDate;
    
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    [keyWindow addSubview:_infoVC.view];
    _infoVC.view.frame = [keyWindow bounds];
}

-(void)infoViewRemoved
{
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Orientation

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateUIForOrientationChange];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self updateUIForOrientationChange];
}

-(void)updateUIForOrientationChange
{
    dispatch_async(dispatch_get_main_queue(),
   ^{
       [self setBottomBarButtonSpacing];
   });
}

-(void)dealloc
{
    [self stopLoadingAnimation];
    _wkWebView.scrollView.delegate = nil;

    NSLog(@"DEALLOC~~~~~~~~~~~~");
}

@end
