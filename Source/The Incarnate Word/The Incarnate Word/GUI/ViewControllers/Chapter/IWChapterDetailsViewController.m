//
//  IWChapterViewController.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWChapterDetailsViewController.h"
#import "IWChapterWebService.h"
#import "IWDetailChapterStructure.h"
#import "IWUtility.h"
#import "IWPathStructure.h"

#import "BPMarkdownView.h"
#import "BPDisplaySettings.h"
#import "IWUIConstants.h"
#import "IWGUIManager.h"
#import "IWInfoViewController.h"
#import "WebServiceConstants.h"

@interface IWChapterDetailsViewController ()<WebServiceDelegate,UIScrollViewDelegate,InfoViewDelegate>
{
    IWChapterWebService                     *_chapterWebService;
    IWDetailChapterStructure                *_detailChapterStructure;
    
    
    BOOL                                    _bShouldFlipHorizontally;
    NSTimer                                 *_timerLoading;
    
    BPMarkdownView                          *_markdownView;
    UITapGestureRecognizer                  *_gestureTapForTop;
    UITapGestureRecognizer                  *_gestureTapForWholeView;
    BOOL                                    _bIsScrollingInProgress;
    UISwipeGestureRecognizer                *_swipeleft,*_swiperight;
}

@property (nonatomic, assign) CGFloat lastContentOffset;


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

- (IBAction)btnPrevChapterPressed:(id)sender;
- (IBAction)btnNextChapterPressed:(id)sender;
- (IBAction)btnSharePressed:(id)sender;

-(void)setupUI;
-(void)addMarkdownView;
-(void)getData;
-(void)updateUI;

@end

@implementation IWChapterDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupVC];
}

- (IBAction)btnPrevChapterPressed:(id)sender
{
    _strChapterPath = _detailChapterStructure.strPrevChapterUrl;
    _iItemIndex = 0;
    _btnInfo.hidden = YES;
    _btnShare.hidden = YES;
    _btnNextChapter.hidden = YES;


    [UIView animateWithDuration:0.5 animations:^{
    
        CGRect rect = [self getMarkdownViewRect];
        rect.origin.x = [UIScreen mainScreen].bounds.size.width;
        _markdownView.frame = rect;
    
    } completion:^(BOOL finished)
    {
        [self setupVC];
    }];
    
}

- (IBAction)btnNextChapterPressed:(id)sender
{
    [self hideNavigationBar:NO];
    
    if([IWUtility isNilOrEmptyString:_detailChapterStructure.strNextChapterUrl])
        return;
    
    _strChapterPath = _detailChapterStructure.strNextChapterUrl;
    _iItemIndex = 0;
    _btnInfo.hidden = YES;
    _btnShare.hidden = YES;
    _btnNextChapter.hidden = YES;

    
    [UIView animateWithDuration:0.5 animations:^{
        
        CGRect rect = [self getMarkdownViewRect];
        rect.origin.x = - [UIScreen mainScreen].bounds.size.width;
        _markdownView.frame = rect;
        
    } completion:^(BOOL finished)
     {
         [self setupVC];
     }];
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
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

-(void)setupVC
{
    [self setupUI];
    [self getData];
}

-(void)setupUI
{
    CGRect rect = [[UIScreen mainScreen] bounds];

    float space = rect.size.width / 3 - 50 - 25;
    
    _constraintHorizontalSpaceBtnsBackNext.constant = space;
    _constraintHorizontalSpaceBtnsInfoShare.constant = space +5;
    
   
    _viewLoading.layer.cornerRadius = 3.0;
    _viewLoading.backgroundColor = COLOR_LOADING_VIEW;
    self.view.backgroundColor = COLOR_VIEW_BG;
    _viewBottom.backgroundColor = COLOR_VIEW_BG;
    _viewToolbar.backgroundColor = COLOR_NAV_BAR;

    
    _btnInfo.titleLabel.font = [UIFont fontWithName:FONT_BODY_ITALIC size:26.0];
    
    
    [self startLoadingAnimation];

    _viewBottom.hidden = YES;
    self.navigationItem.title = @"Loading...";
    


//    _btnPrevChapter.hidden = YES;
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
    _chapterWebService = [[IWChapterWebService alloc] initWithPath:_strChapterPath AndDelegate:self];
    [_chapterWebService sendAsyncRequest];
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
    [self stopLoadingAnimation];
}


#pragma mark - Update UI


-(void)updateUI
{
    _viewBottom.hidden = NO;
    
    NSString *navBarTitle = @"";
    
    if(_detailChapterStructure.arrPath.count >= 2)
    {
        IWPathStructure *path = [_detailChapterStructure.arrPath objectAtIndex:1];
        navBarTitle = path.strTitle;
    }
    self.navigationItem.title = navBarTitle;//_detailChapterStructure.strTitle;
    
    if([IWUtility isNilOrEmptyString:_detailChapterStructure.strDescription] == NO)
    {
        _btnInfo.hidden = NO;
    }
        
    

    [self addMarkdownView];
    
//    NSArray *arrDate = [_detailChapterStructure.strDate componentsSeparatedByString:@"-"];
    
//    if(arrDate.count == 3)
//    {
//        _lblYear.text = [arrDate objectAtIndex:0];
//        NSArray *months = [[NSArray alloc] initWithObjects:@"JAN",@"FEB",@"MARCH",@"APRIL",@"MAY",@"JUNE",@"JULY",@"AUG",@"SEP",@"OCT",@"NOV",@"DEC", nil ];
//        
//        int iMonth = [[arrDate objectAtIndex:1] intValue];
//        NSString *strMonth =  (iMonth > 0 && iMonth <=12 )? [months objectAtIndex: iMonth -1] :@"";
//        _lblMonth.text = strMonth;
//        _lblDay.text = [arrDate objectAtIndex:2];
//        _viewDate.hidden = NO;
//    }
    
    NSMutableString *strPath = [[NSMutableString alloc] init];
    
    for (IWPathStructure *path in _detailChapterStructure.arrPath)
    {
        [strPath appendString:path.strTitle];

        if([_detailChapterStructure.arrPath lastObject] != path)
            [strPath appendString:@" / "];
    }
    
//    _lblBreadCrum.text = [strPath copy];
    

    
    
    _btnNextChapter.hidden = [IWUtility isNilOrEmptyString:_detailChapterStructure.strNextChapterUrl];
//    _btnPrevChapter.hidden = [IWUtility isNilOrEmptyString:_detailChapterStructure.strPrevChapterUrl];
    _btnShare.hidden = NO;
    
    [self stopLoadingAnimation];
}

-(void)addMarkdownView
{
    
    [_markdownView removeFromSuperview];
    _markdownView.delegate = nil;
    _markdownView = nil;
    
    _markdownView  = [IWUtility getMarkdownViewOfFrame:[self getMarkdownViewRect]];
    [_viewBottom addSubview:_markdownView];
    [_markdownView setMarkdown:_detailChapterStructure.strText];
    _markdownView.delegate = self;
}

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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _bIsScrollingInProgress = YES;
    
    if (self.lastContentOffset > scrollView.contentOffset.y)
    {
        [self hideNavigationBar:NO];
        NSLog(@"Up");
    }
    else if (self.lastContentOffset < scrollView.contentOffset.y)
    {
        [self hideNavigationBar:YES];
        NSLog(@"Down");
    }
    
    self.lastContentOffset = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"END DRAG..");
    _bIsScrollingInProgress = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"END DECELERATION..");
    _bIsScrollingInProgress = NO;
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

- (IBAction)btnBackPressed:(id)sender {
    
    [self hideNavigationBar:NO];
    
    if([IWUtility isNilOrEmptyString:_detailChapterStructure.strPrevChapterUrl])
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self btnPrevChapterPressed:nil];
}

- (IBAction)btnInfoPressed:(id)sender {
    
    IWInfoViewController *infoVC = [[IWGUIManager sharedManager] getInfoViewControllerForText:_detailChapterStructure.strDescription];
    infoVC.delegateInfoView = self;
    
    
    [UIView animateWithDuration:0.2 animations:
     ^{
         _viewBottom.alpha  = 0.2;
         
     }];
    
    [UIView animateWithDuration:0.5 animations:
     ^{
         _viewToolbar.alpha = 0;

     }
                     completion:^(BOOL finished)
     {
         
//         _viewToolbar.hidden = YES;

     } ];


    [self addChildViewController:infoVC];
    
    [self.view addSubview:infoVC.view];
}

-(void)infoViewRemoved
{
//    _viewToolbar.hidden = NO;

    _viewToolbar.alpha = 1;

    
    [UIView animateWithDuration:0.2 animations:
     ^{
         _viewBottom.alpha  = 1.0;
     }
                     completion:^(BOOL finished)
     {
         
         
     } ];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}




@end
