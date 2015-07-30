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


@interface IWDictionaryMeaningViewController ()<WebServiceDelegate>
{
    IWDictionaryMeaningWebService       *_dictionaryMeaningWebService;
    IWWordMeaningStructure              *_wordMeaningStructure;

    BOOL                                _bShouldFlipHorizontally;
    NSTimer                             *_timerLoading;
    
    BPMarkdownView                      *_markdownView;
}

@property (weak, nonatomic) IBOutlet UIView                 *viewLoading;
@property (strong, nonatomic) IBOutlet UIView               *viewDescription;
@property (weak, nonatomic) IBOutlet UIView                 *viewToolbar;
@property (weak, nonatomic) IBOutlet UIButton               *btnShare;


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
    [self setupUI];
    [self getData];
}

-(void)setupUI
{
    self.navigationItem.title = @"Loading...";
    _viewLoading.backgroundColor = COLOR_LOADING_VIEW;

    _viewLoading.layer.cornerRadius = 3.0;
    _viewDescription.layer.cornerRadius = 3.0;

    _viewDescription.hidden = YES;
    _btnShare.hidden = YES;
    _viewToolbar.backgroundColor = COLOR_NAV_BAR;

    self.view.backgroundColor = COLOR_VIEW_BG;
    
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
    _viewDescription.hidden = NO;
    _btnShare.hidden = NO;

    [self stopLoadingAnimation];
}

- (IBAction)btnBackPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)addMarkdownView
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGFloat totalTopMargin = 44;
    
    
    
    CGRect markdownRect = CGRectMake(5,-3,
                      screenWidth -4,
                                     screenHeight - totalTopMargin -10);
    _markdownView  = [IWUtility getMarkdownViewOfFrame:markdownRect withCustomBPDisplaySettings:nil];
    [_viewDescription addSubview:_markdownView];
    _markdownView.layer.cornerRadius = 3.0;
    [_markdownView setMarkdown:_wordMeaningStructure.strDefinition];
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
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

@end
