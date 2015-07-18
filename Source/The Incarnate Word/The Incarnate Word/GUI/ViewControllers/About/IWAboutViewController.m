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



@interface IWAboutViewController ()<WebServiceDelegate,UITableViewDataSource,UITableViewDelegate>
{
    IWAboutWebService       *_aboutWebService;
    IWAboutStructure        *_aboutDataStructure;
    
    BOOL                    _bShouldFlipHorizontally;
    NSTimer                 *_timerLoading;
    float                   _fImageViewHeight;
    NSNumber                *_rowHeight;
}

@property (nonatomic, assign) CGFloat lastContentOffset;


@property (weak, nonatomic) IBOutlet UIView                     *viewLoading;
@property (weak, nonatomic) IBOutlet UIView                     *viewMiddle;
@property (weak, nonatomic) IBOutlet UITableView                *tableView;



-(void)setupUI;
-(void)getData;
-(void)updateUI;


@end

@implementation IWAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    [self getData];
}

-(void)setupUI
{
    self.view.backgroundColor = COLOR_VIEW_BG;
    
//    _fImageViewHeight = _constraintImageViewHeight.constant;
//    _constraintViewMiddleTopSpace.constant = _fImageViewHeight;
    
    self.navigationItem.title = @"Loading...";
    _viewLoading.layer.cornerRadius = 3.0;
    _viewLoading.backgroundColor = COLOR_LOADING_VIEW;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

//    [self.view bringSubviewToFront:_viewMiddle];
    [self startLoadingAnimation];
//    [self setupDummyScrollView];
}


/*
-(void)setupDummyScrollView
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.size.height = rect.size.height + _constraintImageViewHeight.constant - 20 - 44;
    [_scrollViewTop setContentSize:rect.size];
    _scrollViewTop.delegate =  self;
    _scrollViewTop.showsHorizontalScrollIndicator = NO;
    _scrollViewTop.showsVerticalScrollIndicator = NO;
}
*/

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
//    _imageViewAuther.image = [UIImage imageNamed:_strImageName];
//    _imageViewAuther.hidden = NO;
//    [self addMarkdownView];
    
    self.navigationItem.title = _aboutDataStructure.strDescriptionTitle;

    
    [self stopLoadingAnimation];
    
    
    [_tableView reloadData];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 190)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:headerView.bounds];
    [headerView addSubview:imageView];
    imageView.image = [UIImage imageNamed:_strImageName];
    self.tableView.tableHeaderView = headerView;
}




#pragma mark - UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _aboutDataStructure == nil ? 0 : 1 ;
}





- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AboutCell" forIndexPath:indexPath];
    
    
    UILabel *lbl =  (UILabel*)[cell viewWithTag:201];
    
   
    NSString *strFinal = [_aboutDataStructure.strDescription stringByReplacingOccurrencesOfString:@"\n---\n" withString:@"\n"];
    lbl.text = strFinal;
    
    indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    
    CGSize cellSize = [cell systemLayoutSizeFittingSize:CGSizeMake(320, 0) withHorizontalFittingPriority:1000.0 verticalFittingPriority:50.0];
    _rowHeight = [NSNumber numberWithFloat:cellSize.height];
    
    return cell;
}



#pragma mark - UITableViewDelegate




- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    return [_rowHeight floatValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
/*
-(void)addMarkdownView
{
//    _markdownView  = [IWUtility getMarkdownViewOfFrame:[self getMarkdownRect]];
//    [_viewMiddle addSubview:_markdownView];
//    _markdownView.delegate = self;
//    [_markdownView setMarkdown:_aboutDataStructure.strDescription];
    NSString *strFinal = [_aboutDataStructure.strDescription stringByReplacingOccurrencesOfString:@"\n---\n" withString:@"\n"];
    
    UIFont *font = [UIFont fontWithName:FONT_BODY_REGULAR size:18];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:strFinal attributes:attrsDictionary];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    [attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [strFinal length])];
    
    
    
    
    _textView.delegate = self;
    _textView.attributedText = attrString;//[IWUtility getMarkdownNSAttributedStringFromNSString:strFinal];
}

#pragma mark - Scrollview Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    float           fTopViewHeight  = _fImageViewHeight;
    UIScrollView *scrollViewBottom  = (UIScrollView*)_textView;
    UIScrollView *scrollViewDummy   = _scrollViewTop;
    
    if(scrollView == scrollViewDummy)
    {
        if(scrollView.contentOffset.y <= fTopViewHeight -1 )
        {
            _constraintViewMiddleTopSpace.constant = fTopViewHeight - scrollView.contentOffset.y;
            [scrollViewBottom setContentOffset:CGPointMake(0, 0)];
        }
        else
        {
            _constraintViewMiddleTopSpace.constant = 0;
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
            
            if(_constraintViewMiddleTopSpace.constant > 0 || scrollView.contentOffset.y == 0)
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

-(CGRect)getMarkdownRect
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGRect markdownRect = CGRectMake(0,
                                     0,
                                     screenWidth ,
                                     screenHeight - 44 -_fImageViewHeight - 20 );
    
    return markdownRect;
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
