//
//  IWQuoteItem.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 12/12/16.
//  Copyright © 2016 Revealing Hour Creations. All rights reserved.
//

#import "IWQuoteItem.h"

@implementation IWQuoteItem

/*
 @property(nonatomic)    NSString    *strTitle;
 @property(nonatomic)    NSString    *strCompilation;
 @property(nonatomic)    int         volume;
 @property(nonatomic)    NSArray     *arrListItems;
 */

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_strTitle forKey:@"strTitle"];
    [encoder encodeObject:_strCompilation forKey:@"strCompilation"];
    [encoder encodeObject:_volume forKey:@"volume"];
    [encoder encodeObject:_arrListItems forKey:@"arrListItems"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init])
    {
        _strTitle = [decoder decodeObjectForKey:@"strTitle"];
        _strCompilation = [decoder decodeObjectForKey:@"strCompilation"];
        _volume = [decoder decodeObjectForKey:@"volume"];
        _arrListItems = [decoder decodeObjectForKey:@"arrListItems"];
    }
    
    return self;
}
@end
