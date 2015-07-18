//
//  IWAboutWebService.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 30/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWAboutWebService.h"
#import "IWAboutStructure.h"
#import "IWCompilationStructure.h"

@implementation IWAboutWebService

-(id)initWithPath:(NSString*) strPath AndDelegate:(id<WebServiceDelegate>)delegate
{
    self = [super initWithRequest:[NSString stringWithFormat:@"%@.json",strPath] header:nil body:nil RequestType:@"GET"];
    if (self)
    {
        self.delegate = delegate;
    }
    return self ;
    
}

/*
 
 {
 "author": 
    {
     "auth": "sa",
     "autn": "Sri Aurobindo",
     "comp": [
     {
     "t": "The Complete Works of Sri Aurobindo",
     "u": "cwsa"
     },
     {
     "t": "Sri Aurobindo Birth Centenary Library",
     "u": "sabcl"
     }
     ],
     "desc": "What Sri Aurobindo represents in the world's history is not a teaching, not even a revelation; it is a decisive action direct from the Supreme.\n\n---\n\nSri Aurobindo has come on earth not to bring a teaching or a creed in competition with previous creeds or teachings, but to show the way to overpass the past and to open concretely the route towards an imminent and inevitable future.\n\n---\n\nSri Aurobindo came upon earth to teach this truth to men. He told them that man is only a transitional being living in a mental consciousness, but with the possibility of acquiring a new consciousness, the Truth-consciousness, and capable of living a life perfectly harmonious, good and beautiful, happy and fully conscious. During the whole of his life upon earth, Sri Aurobindo gave all his time to establish in himself this consciousness he called supramental, and to help those gathered around him to realise it.",
     "dest": "The Mother on Sri Aurobindo"
    }
 }
 
 */

-(void)parseResponse:(NSDictionary*)response
{
    NSDictionary *dictAuther = [response objectForKey:@"author"];
    
    if(dictAuther)
    {
        IWAboutStructure *about = [[IWAboutStructure alloc] init];
        about.strAutherName = [dictAuther objectForKey:@"autn"];
        about.strDescriptionTitle = [dictAuther objectForKey:@"dest"];
        about.strDescription = [dictAuther objectForKey:@"desc"];
        
        if([dictAuther objectForKey:@"comp"])
        {
            NSArray *arrCompDict = [dictAuther objectForKey:@"comp"];
            NSMutableArray *arrComp = [[NSMutableArray alloc] init];
            
            for (NSDictionary *dict in arrCompDict)
            {
                IWCompilationStructure *comp = [[IWCompilationStructure alloc] init];
                comp.strTitle = [dict objectForKey:@"t"];
                comp.strUrl = [dict objectForKey:@"u"];
                [arrComp addObject:comp];
            }
            
            about.arrCompilations = arrComp;
        }
        
        [self sendResponse:about];
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
