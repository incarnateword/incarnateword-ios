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

-(void)showCompilationWithPath:(NSString *) strPath
                andForceOnRoot:(BOOL)bShouldForceOnRoot
{
    UIStoryboard *sbCompilation = [UIStoryboard storyboardWithName:STORYBOARD_COMPILATION bundle:nil];
    IWCompilationViewController *compilationViewController = [sbCompilation instantiateViewControllerWithIdentifier:S_COMP_COMPILATION_VC];
    compilationViewController.strCompilationPath = strPath;
    [[IWGUIManager sharedManager] rootViewPushViewController:compilationViewController forceOnRoot:bShouldForceOnRoot animated:YES];
}

-(void)showVolumeWithPath:(NSString *) strPath
{
    UIStoryboard *sbVolume = [UIStoryboard storyboardWithName:STORYBOARD_VOLUME bundle:nil];
    IWVolumeDetailsViewController *volumeDetailsViewController = [sbVolume instantiateViewControllerWithIdentifier:S_VOL_VOLUME_DETAILS_VC];
    volumeDetailsViewController.strVolumePath = strPath;
    [[IWGUIManager sharedManager] rootViewPushViewController:volumeDetailsViewController forceOnRoot:NO animated:YES];
}

-(void)showChapterWithPath:(NSString *) strPath andItemIndex:(int) iItemIndex;
{
    UIStoryboard *sbChapter = [UIStoryboard storyboardWithName:STORYBOARD_CHAPTER bundle:nil];
    IWChapterDetailsViewController *chapterViewController = [sbChapter instantiateViewControllerWithIdentifier:S_CHAP_CHAPTER_DETAILS_VC];
    chapterViewController.strChapterPath = strPath;
    chapterViewController.iItemIndex = iItemIndex;
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

@end
