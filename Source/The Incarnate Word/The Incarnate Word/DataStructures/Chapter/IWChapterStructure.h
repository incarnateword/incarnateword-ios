//
//  IWChapter.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWChapterStructure : NSObject

/*
 "chapt": "Notes and Comments",
 "u": "notes-and-comments",
 "items": [
 {
 "itemt": "The Message of India",
 "u": "notes-and-comments#the-message-of-india"
 },
 {
 */

@property(readwrite) NSString   *strTitle;
@property(readwrite) NSString   *strUrl;
@property(readwrite) NSArray    *arrChapterItems;
@property(readwrite) NSArray    *arrChapterSegments;

@end
