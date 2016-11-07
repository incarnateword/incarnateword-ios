//
//  IWDictionaryMeaningViewController.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 03/06/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWDictionaryMeaningViewController.h"
#import "IWDictionaryMeaningWebService.h"
#import "IWWordMeaningStructure.h"
#import "IWUtility.h"
#import "BPMarkdownView.h"
#import "IWUIConstants.h"
#import "WebServiceConstants.h"
#import <WebKit/WebKit.h>



@interface IWDictionaryMeaningViewController ()<WebServiceDelegate,UIWebViewDelegate>
{
    IWDictionaryMeaningWebService       *_dictionaryMeaningWebService;
    IWWordMeaningStructure              *_wordMeaningStructure;
    BOOL                                _bShouldFlipHorizontally;
    NSTimer                             *_timerLoading;
}

@property (weak, nonatomic) IBOutlet UIView                 *viewLoading;
@property (weak, nonatomic) IBOutlet UIView                 *viewToolbar;
@property (weak, nonatomic) IBOutlet UIButton               *btnShare;
@property (weak, nonatomic) IBOutlet UIWebView              *webView;
@property(strong,nonatomic) WKWebView                       *wkWebView;


-(void)setupVC;
-(void)setupUI;
-(void)getData;
-(void)updateUI;

- (IBAction)btnBackPressed:(id)sender;
- (IBAction)btnSharePressed:(id)sender;

@end

@implementation IWDictionaryMeaningViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupVC];
}

-(void)setupVC
{
    [self setupWKWebView];
    [self setupUI];
    [self getData];
}

-(void)setupWKWebView
{
    _wkWebView = [WKWebView new];
    _wkWebView.scrollView.delegate = self;

    [self.view addSubview:_wkWebView];
    
    
    _wkWebView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *subview = _wkWebView;
    
    [self.view  addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[subview]-10-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(subview)]];
    
    [self.view  addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[subview]-44-|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(subview)]];
    
}

#pragma mark - Scrollview Delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    scrollView.decelerationRate = SCROLL_DECELERATION_RATE;
}


-(void)setupUI
{
    self.navigationItem.title = @"Loading...";
    UIBarButtonItem *backButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
    _viewLoading.backgroundColor = COLOR_LOADING_VIEW;

    _viewLoading.layer.cornerRadius = 3.0;

    _btnShare.hidden = YES;
    _viewToolbar.backgroundColor = COLOR_NAV_BAR;

    self.view.backgroundColor = COLOR_VIEW_BG;
//    _webView.scrollView.decelerationRate = 1.5;//UIScrollViewDecelerationRateFast;
    _wkWebView.scrollView.decelerationRate = SCROLL_DECELERATION_RATE;//UIScrollViewDecelerationRateFast;

    [self startLoadingAnimation];
}

-(void)getData
{
    _dictionaryMeaningWebService = [[IWDictionaryMeaningWebService alloc] initWithWord:_strWord AndDelegate:self];
    [_dictionaryMeaningWebService sendAsyncRequest];
}

#pragma mark - Webservice Callbacks


-(void)requestSucceed:(BaseWebService*)webService response:(id)responseModel
{
    NSLog(@"Dictionary Meaning Webservice Success.");
    _wordMeaningStructure = (IWWordMeaningStructure*)responseModel;
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}

-(void)requestFailed:(BaseWebService*)webService error:(WSError*)error
{
    NSLog(@"Dictionary Meaning Webservice Failed.");
    
    self.navigationItem.title = STR_WEB_SERVICE_FAILED;
    [IWUtility showWebserviceFailedAlert];
    [self stopLoadingAnimation];
}

#pragma mark - Update UI


-(void)updateUI
{
    self.navigationItem.title = _wordMeaningStructure.strWord;
    [self addMarkdownView];
    _btnShare.hidden = NO;
}

- (IBAction)btnBackPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)addMarkdownView
{
    [self performSelectorOnMainThread:@selector(startLoadingAnimation) withObject:nil waitUntilDone:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0),
   ^{
       NSString *strHtmlString = [IWUtility getHtmlStringUsingJSLibForMarkdownText:_wordMeaningStructure.strDefinition forTypeHeading:NO];
//       [_webView loadHTMLString:strHtmlString baseURL:[IWUtility getCommonCssBaseURL]];
       [_wkWebView loadHTMLString:strHtmlString baseURL:[IWUtility getCommonCssBaseURL]];

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
                    animations:^{
                    }
                    completion:^(BOOL finished) {
                        
                        _bShouldFlipHorizontally = ! _bShouldFlipHorizontally;
                    }
     ];
}

- (IBAction)btnSharePressed:(id)sender
{
    NSString *textToShare = @"";//_detailChapterStructure.strTitle;
    
    NSURL *myWebsite = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",@"http://dictionary.incarnateword.in/entries",_strWord]];
    
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

@end
