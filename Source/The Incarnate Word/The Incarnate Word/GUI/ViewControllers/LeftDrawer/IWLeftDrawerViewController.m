//
//  IWLeftDrawerViewController.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWLeftDrawerViewController.h"
#import "IWUserActionManager.h"
#import "IWUtility.h"
#import "IWUIConstants.h"
#import "IWSearchItemStructure.h"
#import "IWSearchWebService.h"
#import "IWSearchStructure.h"

#define MENU_TITLE  @"MENU_TITLE"
#define MENU_ARRAY  @"MENU_ARRAY"

#define TAG_OFFSET_SECTION_HEADER_BUTTON    200
#define HEIGHT_SEARCH_RESULT_VIEW           20
#define HEIGHT_LOADING_MORE_ITEM_VIEW       20

@interface IWLeftDrawerViewController()<UITableViewDataSource,UITableViewDelegate,WebServiceDelegate>
{
    NSArray                 *_arrDataSource;
    UISearchBar             *_searchBar;
    BOOL                    _bIsKeyboardShown;
    IWSearchWebService      *_searchWebService;
    NSMutableArray          *_arrSearchResult;
    BOOL                    _bIsSearchOn;
    NSString                *_strSearchString;
    BOOL                    _bSearchRequestIsInProgress;
    int                     _iTotalNumberOfRecords;
    
    BOOL                    _bShouldFlipHorizontally;
    NSTimer                 *_timerLoading;
    
}

@property (weak, nonatomic) IBOutlet UITableView            *tableViewMenu;
@property (weak, nonatomic) IBOutlet UIView                 *viewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *constraintTableViewBottom;
@property (weak, nonatomic) IBOutlet UIView                 *viewLoading;
@property (weak, nonatomic) IBOutlet UILabel                *lblCount;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *constraintViewSearchResultHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *constraintViewLoadingMoreItemHeight;

-(void)setupDataSource;
-(void)setupSearchBar;

@end

@implementation IWLeftDrawerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupDataSource];
    [self setupUI];
    [self registerNotifications];
    
}

-(void)setupDataSource
{
    NSMutableDictionary *dict0 = [[NSMutableDictionary alloc] init];
    [dict0 setObject:@"" forKey:MENU_TITLE];
    [dict0 setObject:[[NSArray alloc] initWithObjects:@"Home",nil] forKey:MENU_ARRAY];
    
    NSMutableDictionary *dict1 = [[NSMutableDictionary alloc] init];
    [dict1 setObject:@"Sri Aurobindo" forKey:MENU_TITLE];
    [dict1 setObject:[[NSArray alloc] initWithObjects:@"About",@"Birth Centenary Library",@"Complete Works", nil] forKey:MENU_ARRAY];
    
    NSMutableDictionary *dict2 = [[NSMutableDictionary alloc] init];
    [dict2 setObject:@"The Mother" forKey:MENU_TITLE];
    [dict2 setObject:[[NSArray alloc] initWithObjects:@"About",@"Collected Works",@"Agenda", nil] forKey:MENU_ARRAY];
    
    NSMutableDictionary *dict3 = [[NSMutableDictionary alloc] init];
    [dict3 setObject:@"Dictionary" forKey:MENU_TITLE];
    [dict3 setObject:[[NSArray alloc] initWithObjects:@"Entries", nil] forKey:MENU_ARRAY];
    
    NSMutableDictionary *dict4 = [[NSMutableDictionary alloc] init];
    [dict4 setObject:@"Offline" forKey:MENU_TITLE];
    [dict4 setObject:[[NSArray alloc] initWithObjects:@"Chapters", nil] forKey:MENU_ARRAY];


    _arrDataSource = [[NSArray alloc] initWithObjects:[dict0 copy],[dict1 copy],[dict2 copy],[dict3 copy],[dict4 copy], nil];
}

-(void)setupUI
{
    _viewLoading.layer.cornerRadius = 3.0;
    _viewLoading.backgroundColor = COLOR_LOADING_VIEW;
    
    _constraintViewSearchResultHeight.constant = 0;
    _constraintViewLoadingMoreItemHeight.constant = 0;
    
    _tableViewMenu.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view setBackgroundColor:COLOR_VIEW_BG];
    [self setupSearchBar];
    [self addKeyboardNotifications];

}


-(void)updateTableContent
{
    if(_bIsSearchOn)
    {
        _constraintViewSearchResultHeight.constant = HEIGHT_SEARCH_RESULT_VIEW;
        
        if(_iTotalNumberOfRecords != 0)
        {
        
            _lblCount.text = [NSString stringWithFormat:@"%lu of %d results",
                              (unsigned long)_arrSearchResult.count,
                              _iTotalNumberOfRecords];
        }
        else
        {
            _lblCount.text = @"";
        }
    }
    else
    {
        _constraintViewSearchResultHeight.constant = 0;
    }
    [_tableViewMenu reloadData];
}

-(void)clearSearchData
{
    _iTotalNumberOfRecords = 0;
    [_arrSearchResult removeAllObjects];
    _strSearchString = @"";
}

-(void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notifLeftDrawerClosed:)
                                                 name:NOTIF_LEFT_DRAWER_CLOSED
                                               object:nil];
}

-(void)notifLeftDrawerClosed:(NSNotification*) notification
{
    _bIsSearchOn = NO;
    [self updateTableContent];
}

-(void)setupSearchBar
{
    //Cleanup for orientation re adding of view
    _searchBar.delegate = nil;
    [_searchBar removeFromSuperview];
    _searchBar = nil;
    
    UIColor *searchBarColor = [UIColor colorWithRed:199.0/255 green:201.0/255 blue:207.0/255 alpha:1.0];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, [IWUtility getDrawerWidth], 44)];
    _searchBar.placeholder = @"Search";
    _searchBar.translucent = YES;
    _searchBar.delegate = self;
    _searchBar.showsCancelButton = NO;
    
    //Background color
    _searchBar.barTintColor = searchBarColor;
    
    //Remove border
    _searchBar.layer.borderWidth = 1;
    _searchBar.layer.borderColor = searchBarColor.CGColor;
    //_searchBar.searchBarStyle = UISearchBarStyleProminent;//Removes border
    
    //Cursor color
    [[UITextField appearanceWhenContainedIn: [UISearchBar class], nil] setTintColor:[UIColor blackColor]];
    
    //Cancel button text color
    [[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                  [UIColor blackColor],
                                                                                                  NSForegroundColorAttributeName,
                                                                                                  nil]
                                                                                        forState:UIControlStateNormal];
    //Placeholder text color
    [[UILabel appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor darkGrayColor]];
    
    //Text Field Bg Color
    //[[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setBackgroundColor:[UIColor whiteColor]];
    
    [_viewTop addSubview:_searchBar];
    _viewTop.backgroundColor = searchBarColor;
}


- (void) addKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark - Keyboard notification methods

-(void)keyboardWillShow:(NSNotification *)notification
{
    [_searchBar setShowsCancelButton:YES animated:YES];

    _bIsKeyboardShown = YES;
    [self.navigationController setNavigationBarHidden: YES animated:YES];
    
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    float keyboardHeight = keyboardFrameBeginRect.size.height ;
    
    _constraintTableViewBottom.constant = keyboardHeight;
//    _constraintVIewTopHeight.constant = 44 + 20;
    CGRect rect = [[UIScreen mainScreen] bounds];
    _searchBar.frame = CGRectMake(0, 0, [IWUtility getDrawerWidth], 44);
    
//    if([IWUtility isNilOrEmptyString:_searchBar.text])
//        [self disableTableInteraction:YES];
    
    [_viewTop layoutIfNeeded];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
//    _searchBar.text = @"";
//    _bIsSearchOn = NO;
//    [_tableViewMenu reloadData];
    
    _bIsKeyboardShown = NO;
    _constraintTableViewBottom.constant = 0;
//    _constraintVIewTopHeight.constant = 44 ;
    CGRect rect = [[UIScreen mainScreen] bounds];
    _searchBar.frame = CGRectMake(0, 0, [IWUtility getDrawerWidth], 44);
//    [self disableTableInteraction:NO];
    [self.navigationController setNavigationBarHidden: NO animated:YES];
    [_viewTop layoutIfNeeded];
}

#pragma mark - UISearchBar Delegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText// called when text changes (including clear)
{
    _bIsSearchOn = YES;
    _constraintViewSearchResultHeight.constant = HEIGHT_SEARCH_RESULT_VIEW;
    
    if(searchText == nil || [searchText isEqualToString:@""])
    {
        [self clearSearchData];
        [self updateTableContent];
    }
}



- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar// called when keyboard search button pressed
{
    [self startLoadingAnimation];
    [_searchBar performSelector: @selector(resignFirstResponder)
                     withObject: nil
                     afterDelay: 0.1];
    
    [self clearSearchData];
    [self updateTableContent];
    [self searchForText:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [_searchBar setShowsCancelButton:NO animated:YES];

    [self stopLoadingAnimation];
    
    _searchBar.text = @"";
    [self searchForText:@""];
    
    [_searchBar performSelector: @selector(resignFirstResponder)
                     withObject: nil
                     afterDelay: 0.1];
    
    [self.view endEditing:YES];

    _bIsSearchOn = NO;
    [self clearSearchData];
    [self updateTableContent];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar*)searchBar
{
    _bIsSearchOn = YES;
    [self updateTableContent];

    [_searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

-(void)searchForText:(NSString *)searchText
{
    NSLog(@"Text : %@",searchText);
    
    if(_arrSearchResult)
    {
        [_arrSearchResult removeAllObjects];
    }
    else
    {
        _arrSearchResult = [[NSMutableArray alloc] init];
    }
    
    if(searchText.length != 0)
    {
        [self getData];
    }
    else
    {
        [self updateTableContent];
    }
}

-(void)getData
{
    _iTotalNumberOfRecords = 0;
    _bSearchRequestIsInProgress = YES;
    _strSearchString = _searchBar.text;
    _searchWebService = [[IWSearchWebService alloc] initWithSearchString:_strSearchString
                                                           AndStartIndex:0
                                                             AndDelegate:self];
    [_searchWebService sendAsyncRequest];
}

-(void)lazyLoadPage
{
    if(_bSearchRequestIsInProgress == NO && _arrSearchResult.count < _iTotalNumberOfRecords)
    {
        _bSearchRequestIsInProgress = YES;
        _constraintViewLoadingMoreItemHeight.constant = HEIGHT_LOADING_MORE_ITEM_VIEW;
        _searchWebService = [[IWSearchWebService alloc] initWithSearchString:_strSearchString
                                                               AndStartIndex:(int)_arrSearchResult.count
                                                                 AndDelegate:self];
        [_searchWebService sendAsyncRequest];
    }
}

#pragma mark - Webservice Callbacks


-(void)requestSucceed:(BaseWebService*)webService response:(id)responseModel
{
    NSLog(@"SearchWebservice Success.");
    
    _bSearchRequestIsInProgress = NO;
    _constraintViewLoadingMoreItemHeight.constant = 0;

    if([responseModel isKindOfClass:[IWSearchStructure class]])
    {
        IWSearchStructure *searchResult = responseModel;
        _iTotalNumberOfRecords = searchResult.iCountRecord;
        
        [_arrSearchResult addObjectsFromArray:searchResult.arrSearchItems];


    }
    else
    {
    
    }
    
    [self updateTableContent];
}

-(void)requestFailed:(BaseWebService*)webService error:(WSError*)error
{
    NSLog(@"SearchWebservice Failed.");
    _bSearchRequestIsInProgress = NO;
    _constraintViewLoadingMoreItemHeight.constant = 0;

    
    [IWUtility showWebserviceFailedAlert];
    
    [self stopLoadingAnimation];
}

#pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _bIsSearchOn ? 1 : _arrDataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 0;
    
    return [IWUtility getNumberAsPerScalingFactor:40.0];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [IWUtility getNumberAsPerScalingFactor:_bIsSearchOn ? 100 : 43.0];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_bIsSearchOn)
    {
        return _arrSearchResult.count;
    }
    else
    {
        NSDictionary *dict = [_arrDataSource objectAtIndex:section];
        NSArray *arr = [dict objectForKey:MENU_ARRAY];
        return arr.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString  *strCellId    = _bIsSearchOn == YES ? @"Cell_Search":@"Cell_Menu";
    UITableViewCell *cell   = [tableView dequeueReusableCellWithIdentifier:strCellId];
    UILabel *lblTitle       = (UILabel*)[cell viewWithTag:201];
    lblTitle.font           = [UIFont fontWithName:FONT_TITLE_REGULAR size:[IWUtility getNumberAsPerScalingFactor:18.0]];

    if([strCellId isEqualToString:@"Cell_Menu"])
    {
        NSDictionary *dict  = [_arrDataSource objectAtIndex:indexPath.section];
        NSArray *arr        = [dict objectForKey:MENU_ARRAY];
        
        NSString *strTitle  = [arr objectAtIndex:indexPath.row];
        lblTitle.text       = strTitle;
    }
    else
    {
        IWSearchItemStructure *searchItem   = [_arrSearchResult objectAtIndex:indexPath.row];
        lblTitle.text = searchItem.strTitle;
        lblTitle.font           = [UIFont fontWithName:FONT_TITLE_REGULAR size:[IWUtility getNumberAsPerScalingFactor:17.0]];

        
        UILabel *lblText    = (UILabel*)[cell viewWithTag:202];
        lblText.font        = [UIFont fontWithName:FONT_TITLE_REGULAR size:[IWUtility getNumberAsPerScalingFactor:16.0]];
        
        NSMutableString *strMut = [[NSMutableString alloc] init];
        
        for(NSString *str in searchItem.arrHighlightText)
        {
            if([str isKindOfClass:[NSNull class]] == NO)
            {
                [strMut appendString:str];
                [strMut appendString:@"... "];
            }
        }
        
        strMut = [[strMut stringByReplacingOccurrencesOfString:@"<em>" withString:@""] mutableCopy];
        strMut = [[strMut stringByReplacingOccurrencesOfString:@"</em>" withString:@""] mutableCopy];
        
        lblText.attributedText = [IWUtility getMarkdownNSAttributedStringFromNSString:[strMut copy]];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL bIsLastRow = NO;
    
    NSDictionary *dict = [_arrDataSource objectAtIndex:indexPath.section];
    
    if([_arrDataSource lastObject] == dict)
    {
        NSArray *arr = [dict objectForKey:MENU_ARRAY];
        
        if( (arr.count -1) == indexPath.row)
        {
            bIsLastRow = YES;
        }
    }
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, bIsLastRow ? 1000 :0, 0, 0)];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row)
    {
        //end of loading
        [self stopLoadingAnimation];
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect rect = CGRectMake(0, 0, [IWUtility getDrawerWidth], [IWUtility getNumberAsPerScalingFactor:40.0]);
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    NSDictionary *dict = [_arrDataSource objectAtIndex:section];
    [btn setTitle:[dict objectForKey:MENU_TITLE] forState:UIControlStateNormal];
    [btn setFrame:rect];
    [btn setTag:TAG_OFFSET_SECTION_HEADER_BUTTON + section];
    [btn addTarget:self action:@selector(sectionTapped:) forControlEvents:UIControlEventTouchUpInside];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [btn.titleLabel setFont:[UIFont fontWithName:FONT_TITLE_REGULAR size:[IWUtility getNumberAsPerScalingFactor:21.0]]];
    [btn setTitleColor:COLOR_SECTION_HEADER_TITLE forState:UIControlStateNormal];
    UIView *aView =[[UIView alloc] initWithFrame:rect];
    aView.backgroundColor = section == 0 ? [UIColor lightGrayColor]:COLOR_SECTION_HEADER;//[UIColor colorWithRed:20.0/255 green:15.0/255 blue:5.0/255 alpha:1.0];
    [aView addSubview:btn];

    return aView;
}

- (IBAction)sectionTapped:(id)sender
{
//    UIButton *btn = (UIButton*)sender;
//    int sectionIndex = (int)btn.tag - TAG_OFFSET_SECTION_HEADER_BUTTON;
//    NSLog(@"Section : %d",sectionIndex);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if(_bIsSearchOn)
    {
        if([_searchBar isFirstResponder])
            [_searchBar resignFirstResponder];
        
        _bIsSearchOn = NO;
        
        [self updateTableContent];
        
        IWSearchItemStructure *searchItem = [_arrSearchResult objectAtIndex:indexPath.row];
        [[IWUserActionManager sharedManager] showChapterWithPath:searchItem.strChapterUrl andItemIndex:0];
        
        
    }
    else
    {
        if(indexPath.section == 0)
        {
            if(indexPath.row == 0)
            {
                [[IWUserActionManager sharedManager] showHomeScreen];
            }
        }
        else if(indexPath.section == 1)
        {
            if(indexPath.row == 0)
            {
                [[IWUserActionManager sharedManager] showAboutWithPath:@"sa" andImageName:@"aurobindo.jpg" andDescriptionHeight:682];
            }
            else if(indexPath.row == 1)
            {
                [[IWUserActionManager sharedManager] showCompilationWithPath:@"sabcl" andForceOnRoot:YES];
            }
            else if(indexPath.row == 2)
            {
                [[IWUserActionManager sharedManager] showCompilationWithPath:@"cwsa" andForceOnRoot:YES];
            }
        }
        else if(indexPath.section == 2)
        {
            if(indexPath.row == 0)
            {
                [[IWUserActionManager sharedManager] showAboutWithPath:@"m" andImageName:@"theMother.jpg" andDescriptionHeight:751];
            }
            else if(indexPath.row == 1)
            {
                [[IWUserActionManager sharedManager] showCompilationWithPath:@"cwm" andForceOnRoot:YES];
            }
            else if(indexPath.row == 2)
            {
                [[IWUserActionManager sharedManager] showCompilationWithPath:@"agenda" andForceOnRoot:YES];
            }
        }
        else if(indexPath.section == 3)
        {
            if(indexPath.row == 0)
            {
                [[IWUserActionManager sharedManager] showDictionary];
            }
        }
        else if(indexPath.section == 4)
        {
            if(indexPath.row == 0)
            {
                [[IWUserActionManager sharedManager] showOfflineChapters];
            }
        }
    }
}


#pragma mark - Loading Animation

-(void)startLoadingAnimation
{
    _viewLoading.hidden = NO;
    _timerLoading = [NSTimer scheduledTimerWithTimeInterval: 0.6
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
                      duration: 0.4
                       options: _bShouldFlipHorizontally ?  UIViewAnimationOptionTransitionFlipFromRight : UIViewAnimationOptionTransitionFlipFromBottom
                    animations:^{
                    }
                    completion:^(BOOL finished) {
                        
                        _bShouldFlipHorizontally = ! _bShouldFlipHorizontally;
                    }
     ];
}

#pragma mark - ScrollView Delegate

-(void)scrollViewDidScroll: (UIScrollView*)scrollView
{
    if(_bIsSearchOn)
    {
        float scrollViewHeight = scrollView.frame.size.height;
        float scrollContentSizeHeight = scrollView.contentSize.height;
        float scrollOffset = scrollView.contentOffset.y;
        
        if (scrollOffset == 0)//Top
        {
        }
        else if (scrollOffset + scrollViewHeight == scrollContentSizeHeight)//Bottom
        {
            [self lazyLoadPage];
        }
    }
}

@end
