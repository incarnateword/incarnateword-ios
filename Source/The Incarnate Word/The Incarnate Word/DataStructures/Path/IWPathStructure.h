//
//  IWPathStructure.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 18/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWPathStructure : NSObject

/*
 {
 "t": "SABCL",
 "u": "/sabcl"
 }
 */

@property(readwrite) NSString *strTitle;
@property(readwrite) NSString *strUrl;

@end
