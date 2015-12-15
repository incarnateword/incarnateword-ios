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

@implementation IWSearchWebService


-(id)initWithSearchString:(NSString*) strSearch AndDelegate:(id<WebServiceDelegate>)delegate;
{
    self = [super initWithRequest:[NSString stringWithFormat:@"search.json?q=%@",strSearch] header:nil body:nil RequestType:@"GET"];
    
    if (self)
    {
//        [self setCustomBaseUrl:@"http://dictionary.incarnateword.in"];
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
