//
//  IWBookStructure.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 07/06/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWBookStructure : NSObject

@property(readwrite) NSString   *strTitle;
@property(readwrite) NSArray    *arrChapters;
@property(readwrite) NSArray    *arrParts;


-(NSArray *)getChaptersAndItemsFromBookArray;

@end
