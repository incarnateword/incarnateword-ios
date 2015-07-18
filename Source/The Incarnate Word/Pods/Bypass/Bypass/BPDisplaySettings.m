//
// Created by Audun Holm Ellertsen on 4/30/13.
// Copyright (c) 2013 Uncodin. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreText/CoreText.h>
#import "BPDisplaySettings.h"

#define FONT_TITLE_REGULAR @"CharlotteSansW02-Book"
#define FONT_TITLE_MEDIUM @"CharlotteSansW02-Medium"
#define FONT_TITLE_ITALIC @"CharlotteSansW02-BookItalic"

#define FONT_BODY_BOLD @"MonotypeSabonW04-SemiBold"
#define FONT_BODY_ITALIC @"MonotypeSabonW04-Italic"
#define FONT_BODY_REGULAR @"MonotypeSabonW04-Regular"
#define FONT_BODY_SEMIBOLD @"MonotypeSabonW04-SemiBdItal"


@implementation BPDisplaySettings

- (id)init
{
    self = [super init];
    if (self) {
        CGFloat systemFontSize = [UIFont systemFontSize];
        
        self.defaultFont =         [UIFont fontWithName:FONT_BODY_REGULAR size:systemFontSize + 4.0];//[UIFont systemFontOfSize:systemFontSize]; //ADITYA
        
        self.boldFont = [UIFont fontWithName:FONT_BODY_SEMIBOLD size:systemFontSize + 4.0];//[UIFont boldSystemFontOfSize:systemFontSize]; //ADITYA
        self.italicFont =  [UIFont fontWithName:FONT_BODY_ITALIC size:systemFontSize + 4.0];//[UIFont italicSystemFontOfSize:systemFontSize]; //ADITYA
        self.monospaceFont = [UIFont fontWithName:FONT_BODY_REGULAR size:systemFontSize - 2.f];
        self.quoteFont = [UIFont fontWithName:FONT_BODY_ITALIC size:systemFontSize + 4.0];
        self.h1Font = [UIFont fontWithName:FONT_TITLE_REGULAR size:systemFontSize * 2.f];//[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:systemFontSize * 2.f]; //ADITYA
        self.h2Font = [UIFont fontWithName:FONT_TITLE_REGULAR size:systemFontSize * 1.8f];//[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:systemFontSize * 1.8f]; //ADITYA
        self.h3Font = [UIFont fontWithName:FONT_TITLE_REGULAR size:systemFontSize * 1.6f];//[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:systemFontSize * 1.6f]; //ADITYA
        self.h4Font = [UIFont fontWithName:FONT_TITLE_REGULAR size:systemFontSize * 1.4f];//[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:systemFontSize * 1.4f]; //ADITYA
        self.h5Font = [UIFont fontWithName:FONT_TITLE_REGULAR size:systemFontSize * 1.2f];//[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:systemFontSize * 1.2f]; //ADITYA
        self.h6Font = [UIFont fontWithName:FONT_TITLE_REGULAR size:systemFontSize];//[UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:systemFontSize]; //ADITYA
        
        self.defaultColor = [UIColor blackColor];
        self.quoteColor = [UIColor darkGrayColor];
        self.codeColor = [UIColor grayColor];
        self.linkColor = [UIColor blueColor];
        self.bulletIndentation = 13.0f;
        self.codeIndentation = 10.0f;
        self.quoteIndentation = 23.0f;
        self.paragraphSpacing = 20.0f;
        self.paragraphSpacingHeading = 10.0f;
        self.paragraphSpacingCode = 0.0f;
        
        self.paragraphLineSpacing = 1.2f;
        self.paragraphLineSpacingHeading = 1.2f;
        
    }
    return self;
}

- (UIFont *)boldItalicFont
{
    if (_boldItalicFont == nil) {
        CTFontRef defaultFontRef = [self newCTFontRefFromUIFont:self.defaultFont];
        CTFontSymbolicTraits traits = kCTFontBoldTrait | kCTFontItalicTrait;
        CTFontSymbolicTraits mask = kCTFontBoldTrait | kCTFontItalicTrait;
        CTFontRef boldItalicFontRef = CTFontCreateCopyWithSymbolicTraits(defaultFontRef, 0.f, NULL, traits, mask);
        assert(boldItalicFontRef != NULL);
        
        _boldItalicFont = [self UIFontFromCTFont:defaultFontRef];
        CFRelease(defaultFontRef);
    }
    
    return _boldItalicFont;
}

#pragma mark - Private

- (UIFont *)UIFontFromCTFont:(CTFontRef)ctFont
{
    NSString *fontName = (__bridge_transfer NSString *) CTFontCopyName(ctFont, kCTFontPostScriptNameKey);
    CGFloat fontSize = CTFontGetSize(ctFont);
    
    return [UIFont fontWithName:fontName size:fontSize];
}

- (CTFontRef)newCTFontRefFromUIFont:(UIFont *)font
{
    return CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
}
@end