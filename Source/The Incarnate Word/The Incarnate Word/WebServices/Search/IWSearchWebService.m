//
//  IWSearchWebService.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 13/12/15.
//  Copyright © 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWSearchWebService.h"
#import "IWSearchItemStructure.h"
#import "IWSearchStructure.h"
#import "IWUtility.h"

@implementation IWSearchWebService


-(id)initWithSearchString:(NSString*) strSearch
            AndStartIndex:(int) start
              AndDelegate:(id<WebServiceDelegate>)delegate
{
    self = [super initWithRequest:[NSString stringWithFormat:@"search.json?q=%@&start=%d",strSearch,start] header:nil body:nil RequestType:@"GET"];
    
    if (self)
    {
//        [self setCustomBaseUrl:@"http://dictionary.incarnateword.in"];
        self.delegate = delegate;
    }
    return self ;
}

//http://incarnateword.in/search?q=india&auth=m&comp=cwm&vol=01

-(id)initWithSearchString:(NSString*) strSearch
                AndAuther:(NSString*) strAuther
           AndCompilation:(NSString*) strCollection
                AndVolume:(NSString*) strVolume
            AndStartIndex:(int) start
              AndDelegate:(id<WebServiceDelegate>)delegate
{
    self = [super initWithRequest:[NSString stringWithFormat:@"search.json?q=%@&start=%d&auth=%@&comp=%@&vol=%@",strSearch,start,strAuther,strCollection,strVolume]
                           header:nil
                             body:nil
                      RequestType:@"GET"];
    
    if (self)
    {
        //        [self setCustomBaseUrl:@"http://dictionary.incarnateword.in"];
        self.delegate = delegate;
    }
    return self ;
}


-(id)initWithSearchYear:(NSString*) strYear
              WithMonth:(NSString*) strMonth
               WithDate:(NSString*) strDate
              AndAuther:(NSString*) strAuther
          AndStartIndex:(int) start
            AndDelegate:(id<WebServiceDelegate>)delegate
{
    
    NSMutableString *strQuery = [[NSMutableString alloc] initWithString:strYear];
    
    if([IWUtility isNilOrEmptyString:strMonth] == NO)
    {
        [strQuery appendString:[NSString stringWithFormat:@"/%@",strMonth]];
        
        if([IWUtility isNilOrEmptyString:strDate] == NO)
        {
            [strQuery appendString:[NSString stringWithFormat:@"/%@",strDate]];
        }
    }
    
    if([IWUtility isNilOrEmptyString:strAuther] == NO)
    {
        [strQuery appendString:[NSString stringWithFormat:@"/%@",strAuther]];
    }
    
    [strQuery appendString:[NSString stringWithFormat:@".json?start=%d",start]];
    
    self = [super initWithRequest:[strQuery copy]
                           header:nil
                             body:nil
                      RequestType:@"GET"];
    
    if (self)
    {
        self.delegate = delegate;
    }
    return self ;
}


/*
 {
 "query":
 {
 
 "records": 1840,
 "size": 10,
 
 
 "query": "india",
 "results": [{
 "_source":
         {
         "nxtt": "Nations Other than India",
         "nxtu": "/cwm/13/nations-other-than-india",
         "path": [{
                 "t": "CWM",
                 "u": "/cwm"
                 }, {
                 "t": "Words of the Mother - I",
                 "u": "/cwm/13"
                 }, {
                 "t": "India"
                 }],
         "prvt": "Talk of 30 March 1972",
         "prvu": "/cwm/13/talk-of-30-march-1972",
         "subt": null,
         "t": "India",
         "url": "/cwm/13/india",
         "yr": null,
         "yre": null,
         "yrs": null
         },
 "highlight": {
 "txt": ["(*On 2 June 1947 Lord Louis Mountbatten, the Viceroy of \u003cem\u003eIndia\u003c/em\u003e, delivered a radio speech proposing", " the partition of Pakistan from \u003cem\u003eIndia\u003c/em\u003e, and of certain other parts of \u003cem\u003eIndia\u003c/em\u003e into Hindu and Muslim", " spite of all, \u003cem\u003eIndia\u003c/em\u003e has a single soul and while we have to wait till we can speak of an \u003cem\u003eIndia\u003c/em\u003e one", " and indivisible, our cry must be:\n\nLet the soul of \u003cem\u003eIndia\u003c/em\u003e live forever!\n\n*3 June 1947*\n\n---\n\nThe Soul", " of \u003cem\u003eIndia\u003c/em\u003e is one and indivisible. \u003cem\u003eIndia\u003c/em\u003e is conscious of her mission in the world. She is waiting for"]
 }
 }, {
 "_index": "chapters",
 "_type": "chapter",
 "_source": {
 "nxtt": "The Pilot - Atulprasad Sen",
 "nxtu": "/cwsa/05/the-pilot-atulprasad-sen",
 "ordr": null,
 "path": [{
 "t": "CWSA",
 "u": "/cwsa"
 }, {
 "t": "Translations",
 "u": "/cwsa/05"
 }, {
 "t": "Translations from Bengali"
 }, {
 "t": "Disciples and Others"
 }],
 "prvt": "Hymn to India - Dwijendralal Roy",
 "prvu": "/cwsa/05/hymn-to-india-dwijendralal-roy",
 "subt": null,
 "t": "Mother India - Dwijendralal Roy",
 "txt": null,
 "type": null,
 "url": "/cwsa/05/mother-india-dwijendralal-roy",
 "yr": 1932,
 "yre": null,
 "yrs": null
 },
 "highlight": {
 "items.txt": ["Mother \u003cem\u003eIndia\u003c/em\u003e, when Thou rosest from the depths of oceans hoary,\nLove and joy burst forth unbounded", " tragic night,\nMother \u003cem\u003eIndia\u003c/em\u003e, great World-Mother! O World-Saviour, World's Delight!\nEarth became"]
 }
 },
 
 
 
 ///DATE SEARCH
 
 {
	"query": {
 "query": "/1973",
 "query_alt": "In 1973",
 "results": [{
 "_source": {
 "path": [{
 "u": "/cwm",
 "t": "CWM"
 }, {
 "u": "/cwm/12",
 "t": "On Education"
 }, {
 "t": "Messages, Letters and Conversations"
 }, {
 "t": "Conversations"
 }],
 "url": "/cwm/12/18-february-1973"
 },
 "highlight": {
 "txt": ["A: Tonight, I am going to read you a letter from X. She gave us a letter about her class. You know that this year she has started working with the young children. Oh! A: So this is what she"],
 "t": ["18 February 1973"]
 }
 }
 
 
 */
-(void)parseResponse:(NSDictionary*)response
{
    NSArray *list = [[response objectForKey:@"query"] objectForKey:@"results"];
    NSMutableArray  *arrSearchResult = [[NSMutableArray alloc] init];
    IWSearchStructure   *searchResult = [IWSearchStructure new];

    if(list && list.count > 0)
    {
        
        for (NSDictionary *dict in list)
        {
            IWSearchItemStructure *searchItem = [[IWSearchItemStructure alloc] init];
            
            if([dict objectForKey:@"highlight"])
            {
                NSDictionary *dictHighlight = [dict objectForKey:@"highlight"];
                
                if([dictHighlight objectForKey:@"txt"])
                {
                    searchItem.arrHighlightText = [dictHighlight objectForKey:@"txt"];
                }
                else if([dictHighlight objectForKey:@"items.txt"])
                {
                    searchItem.arrHighlightText = [dictHighlight objectForKey:@"items.txt"];
                }
            }
            
            if([dict objectForKey:@"_source"])
            {
                NSDictionary *dictSource    = [dict objectForKey:@"_source"];
                searchItem.strTitle         = [dictSource objectForKey:@"t"];
                searchItem.strChapterUrl    = [dictSource objectForKey:@"url"];
                
                if(searchItem.arrHighlightText == nil && [dictSource objectForKey:@"txt"] )
                {
                    searchItem.arrHighlightText = [[NSArray alloc] initWithObjects:[dictSource objectForKey:@"txt"], nil];
                }
            }
            
            if( searchItem.strTitle == nil)//Date search
            {
                
                if([dict objectForKey:@"highlight"])
                {
                    NSDictionary *dictHighlight = [dict objectForKey:@"highlight"];
                 
                    if([dictHighlight objectForKey:@"t"])
                    {
                        NSArray *arrTitle = [dictHighlight objectForKey:@"t"];
                        
                        if(arrTitle.count > 0)
                        {
                            searchItem.strTitle = arrTitle.firstObject;
                        }
                    }
                }
            
            }
            
            [arrSearchResult addObject:searchItem];
        }
        
        searchResult.arrSearchItems = [arrSearchResult copy];
        searchResult.iCountRecord = [[[response objectForKey:@"query"] objectForKey:@"records"] intValue];
        searchResult.iPageSize = [[[response objectForKey:@"query"] objectForKey:@"size"] intValue];
    }

    [self sendResponse:searchResult];

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
