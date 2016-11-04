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

@interface IWHomeViewController()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    NSArray     *_arrBanner;
}

@property (strong, nonatomic) IBOutlet UICollectionView *collectionViewQuotes;

-(void)setBanners;

@end

@implementation IWHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-noise.png"]]];
    
    /*
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);
        
        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }

     CharlotteSansMediumPlain
     CharlotteSansBoldPlain
     CharlotteSansBookItalicPlain
     */
    
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
                                               [UIFont fontWithName:FONT_TITLE_REGULAR size:[IWUtility getNumberAsPerScalingFactor:20]],NSFontAttributeName,nil];
    
    self.navigationController.navigationBar.titleTextAttributes = navbarTitleTextAttributes;
    
    
    //Back button font
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(0.0, 1.0);
    shadow.shadowColor = [UIColor whiteColor];
    
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor],
       NSShadowAttributeName:shadow,
       NSFontAttributeName:[UIFont fontWithName:FONT_TITLE_REGULAR size:[IWUtility getNumberAsPerScalingFactor:20]]
       }
     forState:UIControlStateNormal];
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

    float fIPadFontOffset = [IWUtility isDeviceTypeIpad] ? 4 : 0;
    
    if(indexPath.row == 0)
    {
        UILabel *title = (UILabel*)[cell viewWithTag:201];
        
        title.font = [UIFont fontWithName:FONT_TITLE_REGULAR size:[IWUtility getNumberAsPerScalingFactor:25]+fIPadFontOffset];//[UIFont fontWithName:@"CharlotteSansMediumPlain" size:25];
        
        quote.font = [UIFont fontWithName:FONT_BODY_ITALIC size:[IWUtility getNumberAsPerScalingFactor:15]+fIPadFontOffset];
        
        UIFont *font = [UIFont fontWithName:FONT_BODY_ITALIC size:[IWUtility getNumberAsPerScalingFactor:15]+fIPadFontOffset];
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
        quote.font = [UIFont fontWithName:FONT_BODY_REGULAR size:[IWUtility getNumberAsPerScalingFactor:15]+fIPadFontOffset];
        UILabel *by = (UILabel*)[cell viewWithTag:203];
        by.font = [UIFont fontWithName:FONT_BODY_REGULAR size:[IWUtility getNumberAsPerScalingFactor:13]+fIPadFontOffset];
        UIFont *font = [UIFont fontWithName:FONT_BODY_REGULAR size:[IWUtility getNumberAsPerScalingFactor:15]+fIPadFontOffset];
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
    CGFloat cellHeight = [IWUtility getNumberAsPerScalingFactor:150];
    
    if(indexPath.row == 0)
    {
        cellHeight = [IWUtility getNumberAsPerScalingFactor:170];
    }
    else if(indexPath.row == 1)
    {
        cellHeight = [IWUtility getNumberAsPerScalingFactor:130];
    }
    else if(indexPath.row == 2)
    {
        cellHeight = [IWUtility getNumberAsPerScalingFactor:270];
    }
    else if(indexPath.row == 3)
    {
        cellHeight = [IWUtility getNumberAsPerScalingFactor:200];
    }
    
    CGSize cellSize =  CGSizeMake(cellWidth , cellHeight);
    
    return cellSize;
}

#pragma mark - Orientation

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_collectionViewQuotes reloadData];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [_collectionViewQuotes reloadData];
}

@end
