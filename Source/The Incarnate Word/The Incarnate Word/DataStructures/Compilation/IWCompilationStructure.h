//
//  IWCompilationStructure.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWCompilationStructure : NSObject

/*
"compilation": {
    "cmpn": "Sri Aurobindo Birth Centenary Library",
    "comp": "sabcl",
    "autn": "Sri Aurobindo",
    "auth": "sa",
    "curl": "sabcl",
    "desc": "",
    "vols": [
             {
                 "vol": "01",
                 "t": "Bande Mataram",
                 "url": "sabcl/01"
             },
 
 */

@property(readwrite) NSString *strTitle;
@property(readwrite) NSString *strAuthName;
@property(readwrite) NSString *strUrl;
@property(readwrite) NSArray *arrVolumes;


@end
