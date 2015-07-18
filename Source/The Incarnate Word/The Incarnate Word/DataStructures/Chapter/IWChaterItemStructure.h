//
//  IWChaterItemStructure.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 23/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWChaterItemStructure : NSObject

/*
 {
 "itemt": "The Failure of Europe",
 "u": "notes-and-comments#the-failure-of-europe"
 },
 */

@property(readwrite) NSString   *strTitle;
@property(readwrite) NSString   *strUrl;
@property(readwrite) NSString   *strUrlParentChapter;//Additional added parameter for easy data display
@property(readwrite) int        iItemIndex;//Additional added parameter for easy data display


@end
