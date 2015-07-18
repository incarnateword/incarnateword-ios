//
//  IWDictionaryViewController.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 30/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWDictionaryViewController.h"
#import "IWAlphabetStructure.h"
#import "IWWordStructure.h"
#import "IWDictionaryWebService.h"
#import "IWUtility.h"
#import "IWUserActionManager.h"
#import "IWUIConstants.h"
#import "IWUIConstants.h"

@interface IWDictionaryViewController ()<WebServiceDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    NSArray                     *_arrOfAlphabets;
    NSArray                     *_arrOfAlphabetsCopy;
    NSArray                     *_arrSliderAlphabets;
    NSArray                     *_arrSliderAlphabetsCopy;

    IWDictionaryWebService      *_dictionaryWebService;
    UISearchBar                 *_searchBar;
    
    BOOL                        _bShouldFlipHorizontally;
    NSTimer                     *_timerLoading;
    BOOL                        _bSearchClearTextCrossBtnClicked;
    BOOL                        _bIsKeyboardShown;
}

@property (weak, nonatomic) IBOutlet UITableView            *tableViewWordList;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *constraintTableViewBottom;
@property (weak, nonatomic) IBOutlet UIView                 *viewLoading;
@property (weak, nonatomic) IBOutlet UIView                 *viewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *constraintVIewTopHeight;


-(void)setupVC;
-(void)setupUI;
-(void)getData;
-(void)updateUI;
-(void)setupSearchBar;

-(void)keyboardWillShow:(NSNotification *)notification;
-(void)keyboardWillHide:(NSNotification *)notification;

@end

@implementation IWDictionaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    _viewLoading.layer.cornerRadius = 3.0;
    _viewLoading.backgroundColor = COLOR_LOADING_VIEW;

    _tableViewWordList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableViewWordList.sectionIndexColor = [UIColor darkGrayColor];
    _tableViewWordList.sectionIndexBackgroundColor = [UIColor clearColor];
    self.view.backgroundColor = COLOR_VIEW_BG;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];

    [self addKeyboardNotifications];
    
    [self startLoadingAnimation];
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
    
    _constraintVIewTopHeight.constant = 44 + 20;
    
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    _searchBar.frame = CGRectMake(0, 20, rect.size.width, 44);

    if([IWUtility isNilOrEmptyString:_searchBar.text])
        [self disableTableInteraction:YES];

    [_viewTop layoutIfNeeded];

}

-(void)keyboardWillHide:(NSNotification *)notification
{
    _bIsKeyboardShown = NO;
    
    _constraintTableViewBottom.constant = 0;
    _constraintVIewTopHeight.constant = 44 ;

    CGRect rect = [[UIScreen mainScreen] bounds];
    _searchBar.frame = CGRectMake(0, 0, rect.size.width, 44);
    
    [self disableTableInteraction:NO];

    [self.navigationController setNavigationBarHidden: NO animated:YES];
    
    [_viewTop layoutIfNeeded];

}



-(void)getData
{
    _dictionaryWebService = [[IWDictionaryWebService alloc] initWithDelegate:self];
    [_dictionaryWebService sendAsyncRequest];
}

#pragma mark - Webservice Callbacks


-(void)requestSucceed:(BaseWebService*)webService response:(id)responseModel
{
    NSLog(@"Dictionary List Service Success.");
    _arrOfAlphabets = (NSArray*)responseModel;
    _arrOfAlphabetsCopy = (NSArray*)responseModel;
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
}

-(void)requestFailed:(BaseWebService*)webService error:(WSError*)error
{
    NSLog(@"Dictionary List Service Failed.");
    
    self.navigationItem.title = STR_WEB_SERVICE_FAILED;
    [IWUtility showWebserviceFailedAlert];

    [self stopLoadingAnimation];
}


#pragma mark - Update UI


-(void)updateUI
{
    self.navigationItem.title = @"Entries";
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    
    for (IWAlphabetStructure *alpha in _arrOfAlphabetsCopy)
    {
        [temp addObject:alpha.strAlphabet.uppercaseString];
    }
    
    _arrSliderAlphabets = [[NSArray alloc] initWithArray:[temp copy]];
    _arrSliderAlphabetsCopy = [[NSArray alloc] initWithArray:[temp copy]];

    [_tableViewWordList reloadData];
    [self setupSearchBar];
    [self stopLoadingAnimation];

}

-(void)setupSearchBar
{
    CGRect rect = [[UIScreen mainScreen] bounds];
//    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, rect.size.width - 60, 45)];
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 44)];
    _searchBar.barTintColor = [UIColor lightGrayColor];//[UIColor lightGrayColor];//[IWUtility getNavBarColor];
    _searchBar.backgroundColor = [UIColor lightGrayColor];//[IWUtility getNavBarColor];
    _searchBar.placeholder = @"Search";
    _searchBar.translucent = YES;
    _searchBar.delegate = self;
    _searchBar.showsCancelButton = NO;
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;//Removes border
    
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

    //_tableViewWordList.tableHeaderView = _searchBar;
    
    _viewTop.backgroundColor = [UIColor lightGrayColor];
    [_viewTop addSubview:_searchBar];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText// called when text changes (including clear)
{
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
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar*)searchBar
{
    [_searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}


-(void)searchForText:(NSString *)searchText
{
    NSLog(@"Text : %@",searchText);

    if(searchText.length == 0)
    {

        [_searchBar setShowsCancelButton:NO animated:YES];

        _arrOfAlphabetsCopy = _arrOfAlphabets;
        _arrSliderAlphabetsCopy = _arrSliderAlphabets;
        


    }
    else
    {
        [self disableTableInteraction:NO];

        [_searchBar setShowsCancelButton:YES animated:YES];

        NSString *strFirstAlphabet = [searchText substringWithRange:NSMakeRange(0, 1)];
        
        _arrSliderAlphabetsCopy = [[NSArray alloc] init];
        _arrOfAlphabetsCopy = [[NSArray alloc] init];
        
        for (IWAlphabetStructure *alpha in _arrOfAlphabets)
        {
            if([alpha.strAlphabet.lowercaseString isEqualToString:strFirstAlphabet.lowercaseString])
            {
                if(alpha.arrWords.count > 0)
                {
                    NSMutableArray *arrWords = [[NSMutableArray alloc] init];
                    
                    for (IWWordStructure *word in alpha.arrWords)
                    {
                        NSRange range = [word.strWord.lowercaseString rangeOfString:searchText.lowercaseString];
                        
                        if (range.location == NSNotFound)
                        {
                            NSLog(@"string was not found");
                        }
                        else if(range.location == 0)
                        {
                            [arrWords addObject:word];
                        }
                    }
                    
                    if(arrWords.count > 0)
                    {
                        IWAlphabetStructure *alphabet = [[IWAlphabetStructure alloc] init];
                        alphabet.strAlphabet = strFirstAlphabet;
                        alphabet.arrWords = arrWords;
                        
                        _arrSliderAlphabetsCopy = [[NSArray alloc] initWithObjects:alphabet.strAlphabet.uppercaseString, nil];
                        _arrOfAlphabetsCopy = [[NSArray alloc] initWithObjects:alphabet, nil];
                    }
                }
            }
        }
    }
    
    [_tableViewWordList reloadData];
}


-(void)disableTableInteraction:(BOOL)bShouldDisable
{
    _tableViewWordList.userInteractionEnabled = !bShouldDisable;
    _tableViewWordList.alpha = bShouldDisable ? 0.7 : 1.0;
}

#pragma mark - Table View Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _arrOfAlphabetsCopy.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    IWAlphabetStructure *alphabet = [_arrOfAlphabetsCopy objectAtIndex:section];
    return alphabet.arrWords.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IWAlphabetStructure *alphabet = [_arrOfAlphabetsCopy objectAtIndex:indexPath.section];
    IWWordStructure *word = [alphabet.arrWords objectAtIndex:indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellWord"];
    UILabel *labelTitle = (UILabel*)[cell viewWithTag:201];
    labelTitle.font = [UIFont fontWithName:FONT_TITLE_REGULAR size:21.0];
    labelTitle.text = word.strWord;
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return (_bIsKeyboardShown && [IWUtility isNilOrEmptyString:_searchBar.text] == NO) ? 0.0 : 40.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    IWAlphabetStructure *alphabet = [_arrOfAlphabetsCopy objectAtIndex:section];
    return alphabet.strAlphabet.lowercaseString;
}

#pragma mark - Table View Delegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat margins = 12.0;
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, margins, 0, margins +5)];
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
    header.textLabel.font = [UIFont fontWithName:FONT_BODY_ITALIC size:27];
    header.backgroundView.backgroundColor = COLOR_SECTION_HEADER;
    header.textLabel.textAlignment = NSTextAlignmentLeft;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _arrSliderAlphabetsCopy;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [_arrSliderAlphabetsCopy indexOfObject:title];
}


#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [_searchBar performSelector: @selector(resignFirstResponder)
//                     withObject: nil
//                     afterDelay: 0.1];
//    
//    [self.view endEditing:YES];
    
    IWAlphabetStructure *alphabet = [_arrOfAlphabetsCopy objectAtIndex:indexPath.section];
    IWWordStructure *word = [alphabet.arrWords objectAtIndex:indexPath.row];
    [[IWUserActionManager sharedManager] showDictionaryMeaningForWord:word.strWord];
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
@end
