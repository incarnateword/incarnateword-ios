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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    [self getData];
}

-(void)setupUI
{
    self.view.backgroundColor = COLOR_VIEW_BG;
    self.navigationItem.title = @"Loading...";
    _viewLoading.layer.cornerRadius = 3.0;
    _viewLoading.backgroundColor = COLOR_LOADING_VIEW;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self startLoadingAnimation];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _aboutDataStructure == nil ? 0 : 1 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AboutCell" forIndexPath:indexPath];
    UILabel *lbl =  (UILabel*)[cell viewWithTag:201];
   
    NSString *strFinal = [_aboutDataStructure.strDescription stringByReplacingOccurrencesOfString:@"\n---\n" withString:@"\n"];
    UIFont *font = [UIFont fontWithName:FONT_BODY_REGULAR size:18];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                forKey:NSFontAttributeName];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:strFinal attributes:attrsDictionary];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    [attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [strFinal length])];
    lbl.attributedText = attrString;
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

@end
