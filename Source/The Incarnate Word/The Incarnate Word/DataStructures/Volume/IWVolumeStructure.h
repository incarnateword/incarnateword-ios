//
//  IWVolumeStructure.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWVolumeStructure : NSObject

/*
 
 {
 "vol": "01",
 "t": "Bande Mataram",
 "url": "sabcl/01"
 }

 */

@property(readwrite) NSString *strIndex;
@property(readwrite) NSString *strTitle;
@property(readwrite) NSString *strUrl;


@end
