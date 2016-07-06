//
//  IWGUIManager.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWGUIManager.h"

//Drawer
#import "MMDrawerController.h"
#import "MMExampleDrawerVisualStateManager.h"

#import "IWLeftDrawerViewController.h"
#import "IWUtility.h"
#import "IWUIConstants.h"
#import "IWHomeViewController.h"
#import "IWOfflineChapterListViewController.h"
#import "IWChapterDetailsViewController.h"
#import "IWUserActionManager.h"
#import "IWCompilationViewController.h"
#import "IWVolumeDetailsViewController.h"

#import "The_Incarnate_Word-Swift.h"

@interface IWGUIManager()<UINavigationControllerDelegate>
{
    IWCustomSpinnerViewController *_customSpinnerVC;

}

@property (nonatomic,strong) MMDrawerController             *drawerController;

@end


@implementation IWGUIManager

static IWGUIManager* guiManager = nil ;

#pragma mark - Singlton instance creation

+(void)initialize
{
    if (!guiManager)
    {
        guiManager = [[IWGUIManager alloc] init] ;
    }
}

+(IWGUIManager *)sharedManager
{
    return guiManager;
}

-(id) init
{
    if (nil == guiManager)
    {
        guiManager = [super init];
        
        [self setupInitialUI];
    }
    
    return guiManager ;
}

-(void)setupInitialUI
{
    [self setupDrawerConrtol];
}

#pragma mark - Setup Drawer Control


- (void) setupDrawerConrtol
{
    UIStoryboard *sbMain = [UIStoryboard storyboardWithName:STORYBOARD_MAIN bundle:nil];
    UIStoryboard *sbLeftDrawer = [UIStoryboard storyboardWithName:STORYBOARD_LEFT_DRAWER bundle:nil];
    
    IWLeftDrawerViewController *leftVC = [sbLeftDrawer instantiateViewControllerWithIdentifier:S_LEFT_ID_LEFT_DRAWER_VC];
    
    UINavigationController *cenrerVC = [sbMain instantiateViewControllerWithIdentifier:S_MAIN_ID_CENTER_NAVIGATION_VC] ;
    
    self.drawerController = [[MMDrawerController alloc]
                             initWithCenterViewController:cenrerVC
                             leftDrawerViewController:leftVC
                             rightDrawerViewController:nil];
    
    [self.drawerController setRestorationIdentifier:@"MMDrawer"];
    [self.drawerController setMaximumLeftDrawerWidth:[IWUtility getDrawerWidth]];
    
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeBezelPanningCenterView];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeBezelPanningCenterView | MMCloseDrawerGestureModePanningCenterView |MMCloseDrawerGestureModeTapCenterView];
    
    [self.drawerController setCenterHiddenInteractionMode:MMDrawerOpenCenterInteractionModeNone];
    self.drawerController.showsShadow = NO;
    self.drawerController.centerHiddenInteractionMode = MMDrawerOpenCenterInteractionModeNavigationBarOnly;
    
    [self.drawerController setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible)
     {
         
         MMDrawerControllerDrawerVisualStateBlock block;
         block = [[MMExampleDrawerVisualStateManager sharedManager]
                  drawerVisualStateBlockForDrawerSide:drawerSide];
         
         if(block)
         {
             block(drawerController, drawerSide, percentVisible);
         }
     }];
    
    __weak IWGUIManager *weakSelf = self;
    
    [self.drawerController setGestureCompletionBlock:^(MMDrawerController *drawerController, UIGestureRecognizer *gesture)
    {
        [weakSelf drawerEndEditingForLeftDrawer];
    }];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    if(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        UIColor * tintColor = [UIColor colorWithRed:29.0/255.0
                                              green:173.0/255.0
                                               blue:234.0/255.0
                                              alpha:1.0];
        [window setTintColor:tintColor];
    }
    
    [window setRootViewController:self.drawerController];
    [window makeKeyAndVisible];
}

-(void) drawerEndEditingForLeftDrawer
{
    [self.drawerController.leftDrawerViewController.view endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_LEFT_DRAWER_CLOSED object:nil];
}


#pragma mark - Drawer Utiliy

- (void) drawerHideLeft
{
    dispatch_async(dispatch_get_main_queue(),
   ^{
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        MMDrawerController *drawerVC = (MMDrawerController*) window.rootViewController;
        
        if(drawerVC.openSide == MMDrawerSideLeft)
        {
            [drawerVC toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
        }
   });
}

- (void) drawerToggleLeft
{
    dispatch_async(dispatch_get_main_queue(),
   ^{
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        MMDrawerController *drawerVC = (MMDrawerController*) window.rootViewController;
        
        if(drawerVC.openSide == MMDrawerSideLeft)
        {
            [self drawerEndEditingForLeftDrawer];
        }
        
        [drawerVC toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    });

}

-(void) forceOnRoot:(UINavigationController *) centerNavController
{
    //Dismiss View controller that was presented modally if any
    if(nil != centerNavController.presentedViewController)
        [centerNavController dismissViewControllerAnimated:NO completion:nil];
    
    //POP to root view controller
    [centerNavController popToRootViewControllerAnimated:NO] ;
}

- (void) drawerEnableAccess:(BOOL)bShouldEnableAccess
{
    if (bShouldEnableAccess)
    {
        [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeBezelPanningCenterView];
        [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeBezelPanningCenterView | MMCloseDrawerGestureModePanningCenterView];
    }
    else
    {
        [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
        [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
    }
}

#pragma mark - Utility Methods

-(UINavigationController *)getAppRootNavController
{
    return (UINavigationController*)_drawerController.centerViewController;
}

-(UIWindow *)getMainWindow
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    return window;
}

- (void) popAppToRootViewController:(BOOL) animate
{
    //POP to root view controller
    [[self getAppRootNavController] popToRootViewControllerAnimated:animate] ;
}

#pragma mark - Root view navigation


- (void) rootViewPushViewController:(UIViewController *)viewController forceOnRoot:(BOOL) forceOnRoot animated:(BOOL) animate
{
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       
                       UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
                       MMDrawerController *drawerVC = (MMDrawerController*) window.rootViewController;
                       UINavigationController *centerNavController = (UINavigationController*) drawerVC.centerViewController;
                       centerNavController.delegate = self;
                       
                       if(drawerVC.openSide == MMDrawerSideLeft)
                       {
                           [drawerVC toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
                       }
                       
                       if(forceOnRoot == YES)
                       {
                           [self forceOnRoot:centerNavController];
                       }
                       
                       [centerNavController pushViewController:viewController animated:YES];
                   });
}


- (void) rootViewShowModalViewController:(UIViewController *)viewController forceOnRoot:(BOOL) forceOnRoot
{
    
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
                       MMDrawerController *drawerVC = (MMDrawerController*) window.rootViewController;
                       UINavigationController *centerNavController = (UINavigationController*) drawerVC.centerViewController;
                       centerNavController.delegate = self;
                       
                       if(drawerVC.openSide == MMDrawerSideLeft)
                       {
                           [drawerVC toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
                       }
                       
                       if(forceOnRoot == YES)
                       {
                           [self forceOnRoot:centerNavController];
                       }
                       
                       [centerNavController presentViewController:viewController animated:YES completion:nil];
                   });
}

#pragma mark - UINavigationController delegate

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController class] == [IWHomeViewController class] ||
        [viewController class] == [IWCompilationViewController class]||
        [viewController class] == [IWVolumeDetailsViewController class]||
        [viewController class] == [IWAdvanceSearchResultViewController class]||
        [viewController class] == [IWAdvanceSearchViewController class])
    {
        return ;
    }
    
    if(navigationController.viewControllers.count >= 2)
    {
        UIViewController *vc = [navigationController.viewControllers objectAtIndex:navigationController.viewControllers.count - 2];
        if([vc isKindOfClass:[IWOfflineChapterListViewController class]])
            return;
    }
    
    UIButton *customLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    customLeftBtn.bounds = CGRectMake( 10, 0, 40, 40 );
    [customLeftBtn addTarget:self action:@selector(btnLeftDrawerClicked) forControlEvents:UIControlEventTouchUpInside];
    [customLeftBtn setImage:[UIImage imageNamed:@"btn_navbar_drawer"] forState:UIControlStateNormal];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:customLeftBtn];
    
    UIBarButtonItem *negativeSpacerLeft = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
    if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") )
    {
        negativeSpacerLeft.width = -10;
    }
    else
    {
        negativeSpacerLeft.width = 5;
    }
    
    viewController.navigationItem.leftBarButtonItems = [NSArray
                                                        arrayWithObjects:negativeSpacerLeft, leftButton, nil];
    
    if ([viewController class] == [IWChapterDetailsViewController class])
    {
        UIButton *customRighBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        customRighBtn.bounds = CGRectMake( 40, 0, 40, 40 );
        [customRighBtn addTarget:self action:@selector(btnRightDrawerClicked) forControlEvents:UIControlEventTouchUpInside];
        [customRighBtn setImage:[UIImage imageNamed:@"btn_navbar_content"] forState:UIControlStateNormal];
        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:customRighBtn];
        
        UIBarButtonItem *negativeSpacerRight = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                               target:nil action:nil];
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") )
        {
            negativeSpacerRight.width = -9;
        }
        else
        {
            negativeSpacerRight.width = -5;
        }
        
        viewController.navigationItem.rightBarButtonItems = [NSArray
                                                            arrayWithObjects:negativeSpacerRight,rightButton,nil];
    }
}

-(void)btnLeftDrawerClicked
{
    [self drawerToggleLeft];
}

-(void)btnRightDrawerClicked
{
    [[IWUserActionManager sharedManager] showCompilationForChapter];
}

-(IWInfoViewController*)getInfoViewControllerForText:(NSString*) strText
{
    UIStoryboard *sbPopover = [UIStoryboard storyboardWithName:STORYBOARD_POPOVER bundle:nil];
    IWInfoViewController *infoVC = [sbPopover instantiateViewControllerWithIdentifier:S_POPOVER_INFO_VC];
    infoVC.strText = strText;
    
    return infoVC;
}


-(void)addActivityIndicatorOverWindow
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Utility" bundle:nil];
    _customSpinnerVC = [sb instantiateViewControllerWithIdentifier:@"IWCustomSpinnerViewController"];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    [window addSubview:_customSpinnerVC.view];
    _customSpinnerVC.view.frame = window.bounds;
        
        });
}

-(void)removeActivityIndicatorOverWindow
{
    dispatch_after(DISPATCH_TIME_NOW*1, dispatch_get_main_queue(),
    ^{
        if(_customSpinnerVC)
            [_customSpinnerVC.view removeFromSuperview];
        
        _customSpinnerVC = nil;
   });
}

@end
