//
//  IWDictionaryWebService.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 30/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWDictionaryWebService.h"
#import "IWAlphabetStructure.h"
#import "IWWordStructure.h"

@implementation IWDictionaryWebService

-(id)initWithDelegate:(id<WebServiceDelegate>)delegate
{
    self = [super initWithRequest:@"entries.json" header:nil body:nil RequestType:@"GET"];
    
    if (self)
    {
        [self setCustomBaseUrl:@"http://dictionary.incarnateword.in"];
        self.delegate = delegate;
    }
    return self ;
    
}
/*
 {
 "entries": {
 "t": "Dictionary",
 "list": [
 {
 "a": "a",
 "w": [
 {
 "w": "aberrations"
 },
 {
 "w": "abhorred"
 },
 {
 "w": "abject"
 },
 {
 "w": "abnegation"
 },
 {
 "w": "abode"
 },
 {
 "w": "absolute",
 "r": "absolutes,absoluteness"
 },
 {
 "w": "absolute reality",
 "u": "absolute-reality"
 },
 {
 "w": "abstruse"
 },
 {
 "w": "abysmal"
 },
 {
 "w": "accomplice"
 },
 {
 "w": "accord"
 },
 {
 "w": "accursed"
 },
 {
 "w": "action",
 "r": "action’s,actions,self-action"
 },
 
 */
-(void)parseResponse:(NSDictionary*)response
{
    NSArray *list = [[response objectForKey:@"entries"] objectForKey:@"list"];
    
    if(list && list.count > 0)
    {
        NSMutableArray *arrOfAlphabets = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in list)
        {
            IWAlphabetStructure *alpha = [[IWAlphabetStructure alloc] init];
            alpha.strAlphabet = [dict objectForKey:@"a"];
            
            if([dict objectForKey:@"w"])
            {
                NSArray *arrWordDict = [dict objectForKey:@"w"];
                NSMutableArray *arrWord = [[NSMutableArray alloc] init];
                
                for (NSDictionary *dict in arrWordDict)
                {
                    IWWordStructure *word = [[IWWordStructure alloc] init];
                    word.strWord = [dict objectForKey:@"w"];
                    word.strUrl = [dict objectForKey:@"u"];
                    [arrWord addObject:word];
                }
                
                alpha.arrWords = arrWord;
            }
            
            [arrOfAlphabets addObject:alpha];
        }
        
        [self sendResponse:[arrOfAlphabets copy]];
    }
}


#pragma mark-
#pragma mark Call back  to caller

-(void) sendResponse:(id)response
{
    if ([self.delegate respondsToSelector:@selector(requestSucceed:response:)])
    {
        [self.delegate requestSucceed:self response:response];
    }
}

-(void) handleError:(WSError*)error
{
    if ([self.delegate respondsToSelector:@selector(requestFailed:error:)])
    {
        [self.delegate requestFailed:self error:error];
    }
}
@end
