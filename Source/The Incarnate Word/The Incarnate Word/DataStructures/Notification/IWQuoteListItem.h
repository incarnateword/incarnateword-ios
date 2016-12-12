//
//  IWQuoteListItem.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 12/12/16.
//  Copyright © 2016 Revealing Hour Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWQuoteListItem : NSObject

/*
 {
 "ref": "http://incarnateword.in/sabcl/24/difficulties-of-the-path-vii#p13",
 "sel": "\u003cp\u003eSuicide is an absurd solution; he is quite mistaken in thinking that it will give him peace. He will only carry his difficulties with him into a more miserable condition of existence beyond and bring them back to another life on earth. The only remedy is to shake off these morbid ideas and face life with a clear will for some definite work to be done as the life’s aim and with a quiet and active courage.\u003c/p\u003e",
 "auth": "sa",
 "tags": ["suicide"]
 }
 */

@property(nonatomic)    NSString    *strRefUrl;
@property(nonatomic)    NSString    *strSelText;
@property(nonatomic)    NSString    *strAuth;
@property(nonatomic)    NSArray     *arrTags;

@end
