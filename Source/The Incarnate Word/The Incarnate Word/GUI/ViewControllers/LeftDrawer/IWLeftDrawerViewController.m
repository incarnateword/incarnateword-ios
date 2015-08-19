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

#define MENU_TITLE @"MENU_TITLE"
#define MENU_ARRAY @"MENU_ARRAY"
#define TAG_OFFSET_SECTION_HEADER_BUTTON 200

@interface IWLeftDrawerViewController()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *_arrDataSource;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewMenu;

-(void)setupDataSource;

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

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _arrDataSource.count;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 0;
    
    return [IWUtility getNumberAsPerScalingFactor:40.0];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [IWUtility getNumberAsPerScalingFactor:43.0];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dict = [_arrDataSource objectAtIndex:section];
    NSArray *arr = [dict objectForKey:MENU_ARRAY];
    return arr.count;
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


@end
