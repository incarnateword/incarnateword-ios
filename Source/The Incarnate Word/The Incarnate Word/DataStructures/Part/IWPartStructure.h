//
//  IWPartStructure.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWPartStructure : NSObject

/*
 {
 "partt": "1890-1905",
 "chapters": [
 {
 "chapt": "India Renascent",
 "u": "india-renascent"
 }],
},
 
 {
 "partt": "The Upanishads",
 "part": "Part II",
 "sections": [
 {
 "sect": "Isha Upanishad",
 "chapters": [
 {
 "chapt": "Isha Upanishad",
 "u": "isha-upanishad"
 }
 ]
 },
 */
@property(readwrite) NSString   *strTitle;
@property(readwrite) NSArray    *arrChapters;
@property(readwrite) NSArray    *arrSections;

@end
