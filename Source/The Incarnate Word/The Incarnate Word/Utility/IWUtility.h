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
+(float)getNumberAsPerScalingFactor:(float) originalNumber;
+(BOOL)isNilOrEmptyString : (NSString *)aString;

//Markdowns

/**
 Nimbus Lib
 https://github.com/NimbusKit/markdown
 https://github.com/NimbusKit/memorymapping
 **/

+(NSAttributedString*)getMarkdownNSAttributedStringFromNSString:(NSString*)str;

/**
 Marked JS lib 
 https://github.com/chjj/marked
 https://github.com/prashaantt/marked/tree/feature-footnotes
 **/

+(NSString*)getHtmlStringUsingJSLibForMarkdownText:(NSString*) strMarkdownText
                                    forTypeHeading:(BOOL)bTypeHeading;
+(NSURL*)getCommonCssBaseURL;

/**
Bipass Markdown lib
 https://github.com/Uncodin/bypass-ios
 **/

+(BPMarkdownView*)getMarkdownViewOfFrame:(CGRect) rect
             withCustomBPDisplaySettings: (BPDisplaySettings*) customBPSettings;

+(int)getDrawerWidth;
+(UIColor*)getNavBarColor;
+(UIImage *)getBlurredImage:(UIImage *)image;
+(UIImage *)imageWithColor:(UIColor *)color;
+(void)showWebserviceFailedAlert;
+(float)getHorizontalSpaceBetweenButtons;

//Search result highlighted string
+(NSAttributedString*)getAttributedSearchResultStringForSearchText:(NSString*)searchText AndResultStringArray:(NSArray*) arrResultString;
@end
