//
//  IWUtility.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "BPMarkdownView.h"
#import "BPDisplaySettings.h"

#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


@interface IWUtility : NSObject

+(BOOL)isDeviceTypeIpad;
+(BOOL)isNilOrEmptyString : (NSString *)aString;

+(NSAttributedString*)getMarkdownNSAttributedStringFromNSString:(NSString*)str;

+(BPMarkdownView*)getMarkdownViewOfFrame:(CGRect) rect
             withCustomBPDisplaySettings: (BPDisplaySettings*) customBPSettings;

+(int)getDrawerWidth;
+(UIColor*)getNavBarColor;
+(UIImage *)getBlurredImage:(UIImage *)image;
+(UIImage *)imageWithColor:(UIColor *)color;
+(void)showWebserviceFailedAlert;
@end
