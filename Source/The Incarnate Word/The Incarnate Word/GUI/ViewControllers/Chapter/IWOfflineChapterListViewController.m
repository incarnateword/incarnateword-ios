//
//  IWOfflineChapterListViewController.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 20/12/15.
//  Copyright © 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWOfflineChapterListViewController.h"
#import "IWUtility.h"
#import "IWUIConstants.h"
#import "IWUserActionManager.h"
#import "IWDetailChapterStructure.h"

@interface IWOfflineChapterListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *_arrChapters;
}

@property (weak, nonatomic) IBOutlet UITableView *tableViewChapterList;

@end

@implementation IWOfflineChapterListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupVC];
}

-(void)setupVC
{
    [self setupUI];
    [self getData];
}

-(void)setupUI
{
    self.navigationItem.title = @"Offline Chapters";
    _tableViewChapterList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)getData
{
    _arrChapters = [[NSArray alloc] initWithArray:[[IWUserActionManager sharedManager]getOfflineChapters]];
    [_tableViewChapterList reloadData];
}

#pragma mark - Table View Datasource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrChapters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellChapter"];
    UILabel *labelTitle = (UILabel*)[cell viewWithTag:201];
    labelTitle.font = [UIFont fontWithName:FONT_TITLE_REGULAR size:[IWUtility getNumberAsPerScalingFactor:18]];
    
    IWDetailChapterStructure *detailChapterStructure; ;

    if([NSKeyedUnarchiver unarchiveObjectWithData:[_arrChapters objectAtIndex:indexPath.row]])
    {
        detailChapterStructure = [NSKeyedUnarchiver unarchiveObjectWithData:[_arrChapters objectAtIndex:indexPath.row]];

    }
    
    labelTitle.text = detailChapterStructure.strTitle;
    
    return cell;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [IWUtility getNumberAsPerScalingFactor:44];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    IWDetailChapterStructure *detailChapterStructure = [NSKeyedUnarchiver unarchiveObjectWithData:[_arrChapters objectAtIndex:indexPath.row]];

    [[IWUserActionManager sharedManager] showChapterWithChapterStructure:detailChapterStructure];

}

@end
