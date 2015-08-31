//
//  IWUtility.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWUtility.h"
#import "NSAttributedStringMarkdownParser.h"
#import "IWUIConstants.h"
#import <JavaScriptCore/JavaScriptCore.h>

@implementation IWUtility

+(BOOL)isDeviceTypeIpad
{
    if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad)
        return YES;
    
    return NO;
}

+(float)getNumberAsPerScalingFactor:(float) originalNumber
{
    if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad)
        return originalNumber*1.3;
    
    return originalNumber;
}

+ (BOOL) isNilOrEmptyString : (NSString *)aString
{
    BOOL status = NO;
    @try
    {
        if(aString != nil && (aString != (id)[NSNull null]))
        {
            NSString *aTempString = [aString stringByTrimmingCharactersInSet:
                                     [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if([aTempString compare:@""] == NSOrderedSame)
            {
                status = YES;
            }
        }
        else
        {
            status = YES;
        }
    }
    @catch (NSException *exception)
    {
        @throw exception;
    }
    
    return  status;
}

+(NSAttributedString*)getMarkdownNSAttributedStringFromNSString:(NSString*)str
{
    /**
     https://github.com/NimbusKit/markdown
     https://github.com/NimbusKit/memorymapping
     **/
    
    /*
     self.defaultFont =         [UIFont fontWithName:FONT_BODY_REGULAR size:systemFontSize + 4.0];//[UIFont systemFontOfSize:systemFontSize]; //ADITYA
     
     self.boldFont = [UIFont fontWithName:FONT_BODY_SEMIBOLD size:systemFontSize + 4.0];//[UIFont boldSystemFontOfSize:systemFontSize]; //ADITYA
     self.italicFont =  [UIFont fontWithName:FONT_BODY_ITALIC size:systemFontSize + 4.0];//[UIFont italicSystemFontOfSize:systemFontSize]; //ADITYA

     */
    NSAttributedStringMarkdownParser* parser = [[NSAttributedStringMarkdownParser alloc] init];
    parser.boldFontName = FONT_BODY_BOLD;
    parser.boldItalicFontName = FONT_BODY_ITALIC;
    parser.italicFontName = FONT_BODY_ITALIC;
    parser.codeFontName = FONT_BODY_REGULAR;
    parser.paragraphFont = [UIFont fontWithName:FONT_BODY_REGULAR size:[UIFont systemFontSize] + 4.0];
    NSAttributedString* string = [parser attributedStringFromMarkdownString:str];
    return string;
}


+(BPMarkdownView*)getMarkdownViewOfFrame:(CGRect) rect withCustomBPDisplaySettings: (BPDisplaySettings*) customBPSettings
{
    BPMarkdownView *markdownView = [[BPMarkdownView alloc] initWithFrame:rect];
    BPDisplaySettings *bpSettings = [[BPDisplaySettings alloc] init];
    markdownView.displaySettings = customBPSettings != nil ? customBPSettings : bpSettings;
    markdownView.backgroundColor = COLOR_MARKDOWN_VIEW_BG;
    
    markdownView.bounces = NO;
    
    return markdownView;
}

+(int)getDrawerWidth
{
    return [IWUtility isDeviceTypeIpad] ? 420 : 250;
}

+(UIColor*)getNavBarColor
{
   return COLOR_NAV_BAR;
}

+ (UIImage *)getBlurredImage:(UIImage *)image
{
    CIImage *inputImage = [CIImage imageWithCGImage:image.CGImage];
    
    // offset for blur effect
    int blur = 5;
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"
                                  keysAndValues:kCIInputImageKey, inputImage,
                        @"inputRadius", @(blur),
                        nil];
    
    CIImage *outputImage = filter.outputImage;
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef blurrImage = [context createCGImage:outputImage
                                          fromRect:[outputImage extent]];
    return [UIImage imageWithCGImage:blurrImage];
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 600.0f, 500.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+(void)showWebserviceFailedAlert
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STR_NO_NETWORK_ALERT_TITLE
                                                    message:STR_NO_NETWORK_ALERT_MESSAGE
                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
}

+(float)getHorizontalSpaceBetweenButtons
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    float space = rect.size.width / 3 - 50 -16;
    
    return space;
}

+(NSString*)getHtmlStringUsingJSLibForMarkdownText:(NSString*) strMarkdownText
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"marked-feature-footnotes/lib/marked" ofType:@"js"];
    NSString *jsScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    JSContext *context = [[JSContext alloc] init];
    [context evaluateScript: jsScript];
    JSValue  *jsFunction = context[@"marked"];
    NSLog(@"Parsing Start");
    JSValue* result = [jsFunction callWithArguments:@[strMarkdownText]];
    NSLog(@"Parsing End");
    
    NSLog(@"JSValue Conversion Start");
     NSString  *strFinalHtml = [result toString];
    NSLog(@"JSValue Conversion End");
    NSString *strCssHead = [NSString stringWithFormat:@"<head>"
    "<link rel=\"stylesheet\" type=\"text/css\" href=\"%@\">"
    "</head>"
    "<body>",[IWUtility getCssFileName]];
    NSMutableString *strMutString = [[NSMutableString alloc] initWithString:strCssHead];
    [strMutString appendString:strFinalHtml];
    [strMutString appendString:@"</body>"];
    
    NSLog(@"~~~~~~~~~~~%@~~~~~~~~~~~",[strMutString copy]);
    return [strMutString copy];
}

+(NSURL*)getCommonCssBaseURL
{
  return [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:[IWUtility getCssFileName] ofType:@""]];
}

+(NSString*)getCssFileName
{
    if([IWUtility isDeviceTypeIpad])
        return @"iPad.css";
    
    return @"iPhone.css";
}

@end
