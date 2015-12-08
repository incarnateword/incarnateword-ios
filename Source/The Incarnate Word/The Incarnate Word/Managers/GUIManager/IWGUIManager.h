//
//  IWGUIManager.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IWInfoViewController.h"


@interface IWGUIManager : NSObject

+(IWGUIManager*)sharedManager;


#pragma mark - Root view navigation

-(void) rootViewPushViewController:(UIViewController *)viewController
                       forceOnRoot:(BOOL) forceOnRoot
                          animated:(BOOL) animate;

-(void) rootViewShowModalViewController:(UIViewController *)viewController
                            forceOnRoot:(BOOL) forceOnRoot;


#pragma mark - Drawer Utiliy

-(void) drawerHideLeft;
-(void) drawerToggleLeft;
-(void) drawerEnableAccess:(BOOL)bShouldEnableAccess;

#pragma mark - Utiliy

-(UINavigationController *) getAppRootNavController;
-(UIWindow *) getMainWindow;
- (void) popAppToRootViewController:(BOOL) animate;


-(IWInfoViewController*)getInfoViewControllerForText:(NSString*) strText;


@end
