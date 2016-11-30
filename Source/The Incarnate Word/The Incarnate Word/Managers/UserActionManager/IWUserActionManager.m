//
//  IWUserActionManager.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWUserActionManager.h"
#import "IWCompilationViewController.h"
#import "IWUIConstants.h"
#import "IWGUIManager.h"
#import "IWVolumeDetailsViewController.h"
#import "IWChapterDetailsViewController.h"
#import "IWAboutViewController.h"
#import "IWDictionaryViewController.h"
#import "IWDictionaryMeaningViewController.h"
#import "IWOfflineChapterListViewController.h"
#import "IWCompilationWebService.h"
#import "IWUtility.h"
#import "IWCompilationStructure.h"
#import "IWVolumeStructure.h"
#import "IWVolumeWebService.h"
#import "IWDetailVolumeStructure.h"

#import "IWSectionStructure.h"
#import "IWSubSectionStructrue.h"
#import "IWPartStructure.h"
#import "IWSegmentStructure.h"
#import "IWBookStructure.h"
#import "IWChapterStructure.h"
#import "IWChaterItemStructure.h"

#import "The_Incarnate_Word-Swift.h"
@class IWAdvanceSearchViewController;

#import "IWGUIManager.h"

#define kUserDefaultKeyOfflineChapterDetailStructure  @"UserDefaultKeyOfflineChapterDetailStructure"

@interface IWUserActionManager()<WebServiceDelegate>
{
    IWCompilationWebService             *_compilationWebService;
    IWVolumeWebService                  *_volumeWebService;
    IWChapterDetailsViewController      *_chapterViewController;
    NSString *_strVolumePath;
}

@property(nonatomic)    NSString *strCurrentCompilation;
@property(nonatomic)    NSString *strCurrentVolume;

@end

@implementation IWUserActionManager

static IWUserActionManager* userActionManager = nil ;

#pragma mark - Singlton instance creation

+(void)initialize
{
    if (!userActionManager)
    {
        userActionManager = [[IWUserActionManager alloc] init] ;
    }
}


+(IWUserActionManager *)sharedManager
{
    return userActionManager;
}


-(id) init
{
    if (nil == userActionManager)
    {
        userActionManager = [super init];
    }
    
    return userActionManager ;
}

-(void)resetCurrentCompilation
{
    _strCurrentCompilation = nil;
}

-(void)showCompilationWithPath:(NSString *) strPath
                andForceOnRoot:(BOOL)bShouldForceOnRoot
{
    UIStoryboard *sbCompilation = [UIStoryboard storyboardWithName:STORYBOARD_COMPILATION bundle:nil];
    IWCompilationViewController *compilationViewController = [sbCompilation instantiateViewControllerWithIdentifier:S_COMP_COMPILATION_VC];
    compilationViewController.strCompilationPath = strPath;
    [[IWGUIManager sharedManager] rootViewPushViewController:compilationViewController forceOnRoot:bShouldForceOnRoot animated:YES];
}

-(void)showCompilationForChapter
{
    [self showCompilationWithPath:_strCurrentCompilation andForceOnRoot:NO];
}

-(void)pushAdvanceSearchMoreView
{
    UIStoryboard *sbCompilation = [UIStoryboard storyboardWithName:STORYBOARD_ADVANCE_SEARCH bundle:nil];

    [[IWGUIManager sharedManager] rootViewPushViewController:[sbCompilation instantiateViewControllerWithIdentifier:S_ADVANCE_SEARCH_MORE_VC] forceOnRoot:NO animated:YES];
}

-(void)showVolumeForChapter
{
    [self showVolumeWithPath:_strCurrentVolume];
}

-(void)showFirstChapterForCompilationWithPath:(NSString *) strPath
{
    [[IWGUIManager sharedManager] addActivityIndicatorOverWindow];

    _strCurrentCompilation = strPath;
    [self getCompilationData];
}


-(void)showFirstChapterForVolumePath:(NSString *) strPath
{
//    [[IWGUIManager sharedManager] addActivityIndicatorOverWindow];
    
    _strCurrentVolume = strPath;
    [self getVolumeData:strPath];
}

-(void)getCompilationData
{
    _compilationWebService = [[IWCompilationWebService alloc] initWithPath:_strCurrentCompilation AndDelegate:self];
    [_compilationWebService sendAsyncRequest];
}


-(void)getVolumeData:(NSString *) strVolumePath
{
    _strVolumePath = strVolumePath;
    _volumeWebService = [[IWVolumeWebService alloc] initWithPath:strVolumePath AndDelegate:self];
    [_volumeWebService sendAsyncRequest];
}

#pragma mark - Webservice Callbacks

-(void)requestSucceed:(BaseWebService*)webService response:(id)responseModel
{
    
    if(webService == _compilationWebService)
    {
        NSLog(@"CompilationWebService Success.");
        IWCompilationStructure *compilation = (IWCompilationStructure*)responseModel;
        IWVolumeStructure *volume = [compilation.arrVolumes objectAtIndex:0];
        [self getVolumeData:volume.strUrl];
    }
    else if(webService == _volumeWebService)
    {
        NSLog(@"VolumeWebService Success.");
        IWDetailVolumeStructure *detailVolumeStructure = (IWDetailVolumeStructure*)responseModel;
        [self showFirstChapterForVolume:detailVolumeStructure];
    }
}

-(void)requestFailed:(BaseWebService*)webService error:(WSError*)error
{
    if(webService == _compilationWebService)
    {
        NSLog(@"CompilationWebService Failed.");
    }
    else if(webService == _volumeWebService)
    {
        NSLog(@"VolumeWebService Failed.");
    }

    [IWUtility showWebserviceFailedAlert];
    
    [[IWGUIManager sharedManager] removeActivityIndicatorOverWindow];

}



-(void)showFirstChapterForVolume:(IWDetailVolumeStructure*) detailVolumeStructure
{
    

    id chapOrItem;
    
    if(detailVolumeStructure.arrBooks && detailVolumeStructure.arrBooks > 0)//Volumes has books
    {
        IWBookStructure *book = [detailVolumeStructure.arrBooks objectAtIndex:0];
        NSArray *arrChapAndItem = [book getChaptersAndItemsFromBookArray];
        
        for (id item in arrChapAndItem)
        {
            if([item isKindOfClass:[IWChapterStructure class]])
            {
                chapOrItem = item;
                break;
            }
            else if([item isKindOfClass:[IWPartStructure class]])
            {
                IWPartStructure *part = (IWPartStructure*)item;
                
                if(part.arrChapters.count> 0)
                {
                    chapOrItem = part.arrChapters.firstObject;
                    break;
                }
                
                if(part.arrSections.count> 0)
                {
                    IWSectionStructure *section = part.arrSections.firstObject;
                    
                    if(section.arrChapters.count > 0)
                    {
                        chapOrItem = section.arrChapters.firstObject;
                        break;
                    }
                }
            }
            else if([item isKindOfClass:[IWSectionStructure class]])
            {
                IWSectionStructure *section = item;
                
                if(section.arrChapters.count > 0)
                {
                    chapOrItem = section.arrChapters.firstObject;
                    break;
                }
            }
        }
        
    }
    else if(detailVolumeStructure.arrParts && detailVolumeStructure.arrParts > 0)//Volume has parts
    {
        IWPartStructure *part = [detailVolumeStructure.arrParts objectAtIndex:0];
        NSArray *arrChapAndItem = [part getChaptersAndItemsFromPartArray];

        for (id item in arrChapAndItem)
        {
            if([item isKindOfClass:[IWChapterStructure class]])
            {
                chapOrItem = item;
                break;
            }
            else if([item isKindOfClass:[IWSectionStructure class]])
            {
                IWSectionStructure *section = (IWSectionStructure*)chapOrItem;
                
                if(section.arrChapters.count > 0)
                {
                    chapOrItem = section.arrChapters.firstObject;
                    break;
                }
            }
            else if([item isKindOfClass:[IWSubSectionStructrue class]])
            {
                IWSubSectionStructrue *subSection = (IWSubSectionStructrue*)chapOrItem;
                
                if(subSection.arrChapters.count > 0)
                {
                    chapOrItem = subSection.arrChapters.firstObject;
                    break;
                }
            }
        }
    }
    else if(detailVolumeStructure.arrChapters && detailVolumeStructure.arrChapters > 0)//Volume has direct chapters
    {
        chapOrItem = [self getChaptersAndItemsFromChapterArray:detailVolumeStructure.arrChapters];
    }
    
    NSString *strUrl = nil;
    int iItemIndex = 0;
    

    
    if([chapOrItem isKindOfClass:[IWSubSectionStructrue class]]||
       [chapOrItem isKindOfClass:[IWPartStructure class]] ||
       [chapOrItem isKindOfClass:[IWSegmentStructure class]] )
    {
        //Do nothing
        NSLog(@"No chapter or item :%@", chapOrItem);
    }
    
    if([chapOrItem isKindOfClass:[IWSectionStructure class]])
    {
        IWSectionStructure *section = (IWSectionStructure*)chapOrItem;
        
        if(section.arrChapters.count > 0)
        {
            IWChapterStructure *chapter = (IWChapterStructure*)[section.arrChapters firstObject];
            strUrl = chapter.strUrl;
        }

    }
    else if([chapOrItem isKindOfClass:[IWChapterStructure class]])
    {
        IWChapterStructure *chapter = (IWChapterStructure*)chapOrItem;
        strUrl = chapter.strUrl;
    }
    else if([chapOrItem isKindOfClass:[IWChaterItemStructure class]])
    {
        IWChaterItemStructure *chapterItem = (IWChaterItemStructure*)chapOrItem;
        strUrl = chapterItem.strUrlParentChapter;
        iItemIndex = chapterItem.iItemIndex;
    }
    
    if(strUrl)
    {
        _chapterViewController = nil;
        [[IWUserActionManager sharedManager] showChapterWithPath:[NSString stringWithFormat:@"%@/%@",_strVolumePath,strUrl]
                                                    andItemIndex:iItemIndex andShouldForcePush:NO] ;
    }
}

-(NSArray *)getChaptersAndItemsFromChapterArray:(NSArray*) arrChapters
{
    NSMutableArray *arrChapAndItems = [[NSMutableArray alloc] init];
    
    for(IWChapterStructure *chap in arrChapters)
    {
        [arrChapAndItems addObject:chap];
        
        /* Hide chapter segments and items as clicking on them will not take to that location in chapter
         
         if(chap.arrChapterSegments && chap.arrChapterSegments.count > 0)
         {
         for (IWSegmentStructure *segment in chap.arrChapterSegments)
         {
         IWSegmentStructure *dummySegment = [[IWSegmentStructure alloc] init];
         dummySegment.strTitle = segment.strTitle;
         dummySegment.strUrl =  segment.strUrl;
         
         [arrChapAndItems addObject:dummySegment];
         
         for(IWChaterItemStructure *chapItem in segment.arrItems)
         {
         [arrChapAndItems addObject:chapItem];
         }
         }
         }
         else if(chap.arrChapterItems && chap.arrChapterItems.count > 0)
         {
         for(IWChaterItemStructure *chapItem in chap.arrChapterItems)
         {
         [arrChapAndItems addObject:chapItem];
         }
         }
         
         */
    }
    
    return [arrChapAndItems copy];
}

-(void)showVolumeWithPath:(NSString *) strPath
{
    UIStoryboard *sbVolume = [UIStoryboard storyboardWithName:STORYBOARD_VOLUME bundle:nil];
    IWVolumeDetailsViewController *volumeDetailsViewController = [sbVolume instantiateViewControllerWithIdentifier:S_VOL_VOLUME_DETAILS_VC];
    volumeDetailsViewController.strVolumePath = strPath;
    [[IWGUIManager sharedManager] rootViewPushViewController:volumeDetailsViewController forceOnRoot:NO animated:YES];
}

-(void)showChapterWithPath:(NSString *) strPath andItemIndex:(int) iItemIndex andShouldForcePush:(BOOL) bShouldForcePush andShouldUpdateVolumeUrl:(BOOL) bShouldUpdateVolumeUrl
{
    
    if(bShouldUpdateVolumeUrl)
    {
        NSArray *arrPathComponent = [strPath componentsSeparatedByString:@"/"]; // e.g /sabcl/28/
        
        if (arrPathComponent.count >= 3)
        {
            _strCurrentVolume = [NSString stringWithFormat:@"%@/%@",[arrPathComponent objectAtIndex:1],[arrPathComponent objectAtIndex:2]];
        }
    }
    
    [self showChapterWithPath:strPath andItemIndex:iItemIndex andShouldForcePush:bShouldForcePush];
}


-(void)showChapterWithPath:(NSString *) strPath andItemIndex:(int) iItemIndex andShouldForcePush:(BOOL) bShouldForcePush;
{
    if(bShouldForcePush)
        _chapterViewController = nil;
    
    if(_chapterViewController)//In chapter view pressed Next/Prev -> No need to push just update UI
    {
        _chapterViewController.strChapterPath = strPath;
        _chapterViewController.iItemIndex = iItemIndex;
        _chapterViewController.offlineDetailChapterStructure = nil;
        
        [_chapterViewController setupVC];
    }
    else
    {
        UIStoryboard *sbChapter = [UIStoryboard storyboardWithName:STORYBOARD_CHAPTER bundle:nil];
        _chapterViewController = [sbChapter instantiateViewControllerWithIdentifier:S_CHAP_CHAPTER_DETAILS_VC];
        _chapterViewController.strChapterPath = strPath;
        _chapterViewController.iItemIndex = iItemIndex;
        [[IWGUIManager sharedManager] rootViewPushViewController:_chapterViewController forceOnRoot:NO animated:YES];
    }
}

-(void)showChapterWithChapterStructure:(IWDetailChapterStructure*) detailChapterStructure;
{
    UIStoryboard *sbChapter = [UIStoryboard storyboardWithName:STORYBOARD_CHAPTER bundle:nil];
    IWChapterDetailsViewController *chapterViewController = [sbChapter instantiateViewControllerWithIdentifier:S_CHAP_CHAPTER_DETAILS_VC];
    chapterViewController.offlineDetailChapterStructure = detailChapterStructure;
    [[IWGUIManager sharedManager] rootViewPushViewController:chapterViewController forceOnRoot:NO animated:YES];
}


-(void)showAboutWithPath:(NSString *) strPath andImageName:(NSString*)strImageName andDescriptionHeight:(float) height
{
    UIStoryboard *sbAbout = [UIStoryboard storyboardWithName:STORYBOARD_ABOUT bundle:nil];
    IWAboutViewController *aboutVC = [sbAbout instantiateViewControllerWithIdentifier:S_ABOUT_ABOUT_VC];
    aboutVC.strAboutPath = strPath;
    aboutVC.strImageName = strImageName;
    aboutVC.fRowHeight = height;
    [[IWGUIManager sharedManager] rootViewPushViewController:aboutVC forceOnRoot:NO animated:YES];
}

-(void)showDictionary
{
    UIStoryboard *sbDict = [UIStoryboard storyboardWithName:STORYBOARD_DICTIONARY bundle:nil];
    IWDictionaryViewController *dictVC = [sbDict instantiateViewControllerWithIdentifier:S_DICTIONARY_DICTIONARY_VC];
    [[IWGUIManager sharedManager] rootViewPushViewController:dictVC forceOnRoot:NO animated:YES];
}

-(void)showManageNotificationScreen
{
    UIStoryboard *sbNotif = [UIStoryboard storyboardWithName:STORYBOARD_NOTIFICATION bundle:nil];
    [[IWGUIManager sharedManager] rootViewPushViewController:[sbNotif instantiateViewControllerWithIdentifier:S_NOTIFICATION_MANAGE_VC] forceOnRoot:NO animated:YES];
    
}

-(void)showOfflineChapters
{
    UIStoryboard *sbChapter = [UIStoryboard storyboardWithName:STORYBOARD_CHAPTER bundle:nil];
    IWOfflineChapterListViewController  *offlineList = [sbChapter instantiateViewControllerWithIdentifier:S_CHAP_OFFLINE_CHAPTER_LIST_VC];
    [[IWGUIManager sharedManager] rootViewPushViewController:offlineList forceOnRoot:NO animated:YES];
}

-(void)showDictionaryMeaningForWord:(NSString*)strWord
{
    UIStoryboard *sbDict = [UIStoryboard storyboardWithName:STORYBOARD_DICTIONARY bundle:nil];
    IWDictionaryMeaningViewController *dictMeaningVC = [sbDict instantiateViewControllerWithIdentifier:S_DICTIONARY_DICTIONARY_MEANING_VC];
    dictMeaningVC.strWord = strWord;
    [[IWGUIManager sharedManager] rootViewPushViewController:dictMeaningVC forceOnRoot:NO animated:YES];
}

-(void)showHomeScreen
{
    [[IWGUIManager sharedManager] drawerToggleLeft];
    [[IWGUIManager sharedManager] popAppToRootViewController:NO];
}

-(void)toggleLeftDrawer
{
    [[IWGUIManager sharedManager] drawerToggleLeft];
}

-(void)showAdvanceSearch:(NSString*) strSearchSting;
{
    UIStoryboard *sbDict = [UIStoryboard storyboardWithName:STORYBOARD_ADVANCE_SEARCH bundle:nil];
    IWAdvanceSearchViewController *advanceSearchVC = [sbDict instantiateViewControllerWithIdentifier:@"IWAdvanceSearchViewController"];
    advanceSearchVC._strSearch = strSearchSting;
    [[IWGUIManager sharedManager] rootViewPushViewController:advanceSearchVC forceOnRoot:YES animated:YES];

}

#pragma mark - Data Manager

-(void)saveChapter:(IWDetailChapterStructure*) detailChapterStructure
{
    //return;//AppStore
    
    NSMutableDictionary *dictTemp = [[NSMutableDictionary alloc] init];
    
    NSDictionary *dictExistingList = [self getOfflineChapters];
    
    if(dictExistingList)
    {
        dictTemp = [[NSMutableDictionary alloc] initWithDictionary:dictExistingList];
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:detailChapterStructure];
    [dictTemp setObject:data forKey:detailChapterStructure.strUrl];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[dictTemp copy] forKey:kUserDefaultKeyOfflineChapterDetailStructure];
    [userDefaults synchronize];
}



-(IWDetailChapterStructure*)getOfflineChapterWithUrl:(NSString*)strUrl
{
    //return nil;//AppStore
    
    IWDetailChapterStructure *detailChapterStructure = nil;
    NSDictionary *dictExistingList = [self getOfflineChapters];
    
    if([dictExistingList objectForKey:strUrl])
    {
        if([NSKeyedUnarchiver unarchiveObjectWithData:[dictExistingList objectForKey:strUrl]])
        {
            detailChapterStructure = [NSKeyedUnarchiver unarchiveObjectWithData:[dictExistingList objectForKey:strUrl]];
        }
    }
    
    return detailChapterStructure;
}

-(NSDictionary*)getOfflineChapters
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:kUserDefaultKeyOfflineChapterDetailStructure];
}



@end
