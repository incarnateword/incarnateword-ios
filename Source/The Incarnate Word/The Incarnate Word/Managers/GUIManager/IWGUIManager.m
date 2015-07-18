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

@interface IWGUIManager()<UINavigationControllerDelegate>
{
    
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
    self.drawerController.showsShadow = YES;
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


#pragma mark - Drawer Utiliy

- (void) drawerHideLeft
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    MMDrawerController *drawerVC = (MMDrawerController*) window.rootViewController;
    
    if(drawerVC.openSide == MMDrawerSideLeft)
    {
        [drawerVC toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
    }
}


- (void) drawerToggleLeft
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    MMDrawerController *drawerVC = (MMDrawerController*) window.rootViewController;
    [drawerVC toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}


-(void) forceOnRoot:(UINavigationController *) centerNavController
{
    //Dismiss View controller that was presented modally if any
    if(nil != centerNavController.presentedViewController)
        [centerNavController dismissViewControllerAnimated:YES completion:nil];
    
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
                           [drawerVC toggleDrawerSide:MMDrawerSideLeft animated:NO completion:nil];
                       }
                       
                       if(forceOnRoot == YES)
                       {
                           [self forceOnRoot:centerNavController];
                       }
                       
                       [centerNavController pushViewController:viewController animated:NO];
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

#pragma mark -
#pragma mark UINavigationController delegate

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController class] == [IWHomeViewController class])
    {
        return ;
    }
    
    UIButton *customLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    customLeftBtn.bounds = CGRectMake( 10, 0, 40, 40 );
    [customLeftBtn addTarget:self action:@selector(btnDrawerClicked) forControlEvents:UIControlEventTouchUpInside];
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
}

-(void)btnDrawerClicked
{
//    UINavigationController* navigation = (UINavigationController*)self.drawerController.centerViewController ;
//    [navigation popViewControllerAnimated:NO] ;
    
    [self drawerToggleLeft];
}

-(IWInfoViewController*)getInfoViewControllerForText:(NSString*) strText
{
    UIStoryboard *sbPopover = [UIStoryboard storyboardWithName:STORYBOARD_POPOVER bundle:nil];
    IWInfoViewController *infoVC = [sbPopover instantiateViewControllerWithIdentifier:S_POPOVER_INFO_VC];
    infoVC.strText = strText;
    
    return infoVC;
}

@end
