//
//  IWDetailChapterStructure.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWDetailChapterStructure.h"

@implementation IWDetailChapterStructure

-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_strDescription forKey:@"strDescription"];
    [encoder encodeObject:_strDate forKey:@"strDate"];
    [encoder encodeObject:_strNextChapter forKey:@"strNextChapter"];
    [encoder encodeObject:_strNextChapterUrl forKey:@"strNextChapterUrl"];
    [encoder encodeObject:_strPrevChapter forKey:@"strPrevChapter"];
    [encoder encodeObject:_strPrevChapterUrl forKey:@"strPrevChapterUrl"];
//    [encoder encodeObject:_arrPath forKey:@"arrPath"];
    [encoder encodeObject:_strTitle forKey:@"strTitle"];
    [encoder encodeObject:_strUrl forKey:@"strUrl"];
    [encoder encodeObject:_strText forKey:@"strText"];
    [encoder encodeObject:_strTextParsed forKey:@"strTextParsed"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init])
    {
        _strDescription = [decoder decodeObjectForKey:@"strDescription"];
        _strDate = [decoder decodeObjectForKey:@"strDate"];
        _strNextChapter = [decoder decodeObjectForKey:@"strNextChapter"];
        _strNextChapterUrl = [decoder decodeObjectForKey:@"strNextChapterUrl"];
        _strPrevChapter = [decoder decodeObjectForKey:@"strPrevChapter"];
        _strPrevChapterUrl = [decoder decodeObjectForKey:@"strPrevChapterUrl"];
//        _arrPath = [decoder decodeObjectForKey:@"arrPath"];
        _strTitle = [decoder decodeObjectForKey:@"strTitle"];
        _strUrl = [decoder decodeObjectForKey:@"strUrl"];
        _strText = [decoder decodeObjectForKey:@"strText"];
        _strTextParsed = [decoder decodeObjectForKey:@"strTextParsed"];
    }
    
    return self;
}

@end
