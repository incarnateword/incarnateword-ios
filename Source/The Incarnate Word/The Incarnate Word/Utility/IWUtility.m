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


@implementation IWUtility

+(BOOL)isDeviceTypeIpad
{
    if([[UIDevice currentDevice] userInterfaceIdiom]==UIUserInterfaceIdiomPad)
        return YES;
    
    return NO;
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


+(BPMarkdownView*)getMarkdownViewOfFrame:(CGRect) rect
{
    BPMarkdownView *markdownView = [[BPMarkdownView alloc] initWithFrame:rect];
    markdownView.backgroundColor = [UIColor clearColor];
    BPDisplaySettings *bpSettings = [[BPDisplaySettings alloc] init];
    bpSettings.defaultColor = [UIColor redColor];
    bpSettings.defaultFont = [UIFont fontWithName:@"Helevetica-Light" size:15.0];
    markdownView.displaySettings = bpSettings;
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

@end
