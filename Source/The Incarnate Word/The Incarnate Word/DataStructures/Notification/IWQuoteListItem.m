//
//  IWQuoteListItem.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 12/12/16.
//  Copyright © 2016 Revealing Hour Creations. All rights reserved.
//

#import "IWQuoteListItem.h"

@implementation IWQuoteListItem
/*
 
 @property(nonatomic)    NSString    *strRefUrl;
 @property(nonatomic)    NSString    *strSelText;
 @property(nonatomic)    NSString    *strAuth;
 @property(nonatomic)    NSArray     *arrTags;
 */

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_strRefUrl forKey:@"strRefUrl"];
    [encoder encodeObject:_strSelText forKey:@"strSelText"];
    [encoder encodeObject:_strAuth forKey:@"strAuth"];
    [encoder encodeObject:_arrTags forKey:@"arrTags"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init])
    {
        _strRefUrl = [decoder decodeObjectForKey:@"strRefUrl"];
        _strSelText = [decoder decodeObjectForKey:@"strSelText"];
        _strAuth = [decoder decodeObjectForKey:@"strAuth"];
        _arrTags = [decoder decodeObjectForKey:@"arrTags"];
    }
    
    return self;
}

@end
