//
//  IWCompilationViewController.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWCompilationViewController.h"
#import "IWCompilationWebService.h"
#import "IWCompilationStructure.h"
#import "IWVolumeStructure.h"
#import "IWUserActionManager.h"
#import "IWUIConstants.h"
#import "IWUtility.h"



@interface IWCompilationViewController ()<WebServiceDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    IWCompilationWebService             *_compilationWebService;
    IWCompilationStructure              *_compilation;
    
//    CGFloat                             _fTopViewHeight;
    
    BOOL                                _bShouldFlipHorizontally;
    NSTimer                             *_timerLoading;
//    UITapGestureRecognizer              *_tapGestureOnDummyScrollView;

}

@property (nonatomic, assign) CGFloat lastContentOffset;

@property (weak, nonatomic) IBOutlet UITableView                *tableViewVolumeList;
@property (weak, nonatomic) IBOutlet UIView                     *viewVolume;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *constraintViewVolumeTopSpace;
@property (weak, nonatomic) IBOutlet UIView                     *viewLoading;
@property (weak, nonatomic) IBOutlet UIView                     *viewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint         *constraintTopViewHeight;
@property (weak, nonatomic) IBOutlet UILabel                    *lblTop;
//@property (weak, nonatomic) IBOutlet UIScrollView               *scrollViewTop;

-(void)setupUI;
-(void)getData;
-(void)updateUI;

@end

@implementation IWCompilationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    [self getData];
}

-(void)setupUI
{
    _viewLoading.layer.cornerRadius = 3.0;
    _viewLoading.backgroundColor = COLOR_LOADING_VIEW;
    
    self.view.backgroundColor = COLOR_VIEW_BG;
    _viewVolume.backgroundColor = COLOR_VIEW_BG;
    
    _viewVolume.hidden = YES;
    self.navigationItem.title = @"Loading...";
    _tableViewVolumeList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view sendSubviewToBack:_viewTop];
//    _fTopViewHeight = _constraintTopViewHeight.constant;
    _constraintViewVolumeTopSpace.constant = 0;
    _constraintTopViewHeight.constant = 0;
    [self startLoadingAnimation];
//    [self setupDummyScrollView];
}
/*
-(void)setupDummyScrollView
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.size.height = rect.size.height + _constraintTopViewHeight.constant - 20 - 44;
    [_scrollViewTop setContentSize:rect.size];
    _scrollViewTop.delegate =  self;
    _scrollViewTop.showsHorizontalScrollIndicator = NO;
    _scrollViewTop.showsVerticalScrollIndicator = NO;
    
    
    _tapGestureOnDummyScrollView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnDummyScrollView:)];
    [_scrollViewTop addGestureRecognizer:_tapGestureOnDummyScrollView];
}


- (void) handleTapOnDummyScrollView: (UITapGestureRecognizer *)recognizer
{
    NSIndexPath* indexPath = [_tableViewVolumeList indexPathForRowAtPoint:[recognizer locationInView:_tableViewVolumeList]];
    [self selectedItemAtIndex:indexPath.row];
}
 
 */

-(void)getData
{
    _compilationWebService = [[IWCompilationWebService alloc] initWithPath:_strCompilationPath AndDelegate:self];
    [_compilationWebService sendAsyncRequest];
}

#pragma mark - Webservice Callbacks


-(void)requestSucceed:(BaseWebService*)webService response:(id)responseModel
{
    NSLog(@"CompilationWebService Success.");
    _compilation = (IWCompilationStructure*)responseModel;
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
    self.navigationItem.title = _compilation.strAuthName;
    
    if(_compilation.arrVolumes.count > 0)
    {
        _viewVolume.hidden = NO;
        [_tableViewVolumeList reloadData];
    }
    
    [self stopLoadingAnimation];
    
//    _lblTop.font  = [UIFont fontWithName:FONT_TITLE_REGULAR size:19];
//    _lblTop.text = _compilation.strTitle;
    
    [self setHeaderView];
}


-(void)setHeaderView
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 70)];
    headerView.backgroundColor = [UIColor darkGrayColor];
    UILabel *label = [[UILabel alloc] initWithFrame:headerView.bounds];
    label.font  = [UIFont fontWithName:FONT_TITLE_REGULAR size:19];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = _compilation.strTitle;
    label.textColor = [UIColor whiteColor];
    [headerView addSubview:label];
    _tableViewVolumeList.tableHeaderView = headerView;
}

#pragma mark - Table View Datasource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _compilation.arrVolumes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VolumeCell"];
    UILabel *labelTitle = (UILabel*)[cell viewWithTag:501];
    IWVolumeStructure *volume = [_compilation.arrVolumes objectAtIndex:indexPath.row];
    
    UIFont *font = [UIFont fontWithName:FONT_TITLE_REGULAR size:18];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                forKey:NSFontAttributeName];
    
    NSString *stringSeparatorFormat = @" / ";
    NSString *finalString = [NSString stringWithFormat:@"%@%@%@",volume.strIndex,stringSeparatorFormat,volume.strTitle];
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:finalString attributes:attrsDictionary];
    UIColor *colorIndexString = [UIColor colorWithRed:18.0/255 green:107.0/255 blue:169.0/255 alpha:1.0];
    [attributedString addAttribute:NSForegroundColorAttributeName value:colorIndexString range:NSMakeRange(0,volume.strIndex.length+stringSeparatorFormat.length)];
    
    labelTitle.attributedText = attributedString;

    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self selectedItemAtIndex:indexPath.row];
}

-(void)selectedItemAtIndex:(NSInteger)index
{
    [self.navigationController setNavigationBarHidden: NO animated:YES];
    IWVolumeStructure *volume = [_compilation.arrVolumes objectAtIndex:index];
    [[IWUserActionManager sharedManager] showVolumeWithPath:[NSString stringWithFormat:@"%@",volume.strUrl]];
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
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


#pragma mark - Scrollview Delegate


/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float           fTopViewHeight  = _fTopViewHeight;
    UIScrollView *scrollViewBottom  = (UIScrollView*)_tableViewVolumeList;
    UIScrollView *scrollViewDummy   = _scrollViewTop;
    
    if(scrollView == scrollViewDummy)
    {
        if(scrollView.contentOffset.y <= fTopViewHeight -1 )
        {
            _constraintViewVolumeTopSpace.constant = fTopViewHeight - scrollView.contentOffset.y;
            [scrollViewBottom setContentOffset:CGPointMake(0, 0)];
        }
        else
        {
            _constraintViewVolumeTopSpace.constant = 0;
            scrollViewDummy.userInteractionEnabled = NO;
            self.lastContentOffset = 0;
            [scrollViewBottom setContentOffset:CGPointMake(0, 1)];
        }
    }
    else
    {
        if (self.lastContentOffset > scrollView.contentOffset.y)
        {
            [self hideNavigationBar:NO];//up
            
            if( scrollView.contentOffset.y == 0)
            {
                scrollViewDummy.userInteractionEnabled = YES;
            }
        }
        else
        {
            [self hideNavigationBar:YES];//down
            
            if(_constraintViewVolumeTopSpace.constant > 0 || scrollView.contentOffset.y == 0)
            {
                scrollViewDummy.userInteractionEnabled = YES;
                [scrollViewBottom setContentOffset:CGPointMake(0, 0)];
            }
        }
        
        self.lastContentOffset = scrollView.contentOffset.y;
    }
}

-(void)hideNavigationBar:(BOOL) bShouldHide
{
    return;
    
    if(self.navigationController.navigationBar.hidden == NO && bShouldHide == YES )
    {
        [self.navigationController setNavigationBarHidden: bShouldHide animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:bShouldHide];

    }
    else if (self.navigationController.navigationBar.hidden == YES && bShouldHide == NO)
    {
        [self.navigationController setNavigationBarHidden: bShouldHide animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:bShouldHide];
    }
}

 */

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

@end
