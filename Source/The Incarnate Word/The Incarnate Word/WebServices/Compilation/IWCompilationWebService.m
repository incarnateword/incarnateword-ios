//
//  TestWebService.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 16/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWCompilationWebService.h"
#import "IWCompilationStructure.h"
#import "IWVolumeStructure.h"

@implementation IWCompilationWebService

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
 compilation =     {
 auth = sa;
 autn = "Sri Aurobindo";
 cmpn = "Sri Aurobindo Birth Centenary Library";
 comp = sabcl;
 curl = sabcl;
 desc = "";
 vols =         (
 {
 t = "Bande Mataram";
 url = "sabcl/01";
 vol = 01;
 },
 {
 t = Karmayogin;
 url = "sabcl/02";
 vol = 02;
 },

 
 */

-(void)parseResponse:(NSDictionary*)response
{
    
    NSDictionary *dictCompilation = [response objectForKey:@"compilation"];
    
    if(dictCompilation)
    {
        IWCompilationStructure *compilation = [[IWCompilationStructure alloc] init];
        compilation.strTitle = [dictCompilation objectForKey:@"cmpn"];
        compilation.strAuthName = [dictCompilation objectForKey:@"autn"];
        compilation.strUrl = [dictCompilation objectForKey:@"curl"];
        
        if([dictCompilation objectForKey:@"vols"])
        {
            NSArray *arrDictVolume = [dictCompilation objectForKey:@"vols"];
            NSMutableArray *arrVolumes = [[NSMutableArray alloc] init];
            
            for (NSDictionary *dict in arrDictVolume)
            {
                IWVolumeStructure *volume = [[IWVolumeStructure alloc] init];
                volume.strIndex = [dict objectForKey:@"vol"];
                volume.strTitle = [dict objectForKey:@"t"];
                volume.strUrl = [dict objectForKey:@"url"];
                [arrVolumes addObject:volume];
            }
            
            compilation.arrVolumes = arrVolumes;
        }
        
        [self sendResponse:compilation];
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
