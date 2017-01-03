//
//  IWUserActionManager.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IWDetailChapterStructure.h"

@interface IWUserActionManager : NSObject


+(IWUserActionManager*)sharedManager;


-(void)showCompilationWithPath:(NSString *) strPath
                andForceOnRoot:(BOOL)bShouldForceOnRoot;

-(void)showCompilationForChapter;
-(void)showVolumeForChapter;

-(void)showFirstChapterForCompilationWithPath:(NSString *) strPath;
-(void)showFirstChapterForVolumePath:(NSString *) strPath;


-(void)showVolumeWithPath:(NSString *) strPath;
-(void)showChapterWithPath:(NSString *) strPath
              andItemIndex:(int) iItemIndex
        andShouldForcePush:(BOOL) bShouldForcePush
         andParagraphIndex:(int) iParagraphIndex
      andShouldForceOnRoot:(BOOL) bShouldForceOnRoot;


-(void)showChapterWithPath:(NSString *) strPath
              andItemIndex:(int) iItemIndex
        andShouldForcePush:(BOOL) bShouldForcePush
  andShouldUpdateVolumeUrl:(BOOL) bShouldUpdateVolumeUrl
         andParagraphIndex:(int) iParagraphIndex
      andShouldForceOnRoot:(BOOL) bShouldForceOnRoot;


-(void)showChapterWithChapterStructure:(IWDetailChapterStructure*) detailChapterStructure;
-(void)showAboutWithPath:(NSString *) strPath andImageName:(NSString*)strImageName andDescriptionHeight:(float) height;
-(void)showDictionary;
-(void)showOfflineChapters;
-(void)showManageNotificationScreen;
-(void)showDictionaryMeaningForWord:(NSString*)strWord;
-(void)showHomeScreen;
-(void)toggleLeftDrawer;
-(void)showAdvanceSearch:(NSString*) strSearchSting;
-(void)pushAdvanceSearchMoreView;
//TODO: Move to data manager
-(void)saveChapter:(IWDetailChapterStructure*) detailChapterStructure;
-(IWDetailChapterStructure*)getOfflineChapterWithUrl:(NSString*)strUrl;
-(NSDictionary*)getOfflineChapters;


-(void)resetCurrentCompilation;

@end
