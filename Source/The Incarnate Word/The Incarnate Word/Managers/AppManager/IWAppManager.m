//
//  IWAppManager.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWAppManager.h"
#import "IWGUIManager.h"

@implementation IWAppManager

static IWAppManager* appManager = nil ;

#pragma mark - Singlton instance creation

+(void)initialize
{
    if (!appManager)
    {
        NSLog(@"initialize !!!!");

        appManager = [[IWAppManager alloc] init] ;
    }
}


+(IWAppManager *)sharedManager
{
    return appManager;
}


-(id) init
{
    if (nil == appManager)
    {
        appManager = [super init];

        NSLog(@"HERE !!!!");
        [self initializeApplication];
        
    }
    
    return appManager ;
}

-(void)initializeApplication
{
    [IWGUIManager sharedManager];

}

@end
