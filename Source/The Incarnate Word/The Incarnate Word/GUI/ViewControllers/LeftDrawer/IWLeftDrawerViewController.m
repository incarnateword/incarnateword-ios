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

#define MENU_TITLE @"MENU_TITLE"
#define MENU_ARRAY @"MENU_ARRAY"
#define TAG_OFFSET_SECTION_HEADER_BUTTON 200

@interface IWLeftDrawerViewController()<UITableViewDataSource,UITableViewDelegate,WebServiceDelegate>
{
    NSArray                 *_arrDataSource;
    UISearchBar             *_searchBar;
    BOOL                    _bIsKeyboardShown;
    IWSearchWebService      *_searchWebService;
    NSMutableArray          *_arrSearchResult;
    BOOL                    _bIsSearchOn;
    
}

@property (weak, nonatomic) IBOutlet UITableView            *tableViewMenu;
@property (weak, nonatomic) IBOutlet UIView                 *viewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *constraintTableViewBottom;

-(void)setupDataSource;
-(void)setupSearchBar;

@end

@implementation IWLeftDrawerViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupDataSource];
    [self setupUI];
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

    _arrDataSource = [[NSArray alloc] initWithObjects:[dict0 copy],[dict1 copy],[dict2 copy],[dict3 copy], nil];
}

-(void)setupUI
{
    _tableViewMenu.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view setBackgroundColor:COLOR_VIEW_BG];
    [self setupSearchBar];
    [self addKeyboardNotifications];

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
    _searchBar.text = @"";
    _bIsSearchOn = NO;
    [_tableViewMenu reloadData];
    
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
    [_tableViewMenu reloadData];
    
    [self searchForText:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar// called when keyboard search button pressed
{
    [self searchForText:searchBar.text];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _searchBar.text = @"";
    [self searchForText:@""];
    
    [_searchBar performSelector: @selector(resignFirstResponder)
                     withObject: nil
                     afterDelay: 0.1];
    
    [self.view endEditing:YES];

    _bIsSearchOn = NO;
    [_tableViewMenu reloadData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar*)searchBar
{
    [_searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

-(void)searchForText:(NSString *)searchText
{
    NSLog(@"Text : %@",searchText);
    
    [_searchBar setShowsCancelButton:YES animated:YES];
    
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
        [_tableViewMenu reloadData];
    }
}

-(void)getData
{
    _searchWebService = [[IWSearchWebService alloc] initWithDelegate:self];
    [_searchWebService sendAsyncRequest];
}

#pragma mark - Webservice Callbacks


-(void)requestSucceed:(BaseWebService*)webService response:(id)responseModel
{
    NSLog(@"SearchWebservice Success.");

    if([responseModel isKindOfClass:[NSArray class]])
    {
        [_arrSearchResult addObjectsFromArray:responseModel];
    }
    
    [_tableViewMenu reloadData];
}

-(void)requestFailed:(BaseWebService*)webService error:(WSError*)error
{
    NSLog(@"SearchWebservice Failed.");
    [IWUtility showWebserviceFailedAlert];
}

#pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _bIsSearchOn ? 0 : _arrDataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 0;
    
    return [IWUtility getNumberAsPerScalingFactor:40.0];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [IWUtility getNumberAsPerScalingFactor:_bIsSearchOn ? 150 : 43.0];

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_Menu"];
    UILabel *label = (UILabel*)[cell viewWithTag:201];
    
    
    
    
    label.font = [UIFont fontWithName:FONT_TITLE_REGULAR size:[IWUtility getNumberAsPerScalingFactor:18.0]];
    
    NSDictionary *dict = [_arrDataSource objectAtIndex:indexPath.section];
    NSArray *arr = [dict objectForKey:MENU_ARRAY];
    
    NSString *strTitle = [arr objectAtIndex:indexPath.row];
    label.text = strTitle;
    
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
    }
}


@end
