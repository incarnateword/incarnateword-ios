//
//  IWVolumeDetailsViewController.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWVolumeDetailsViewController.h"
#import "IWVolumeWebService.h"
#import "IWDetailVolumeStructure.h"
#import "IWPartStructure.h"
#import "IWChapterStructure.h"
#import "IWUserActionManager.h"
#import "IWUtility.h"
#import "IWChaterItemStructure.h"
#import "IWUIConstants.h"
#import "IWSectionStructure.h"
#import "IWSubSectionStructrue.h"
#import "IWBookStructure.h"
#import "IWSegmentStructure.h"

@interface IWVolumeDetailsViewController ()<WebServiceDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    IWVolumeWebService                  *_volumeWebService;
    IWDetailVolumeStructure             *_detailVolumeStructure;
    CGFloat                             _fTopViewHeight;
    BOOL                                _bShouldFlipHorizontally;
    NSTimer                             *_timerLoading;
    UIView                              *_viewMaterial;
    UILabel                             *_lblMaterialTop;
    UILabel                             *_lblMaterialBottom;
    BOOL                                _bIsAddingMaterialTopBar;
    UITapGestureRecognizer              *_tapGestureOnDummyScrollView;
    UISwipeGestureRecognizer            *_swipeleft,*_swiperight;
}

@property (nonatomic, assign) CGFloat                           lastContentOffset;
@property (weak, nonatomic) IBOutlet UITableView                *tableViewParts;
@property (weak, nonatomic) IBOutlet UIView                     *viewBottom;
@property (weak, nonatomic) IBOutlet UIView                     *viewLoading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *constraintViewBottomTopSpace;
@property (weak, nonatomic) IBOutlet UIButton                   *btnPrevVolume;
@property (weak, nonatomic) IBOutlet UIButton                   *btnNextVolume;
@property (strong, nonatomic) IBOutlet UIView                   *viewToolbar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint       *constraintViewToolbarHeight;
@property (weak, nonatomic) IBOutlet UILabel                    *lblTop;
@property (weak, nonatomic) IBOutlet UILabel                    *lblBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *constraintViewTopHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *constraintLblTopTopSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *constraintLblBottomTopSpace;
@property (weak, nonatomic) IBOutlet UIScrollView               *scrollViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *constraintHorizontalSpaceBtnsBackNext;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTableBottomSpace;


- (IBAction)btnPrevVolumePressed:(id)sender;
- (IBAction)btnNextVolumePressed:(id)sender;

-(void)setupVC;
-(void)setupUI;
-(void)getData;
-(void)updateUI;

@end

@implementation IWVolumeDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupVC];
}

- (IBAction)btnPrevVolumePressed:(id)sender
{
    if([IWUtility isNilOrEmptyString:_detailVolumeStructure.strUrlPrevVolume])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        CGRect rectTableTop = CGRectMake(0, 0, 10, 10);
        [_tableViewParts scrollRectToVisible:rectTableTop animated:NO];
        
        _strVolumePath = _detailVolumeStructure.strUrlPrevVolume;
        [self setupVC];
    }
}

- (IBAction)btnNextVolumePressed:(id)sender
{
    if([IWUtility isNilOrEmptyString:_detailVolumeStructure.strUrlNextVolume])
        return;
    
    CGRect rectTableTop = CGRectMake(0, 0, 10, 10);
    [_tableViewParts scrollRectToVisible:rectTableTop animated:NO];
    
    _strVolumePath = _detailVolumeStructure.strUrlNextVolume;
    [self setupVC];
}

-(void)setupVC
{
    [self setupUI];
    [self getData];
}

-(void)setupUI
{
    //Hide bottom bar for right drawer based volume listing
    _constraintViewToolbarHeight.constant = 0;
    _constraintTableBottomSpace.constant = 0;
    
    self.navigationItem.title = @"Loading...";
    _viewLoading.layer.cornerRadius = 3.0;
    _viewLoading.backgroundColor = COLOR_LOADING_VIEW;

    _constraintViewBottomTopSpace.constant = 0;
    _tableViewParts.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _viewBottom.hidden = YES;
    _btnNextVolume.hidden = YES;
    
    self.view.backgroundColor = COLOR_VIEW_BG;
    _viewBottom.backgroundColor = COLOR_VIEW_BG;
    _viewToolbar.backgroundColor = COLOR_NAV_BAR;
    
    
    _constraintHorizontalSpaceBtnsBackNext.constant = [IWUtility getHorizontalSpaceBetweenButtons];
    
    _swipeleft =[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    _swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:_swipeleft];
    
    _swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    _swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:_swiperight];

    [self startLoadingAnimation];
}

-(void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [self btnNextVolumePressed:nil];
    }
}

-(void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        [self btnPrevVolumePressed:nil];
    }
}

-(void)getData
{
    _volumeWebService = [[IWVolumeWebService alloc] initWithPath:_strVolumePath AndDelegate:self];
    [_volumeWebService sendAsyncRequest];
}

#pragma mark - Webservice Callbacks


-(void)requestSucceed:(BaseWebService*)webService response:(id)responseModel
{
    NSLog(@"VolumeWebService Success.");
    _detailVolumeStructure = (IWDetailVolumeStructure*)responseModel;
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}

-(void)requestFailed:(BaseWebService*)webService error:(WSError*)error
{
    NSLog(@"VolumeWebService Failed.");

    self.navigationItem.title = STR_WEB_SERVICE_FAILED;
    [IWUtility showWebserviceFailedAlert];

    [self stopLoadingAnimation];
}


#pragma mark - Update UI

-(void)updateUI
{
    _viewBottom.hidden = NO;
    self.navigationItem.title = _detailVolumeStructure.strCompilationName;
    _btnNextVolume.hidden = [IWUtility isNilOrEmptyString:_detailVolumeStructure.strUrlNextVolume];
    
    [_tableViewParts reloadData];
    [self stopLoadingAnimation];

    [self setHeaderView];
}

-(void)setHeaderView
{
    float fTopViewHeight = [IWUtility getNumberAsPerScalingFactor:100];
    float fTopLbl_Y = [IWUtility getNumberAsPerScalingFactor:10];
    float fBottomLbl_Y = [IWUtility getNumberAsPerScalingFactor:10] + [IWUtility getNumberAsPerScalingFactor:40] + [IWUtility getNumberAsPerScalingFactor:10];
    BOOL bIsTitlePresent = YES;
    
    if([IWUtility isNilOrEmptyString:_detailVolumeStructure.strTitle])
    {
        fTopViewHeight = fTopViewHeight - [IWUtility getNumberAsPerScalingFactor:10] - [IWUtility getNumberAsPerScalingFactor:40];
        fBottomLbl_Y = [IWUtility getNumberAsPerScalingFactor:10];
        bIsTitlePresent = NO;
    }
    
    if([IWUtility isNilOrEmptyString:_detailVolumeStructure.strSubTitle])
    {
        fTopViewHeight = fTopViewHeight - [IWUtility getNumberAsPerScalingFactor:10] - [IWUtility getNumberAsPerScalingFactor:30] - (bIsTitlePresent ? 0 : [IWUtility getNumberAsPerScalingFactor:10]);
    }
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    UILabel *lblTop = [[UILabel alloc] initWithFrame:CGRectMake(10, fTopLbl_Y, rect.size.width-20, [IWUtility getNumberAsPerScalingFactor:40])];
    UILabel *lblBottom = [[UILabel alloc] initWithFrame:CGRectMake(10, fBottomLbl_Y, rect.size.width-20, [IWUtility getNumberAsPerScalingFactor:30])];

    lblTop.text = _detailVolumeStructure.strTitle;
    lblTop.font  = [UIFont fontWithName:FONT_TITLE_REGULAR size:[IWUtility getNumberAsPerScalingFactor:20]];
    lblTop.textAlignment = NSTextAlignmentCenter;
    lblTop.textColor = [UIColor whiteColor];
    
    lblBottom.text = _detailVolumeStructure.strSubTitle;
    lblBottom.font  = [UIFont fontWithName:FONT_TITLE_REGULAR size:[IWUtility getNumberAsPerScalingFactor:18]];
    lblBottom.textAlignment = NSTextAlignmentCenter;
    lblBottom.textColor = [UIColor whiteColor];

    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, fTopViewHeight)];
    headerView.backgroundColor = [UIColor darkGrayColor];
    [headerView addSubview:lblTop];
    [headerView addSubview:lblBottom];
    
    _tableViewParts.tableHeaderView = headerView;
}


#pragma mark - Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(_detailVolumeStructure.arrBooks && _detailVolumeStructure.arrBooks)
        return _detailVolumeStructure.arrBooks.count;//Volume has books show them as section
        
    return _detailVolumeStructure.arrParts.count;//Volume may contain parts
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger rowCount = 0;
    
    if(_detailVolumeStructure.arrBooks && _detailVolumeStructure.arrBooks)//Volume has books
    {
        IWBookStructure *book = [_detailVolumeStructure.arrBooks objectAtIndex:section];
        NSArray *arrChapAndItem = [book getChaptersAndItemsFromBookArray];
        rowCount = arrChapAndItem.count;
    }
    else if(_detailVolumeStructure.arrParts && _detailVolumeStructure.arrParts > 0)//Volume has parts
    {
        IWPartStructure *part = [_detailVolumeStructure.arrParts objectAtIndex:section];
        NSArray *arrChapAndItem = [part getChaptersAndItemsFromPartArray];
        rowCount = arrChapAndItem.count;
    }
    else if(_detailVolumeStructure.arrChapters && _detailVolumeStructure.arrChapters > 0)//Volume has direct chapters
    {
        NSArray *arrChapAndItem = [self getChaptersAndItemsFromChapterArray:_detailVolumeStructure.arrChapters];
        rowCount = arrChapAndItem.count;
    }

    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id chapOrItem;
    
    if(_detailVolumeStructure.arrBooks && _detailVolumeStructure.arrBooks)//Volume has books
    {
        IWBookStructure *book = [_detailVolumeStructure.arrBooks objectAtIndex:indexPath.section];
        NSArray *arrChapAndItem = [book getChaptersAndItemsFromBookArray];
        chapOrItem = [arrChapAndItem objectAtIndex:indexPath.row];
    }
    else if(_detailVolumeStructure.arrParts && _detailVolumeStructure.arrParts > 0)//Volume has parts
    {
        IWPartStructure *part = [_detailVolumeStructure.arrParts objectAtIndex:indexPath.section];
        NSArray *arrChapAndItem = [part getChaptersAndItemsFromPartArray];
        chapOrItem = [arrChapAndItem objectAtIndex:indexPath.row];
    }
    else if(_detailVolumeStructure.arrChapters && _detailVolumeStructure.arrChapters > 0)//Volume has direct chapters
    {
        NSArray *arrChapAndItem = [self getChaptersAndItemsFromChapterArray:_detailVolumeStructure.arrChapters];
        chapOrItem = [arrChapAndItem objectAtIndex:indexPath.row];
    }
    
    UITableViewCell *cell;
    NSString *strTitle = @"";
    float fFontSize = 17;
    UIColor *color = [UIColor whiteColor];
    
    if([chapOrItem isKindOfClass:[IWPartStructure class]])
    {
        IWPartStructure *book = (IWPartStructure*)chapOrItem;
        cell = [tableView dequeueReusableCellWithIdentifier:@"PartCell"];
        strTitle = book.strTitle;
//        fFontSize = 20;
        color = [UIColor colorWithRed:180.0/255 green:180.0/255 blue:180.0/255 alpha:1.0];
    }
    else if([chapOrItem isKindOfClass:[IWSectionStructure class]])
    {
        IWSectionStructure *section = (IWSectionStructure*)chapOrItem;
        cell = [tableView dequeueReusableCellWithIdentifier:@"SectionCell"];
        strTitle = section.strTitle;
//        fFontSize = 19;
        color = [UIColor colorWithRed:210.0/255 green:210.0/255 blue:210.0/255 alpha:1.0];
    }
    else if([chapOrItem isKindOfClass:[IWSubSectionStructrue class]])
    {
        IWSubSectionStructrue *section = (IWSubSectionStructrue*)chapOrItem;
        cell = [tableView dequeueReusableCellWithIdentifier:@"SubSectionCell"];
        strTitle = section.strTitle;
//        fFontSize = 18;
        color = [UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1.0];
    }
    else if([chapOrItem isKindOfClass:[IWChapterStructure class]])
    {
        IWChapterStructure *chapter = (IWChapterStructure*)chapOrItem;
        cell = [tableView dequeueReusableCellWithIdentifier:@"ChapterCell"];
        strTitle = chapter.strTitle;
//        fFontSize = 17;
    }
    else if([chapOrItem isKindOfClass:[IWSegmentStructure class]])
    {
        IWSegmentStructure *segment = (IWSegmentStructure*)chapOrItem;
        cell = [tableView dequeueReusableCellWithIdentifier:@"SegmentCell"];
        strTitle = segment.strTitle;
//        fFontSize = 16;
    }
    else if([chapOrItem isKindOfClass:[IWChaterItemStructure class]])
    {
        IWChaterItemStructure *chapter = (IWChaterItemStructure*)chapOrItem;
        cell = [tableView dequeueReusableCellWithIdentifier:@"ChapterItemCell"];
        strTitle = chapter.strTitle;
//        fFontSize = 15;
    }
    
    [cell.contentView setBackgroundColor:color];
    UILabel *labelTitle = (UILabel*)[cell viewWithTag:201];
    labelTitle.text = strTitle;
    labelTitle.font = [UIFont fontWithName:FONT_TITLE_REGULAR size:[IWUtility getNumberAsPerScalingFactor:fFontSize]];
    
    return cell;
}




-(NSArray *)getChaptersAndItemsFromChapterArray:(NSArray*) arrChapters
{
    NSMutableArray *arrChapAndItems = [[NSMutableArray alloc] init];
    
    for(IWChapterStructure *chap in arrChapters)
    {
        [arrChapAndItems addObject:chap];
        
        /* Hide chapter segments and items as clicking on them will not take to that location in chapter
        
        if(chap.arrChapterSegments && chap.arrChapterSegments.count > 0)
        {
            for (IWSegmentStructure *segment in chap.arrChapterSegments)
            {
                IWSegmentStructure *dummySegment = [[IWSegmentStructure alloc] init];
                dummySegment.strTitle = segment.strTitle;
                dummySegment.strUrl =  segment.strUrl;
                
                [arrChapAndItems addObject:dummySegment];
                
                for(IWChaterItemStructure *chapItem in segment.arrItems)
                {
                    [arrChapAndItems addObject:chapItem];
                }
            }
        }
        else if(chap.arrChapterItems && chap.arrChapterItems.count > 0)
        {
            for(IWChaterItemStructure *chapItem in chap.arrChapterItems)
            {
                [arrChapAndItems addObject:chapItem];
            }
        }
         
         */
    }
    
    return [arrChapAndItems copy];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [IWUtility getNumberAsPerScalingFactor:40];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id chapOrItem;
    
    if(_detailVolumeStructure.arrBooks && _detailVolumeStructure.arrBooks > 0)
    {
        IWBookStructure *book = [_detailVolumeStructure.arrBooks objectAtIndex:indexPath.section];
        NSArray *arrChapAndItem = [book getChaptersAndItemsFromBookArray];
        chapOrItem = [arrChapAndItem objectAtIndex:indexPath.row];
    }
    else if(_detailVolumeStructure.arrParts && _detailVolumeStructure.arrParts > 0)
    {
        IWPartStructure *part = [_detailVolumeStructure.arrParts objectAtIndex:indexPath.section];
        NSArray *arrChapAndItem = [part getChaptersAndItemsFromPartArray];
        chapOrItem = [arrChapAndItem objectAtIndex:indexPath.row];
    }
    else if(_detailVolumeStructure.arrChapters && _detailVolumeStructure.arrChapters > 0)
    {
        chapOrItem = [self getChaptersAndItemsFromChapterArray:_detailVolumeStructure.arrChapters];
    }
    
//    if([chapOrItem isKindOfClass:[IWPartStructure class]])
//        return [IWUtility getNumberAsPerScalingFactor:35];
//    
//    if([chapOrItem isKindOfClass:[IWSectionStructure class]])
//        return [IWUtility getNumberAsPerScalingFactor:30];
//    
//    if([chapOrItem isKindOfClass:[IWSubSectionStructrue class]])
//        return [IWUtility getNumberAsPerScalingFactor:25];
//    
//    if([chapOrItem isKindOfClass:[IWSegmentStructure class]])
//        return [IWUtility getNumberAsPerScalingFactor:40];
    
    return [IWUtility getNumberAsPerScalingFactor:40];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *strTitle = @"";
    
    if(_detailVolumeStructure.arrBooks && _detailVolumeStructure.arrBooks > 0)
    {
        IWBookStructure *book = [_detailVolumeStructure.arrBooks objectAtIndex:section];
        strTitle = book.strTitle;
    }
    else if(_detailVolumeStructure.arrParts && _detailVolumeStructure.arrParts)
    {
        IWPartStructure *part = [_detailVolumeStructure.arrParts objectAtIndex:section];
        strTitle = part.strTitle;
    }
        
    return strTitle;
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self selectedItemAtIndex:indexPath];
}

-(void)selectedItemAtIndex:(NSIndexPath *)indexPath
{
    [self.navigationController setNavigationBarHidden: NO animated:YES];
    
    id chapOrItem;
    
    if(_detailVolumeStructure.arrBooks && _detailVolumeStructure.arrBooks > 0)//Volumes has books
    {
        IWBookStructure *book = [_detailVolumeStructure.arrBooks objectAtIndex:indexPath.section];
        NSArray *arrChapAndItem = [book getChaptersAndItemsFromBookArray];
        chapOrItem = [arrChapAndItem objectAtIndex:indexPath.row];
    }
    else if(_detailVolumeStructure.arrParts && _detailVolumeStructure.arrParts > 0)//Volume has parts
    {
        IWPartStructure *part = [_detailVolumeStructure.arrParts objectAtIndex:indexPath.section];
        NSArray *arrChapAndItem = [part getChaptersAndItemsFromPartArray];
        chapOrItem = [arrChapAndItem objectAtIndex:indexPath.row];
    }
    else if(_detailVolumeStructure.arrChapters && _detailVolumeStructure.arrChapters > 0)//Volume has direct chapters
    {
        chapOrItem = [self getChaptersAndItemsFromChapterArray:_detailVolumeStructure.arrChapters];
    }
    
    NSString *strUrl = nil;
    int iItemIndex = 0;
    
    if([chapOrItem isKindOfClass:[IWSectionStructure class]] ||
       [chapOrItem isKindOfClass:[IWSubSectionStructrue class]]||
       [chapOrItem isKindOfClass:[IWPartStructure class]] ||
       [chapOrItem isKindOfClass:[IWSegmentStructure class]] )
    {
        //Do nothing
    }
    if([chapOrItem isKindOfClass:[IWChapterStructure class]])
    {
        IWChapterStructure *chapter = (IWChapterStructure*)chapOrItem;
        strUrl = chapter.strUrl;
    }
    else if([chapOrItem isKindOfClass:[IWChaterItemStructure class]])
    {
        IWChaterItemStructure *chapterItem = (IWChaterItemStructure*)chapOrItem;
        strUrl = chapterItem.strUrlParentChapter;
        iItemIndex = chapterItem.iItemIndex;
    }
    
    if(strUrl)
    {
        [[IWUserActionManager sharedManager] showChapterWithPath:[NSString stringWithFormat:@"%@/%@",_strVolumePath,strUrl]
                                                    andItemIndex:iItemIndex];
        [self.navigationController popViewControllerAnimated:YES];

    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat fLeadingSpace = 0.0;
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, fLeadingSpace, 0, 0)];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.textColor = COLOR_SECTION_HEADER_TITLE;
    header.textLabel.font = [UIFont fontWithName:FONT_TITLE_REGULAR size:[IWUtility getNumberAsPerScalingFactor:18]];
    BOOL bHasBooks = _detailVolumeStructure.arrBooks.count > 0 ? YES : NO;
    
    header.backgroundView.backgroundColor = bHasBooks ? [UIColor blackColor] : COLOR_SECTION_HEADER;
    header.textLabel.textAlignment = NSTextAlignmentCenter;
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
    [self updateUIForOrientationChange];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [self updateUIForOrientationChange];
}

-(void)updateUIForOrientationChange
{
    dispatch_async(dispatch_get_main_queue(),
   ^{
       [self setHeaderView];
       _constraintHorizontalSpaceBtnsBackNext.constant = [IWUtility getHorizontalSpaceBetweenButtons];
   });
}

@end
