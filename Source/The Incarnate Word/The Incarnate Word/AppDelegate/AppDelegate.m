//
//  AppDelegate.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 16/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "AppDelegate.h"
#import "IWAppManager.h"
#import "IWUIConstants.h"
#import "The_Incarnate_Word-Swift.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [IWAppManager sharedManager];
    
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    
    UILocalNotification *locationNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (locationNotification)
    {
        [[IWNotificationModel sharedInstance] showRandomQuote];
        application.applicationIconBadgeNumber = 0;
    }
    
    
    return YES;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    CGPoint location = [[[event allTouches] anyObject] locationInView:[self window]];
    if (CGRectContainsPoint([UIApplication sharedApplication].statusBarFrame, location))
    {
        NSLog(@"STATUS BAR TAPPED!");
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_STATUS_BAR_TAPPED object:nil];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    UIApplicationState state = [application applicationState];
    
    if (state == UIApplicationStateActive) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Daily Quotes"
                                                        message:notification.alertBody
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Ok",nil];
        alert.tag = 123;
        [alert show];
    }
    else
    {
        [[IWNotificationModel sharedInstance] showRandomQuote];
    }
    
    // Set icon badge number to zero
    application.applicationIconBadgeNumber = 0;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 123)
    {
        if([[alertView buttonTitleAtIndex:buttonIndex]isEqual:@"Ok"])
        {
            [[IWNotificationModel sharedInstance] showRandomQuote];
        }
    }
}

@end
