//
//  IWQuoteItem.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 12/12/16.
//  Copyright © 2016 Revealing Hour Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWQuoteItem : NSObject
/*
 
 {
 "t": "Letters on Yoga - III",
 "comp": "sabcl",
 "vol": "24",
 "list":
 */

@property(nonatomic)    NSString    *strTitle;
@property(nonatomic)    NSString    *strCompilation;
@property(nonatomic)    int         volume;
@property(nonatomic)    NSArray     *arrListItems;


@end
