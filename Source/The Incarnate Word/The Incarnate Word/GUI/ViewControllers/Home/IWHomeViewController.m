//
//  ViewController.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 16/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWHomeViewController.h"
#import "IWUIConstants.h"
#import "IWUserActionManager.h"
#import "IWUtility.h"
#import "IWCarouselItemViewController.h"


@interface IWHomeViewController()<UIPageViewControllerDataSource,UIPageViewControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    NSArray                     *_arrBanner;
    UIPageViewController        *_pageViewController;
    NSMutableArray              *_arrCarouselItemViewControllers;
    NSTimer                     *_timerPageChange;
    BOOL                        _bIsTimerBasedTransition;
}
@property (weak, nonatomic) IBOutlet UIView             *viewTop;
@property (strong, nonatomic) IBOutlet UIPageControl    *pageControl;
@property (weak, nonatomic) IBOutlet UIView             *viewBottom;
@property (weak, nonatomic) IBOutlet UILabel            *lblTitle;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionViewQuotes;


//Private Methods
-(void)setBanners;
-(void)setupPageViewController;
-(void)createCarouselItemForPageNumber:(int) pageNumber;
-(void)updateUIForNewCurrentPageNumber:(int) pageNumber;
-(void)setupNextPageTimer;
-(void)invalidateNextPageTimer;
-(void)showNextPage;
-(void)setFlagIsPageTransitionTimerBased: (BOOL) bIsPageTransitionTimerBased;

@end

@implementation IWHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-noise.png"]]];
    _viewTop.clipsToBounds = YES;
    _viewBottom.layer.cornerRadius = 5.0;
    _viewBottom.clipsToBounds = YES;

    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }

    /*
     CharlotteSansMediumPlain
     CharlotteSansBoldPlain
     CharlotteSansBookItalicPlain
     
     Swift1 OT
     2015-06-25 02:35:58.038 The Incarnate Word[7113:73489]   Swift1OT-BdIt
     2015-06-25 02:35:58.038 The Incarnate Word[7113:73489]   Swift1OT-Rg
     2015-06-25 02:35:58.038 The Incarnate Word[7113:73489]   Swift1OT-It
     2015-06-25 02:35:58.038 The Incarnate Word[7113:73489]   Swift1OT-Bd
     */
    
    UIFont *font = [UIFont fontWithName:@"Swift1OT-Rg" size:14];
    _lblTitle.font = font;//[UIFont fontWithName:@"Cabin-SemiBold" size:6];
    
    [self setupNavigationBar];
    [self setBanners];
}

-(void)setupNavigationBar
{
    UIButton *customLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    customLeftBtn.bounds = CGRectMake( 10, 0, 44, 44 );
    [customLeftBtn addTarget:self action:@selector(btnLeftMenuPressed:) forControlEvents:UIControlEventTouchUpInside];
    [customLeftBtn setImage:[UIImage imageNamed:@"btn_navbar_drawer"] forState:UIControlStateNormal];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:customLeftBtn];
    
    UIBarButtonItem *negativeSpacerLeft = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") )
    {
        negativeSpacerLeft.width = -14;
    }
    else
    {
        negativeSpacerLeft.width = -2;
    }
    
    self.navigationItem.leftBarButtonItems = [NSArray
                                              arrayWithObjects:negativeSpacerLeft, leftButton, nil];
    
     UIColor *navBarColor = [IWUtility getNavBarColor];
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector(setBarTintColor:)])//iOS 7 and above
    {
        [self.navigationController.navigationBar setBarTintColor:navBarColor];
    }
    else//iOS 6
    {
        [self.navigationController.navigationBar setTintColor:navBarColor];
    }
 
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor blackColor],NSForegroundColorAttributeName,
                                               [UIFont fontWithName:FONT_TITLE_REGULAR size:20.0],NSFontAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = navbarTitleTextAttributes;
    
}

-(IBAction)btnLeftMenuPressed:(id)sender
{
    NSLog(@"Left menu pressed");
    [[IWUserActionManager sharedManager] toggleLeftDrawer];
}


#pragma mark - WS Request Get banner data


-(void)setBanners
{
    _arrBanner = [[NSArray alloc] initWithObjects:@"If one reads Sri Aurobindo carefully one finds the answers to all that one wants to know.",
                  @"If you want to know what Sri Aurobindo has said on a given subject, you must at least read all that he has written on that subject. You will then see that he has apparently said the most contradictory things. But when one has read everything, and understood a little, one perceives that all the contradictions complement each other and are organised and unified into an integral synthesis.",
                  @"It is not by books that Sri Aurobindo ought to be studied but by subjects — what he has said on the Divine, on Unity, on religion, on evolution, on education, on self-perfection, on supermind, etc., etc.",nil];
}

#pragma mark - Setup Pages


-(void)setupPageViewController
{
    //1. Setup page view controller
    _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    _pageViewController.dataSource = self;
    _pageViewController.delegate = self ;
    [_pageViewController.view setFrame:CGRectMake(0,0 , _viewBottom.bounds.size.width, _viewBottom.bounds.size.height-30)];
    [self createCarouselItemForPageNumber:0];
    [_pageViewController setViewControllers:[_arrCarouselItemViewControllers copy] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    [_viewBottom addSubview:_pageViewController.view];
    
    //2. Setup _pageControl
    _pageControl.numberOfPages = [_arrBanner count];
    
    //3. Set default current page as page 0
    [self updateUIForNewCurrentPageNumber:0];
    
    //4. Setup timer
    [self setupNextPageTimer];
}

-(void)createCarouselItemForPageNumber:(int) pageNumber
{
    //1. Create instance of carousel item
    UIStoryboard *sb = [UIStoryboard storyboardWithName:STORYBOARD_MAIN bundle:nil];
    IWCarouselItemViewController *carouselItemVC = [sb instantiateViewControllerWithIdentifier:S_MAIN_ID_CAROUSEL_ITEM_VC];
    carouselItemVC.pageNumber = pageNumber;
    carouselItemVC.strQuote = [_arrBanner objectAtIndex:pageNumber];
    
    //2. Add it to item array
    if(_arrCarouselItemViewControllers == nil)
        _arrCarouselItemViewControllers = [[NSMutableArray alloc] init];
    
    [_arrCarouselItemViewControllers insertObject:carouselItemVC atIndex:pageNumber];
}


#pragma mark - Next page timer handling


-(void)setupNextPageTimer
{
    [self invalidateNextPageTimer];
    
    if(_arrCarouselItemViewControllers && _arrCarouselItemViewControllers.count > 0)
    {
        _timerPageChange = [NSTimer scheduledTimerWithTimeInterval:4.0
                                                            target:self
                                                          selector:@selector(showNextPage)
                                                          userInfo:nil
                                                           repeats:YES];
    }
}

-(void)invalidateNextPageTimer
{
    if(_timerPageChange && [_timerPageChange isValid])
    {
        [_timerPageChange invalidate];
        _timerPageChange = nil;
    }
}

-(void)showNextPage
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       //Already in progress ignore
                       if(_viewBottom.userInteractionEnabled == NO)
                           return ;
                       
                       [self setFlagIsPageTransitionTimerBased:YES];
                       
                       //Disable user interaction before animating to next page
                       _viewBottom.userInteractionEnabled = NO;
                       
                       int nextPageIndex = (_pageControl.currentPage + 1) < _pageControl.numberOfPages ? ((int)_pageControl.currentPage + 1) : 0;
                       
                       //add page if not already added
                       if(nextPageIndex >= _arrCarouselItemViewControllers.count)
                       {
                           [self createCarouselItemForPageNumber:nextPageIndex];
                       }
                       
                       __weak IWHomeViewController *weakOfSelf = (IWHomeViewController*)self;
                       
                       //animate to next page
                       [_pageViewController setViewControllers:@[[_arrCarouselItemViewControllers objectAtIndex:nextPageIndex]]
                                                     direction:UIPageViewControllerNavigationDirectionForward
                                                      animated:YES
                                                    completion:
                        ^(BOOL finished){
                            
                            //Re-enable user interaction
                            _viewBottom.userInteractionEnabled = YES;
                            [weakOfSelf setFlagIsPageTransitionTimerBased:NO];
                        }];
                       
                       //updtae UI
                       [self updateUIForNewCurrentPageNumber:nextPageIndex];
                   });
}

-(void)setFlagIsPageTransitionTimerBased: (BOOL) bIsPageTransitionTimerBased
{
    _bIsTimerBasedTransition = bIsPageTransitionTimerBased;
}


#pragma mark - UI Update


-(void)updateUIForNewCurrentPageNumber:(int) pageNumber
{
    _pageControl.currentPage = pageNumber;
}


#pragma mark - PageViewControllerDataSource


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    int pageNumber = [(IWCarouselItemViewController *)viewController pageNumber];
    int previousPageNumber = pageNumber - 1;
    
    if (pageNumber == 0)//no pages before page 0
        return nil;
    
    if(_arrCarouselItemViewControllers.count <= previousPageNumber)//no instance was created befor for this page number
    {
        [self createCarouselItemForPageNumber:previousPageNumber];
    }
    
    return [_arrCarouselItemViewControllers objectAtIndex: previousPageNumber];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    int pageNumber = [(IWCarouselItemViewController *)viewController pageNumber];
    int nextPageNumber = pageNumber + 1;
    
    if (nextPageNumber == [_arrBanner count])//no pages after last page
        return nil;
    
    if(_arrCarouselItemViewControllers.count <= nextPageNumber)//no instance was created befor for this page number
    {
        [self createCarouselItemForPageNumber:nextPageNumber];
    }
    
    return [_arrCarouselItemViewControllers objectAtIndex: nextPageNumber];
}


#pragma mark - PageViewControllerDelegates

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    if(_bIsTimerBasedTransition == NO)//Manual Scroll -> Disable timer based transtion
        [self invalidateNextPageTimer];
}

- (void)pageViewController:(UIPageViewController *)pvc didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    IWCarouselItemViewController *carouselItemVC = (IWCarouselItemViewController *)[_pageViewController.viewControllers lastObject];
    [self updateUIForNewCurrentPageNumber:carouselItemVC.pageNumber];
    
    if(_bIsTimerBasedTransition == NO)//Finished Manual Scroll Transition -> Re-Enable timer based transtion
        [self setupNextPageTimer];
}

#pragma mark - Collection datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _arrBanner.count + 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell;
    
    NSString *strCellId = indexPath.row == 0 ? @"CellTop" : @"CellQuote";
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:strCellId forIndexPath:indexPath];
    
    UILabel *quote = (UILabel*)[cell viewWithTag:202];

    if(indexPath.row == 0)
    {
        UILabel *title = (UILabel*)[cell viewWithTag:201];
        
        title.font = [UIFont fontWithName:FONT_TITLE_REGULAR size:25];//[UIFont fontWithName:@"CharlotteSansMediumPlain" size:25];
        
        quote.font = [UIFont fontWithName:FONT_BODY_ITALIC size:15];
        
        UIFont *font = [UIFont fontWithName:FONT_BODY_ITALIC size:15];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                    forKey:NSFontAttributeName];
        NSString *str = [NSString stringWithFormat:@"O living power of the incarnate Word,\nAll that the Spirit has dreamed thou canst create:\nThou art the force by which I made the worlds,\nThou art my vision and my will and voice."];
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:str attributes:attrsDictionary];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:10];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];

        
        quote.attributedText = attrString;

    }
    else
    {
        quote.font = [UIFont fontWithName:FONT_BODY_REGULAR size:15];

        UILabel *by = (UILabel*)[cell viewWithTag:203];
        by.font = [UIFont fontWithName:FONT_BODY_REGULAR size:13];
        
        
        
        
        
        UIFont *font = [UIFont fontWithName:FONT_BODY_REGULAR size:15];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                    forKey:NSFontAttributeName];
        NSString *str = [_arrBanner objectAtIndex:indexPath.row -1];
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:str attributes:attrsDictionary];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:5];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        [attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [str length])];
        
        
        quote.attributedText = attrString;

    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat cellWidth = screenRect.size.width - 14;
    CGFloat cellHeight = 150;
    
    if(indexPath.row == 0)
    {
        cellHeight = 170;
    }
    else if(indexPath.row == 1)
    {
        cellHeight = 130;
    }
    else if(indexPath.row == 2)
    {
        cellHeight = 270;
    }
    else if(indexPath.row == 3)
    {
        cellHeight = 200;
    }
    
    CGSize cellSize =  CGSizeMake(cellWidth , cellHeight);
    
    return cellSize;
}

@end
