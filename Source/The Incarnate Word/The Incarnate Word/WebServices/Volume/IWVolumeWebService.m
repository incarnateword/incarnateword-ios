//
//  IWVolumeWebService.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWVolumeWebService.h"
#import "IWDetailVolumeStructure.h"
#import "IWPartStructure.h"
#import "IWChapterStructure.h"
#import "IWChaterItemStructure.h"
#import "IWSectionStructure.h"
#import "IWSubSectionStructrue.h"
#import "IWBookStructure.h"
#import "IWSegmentStructure.h"

@implementation IWVolumeWebService


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
 
 
 "toc": {
 "books": [
 {
 "bookt": "Book Two",
 "parts": [
 {
 "partt": "Plays",
 "part": "Part I",
 "sections": [
 
 --------------
 
 {
 "volume": {
 "_id": {
 "$oid": "554d2c4469702d4f306d0100"
 },
 "alt": "Bande Mataram",
 "auth": "sa",
 "autn": "Sri Aurobindo",
 "cmpa": "SABCL",
 "cmpn": "Sri Aurobindo Birth Centenary Library",
 "comp": "sabcl",
 "curl": "sabcl",
 
 "nxtt": "The Harmony of Virtue",
 "nxtu": "/sabcl/03",
 "nxtv": 3,
 
 "prvt": "Bande Mataram",
 "prvu": "/sabcl/01",
 "prvv": 1,
 
 "subt": "Early Political Writings - 1 (1890-May 1908)",
 "t": "Bande Mataram",
 "toc": {
 "parts": [
 {
 "partt": "1890-1905",
 "chapters": [
 {
 "chapt": "Notes and Comments",
 "u": "notes-and-comments",
 "items": [
 {
 "itemt": "The Message of India",
 "u": "notes-and-comments#the-message-of-india"
 }]
 }]
 }
 ,
 {
 "partt": "Second Series",
 "sections": [
 {
 "sect": "The Synthesis of Works, Love and Knowledge",
 "sec": "Part I",
 "chapters": [
 {
 "chapt": "The Two Natures",
 "chap": "Chapter I",
 "u": "the-two-natures"
 },
 {
 "chapt": "The Synthesis of Devotion and Knowledge",
 "chap": "Chapter II",
 "u": "the-synthesis-of-devotion-and-knowledge"
 },
 {
 "chapt": "The Supreme Divine",
 "chap": "Chapter III",
 "u": "the-supreme-divine"
 }
 ]
 }
 --------------
 {
 "partt": "Supplement to Volume 12",
 "part": "Part XI",
 "sections": [
 {
 "sect": "\"The Karmayogin\"",
 "subsections": [
 {
 "subst": "Karmayogin: The Ideal",
 "chapters": [
 {
 "chapt": "The Eternal in His Universe",
 "u": "the-eternal-in-his-universe"
 },
 {
 "chapt": "Brahman",
 "chap": "Chapter I",
 "u": "brahman"
 },
 {
 "chapt": "Spiritual Evolution in Brahman",
 "chap": "Chapter II",
 "u": "spiritual-evolution-in-brahman"
 },
 {
 
 
 --------------
 
 {
 "chapt": "10 June-29 September 1914",
 "u": "10-june-29-september-1914",
 "segments": [
 {
 "segt": "June. 1914—",
 "u": "10-june-29-september-1914#june-1914",
 "items": [
 {
 "itemt": "June 10ṭḥ",
 "u": "10-june-29-september-1914#june-10"
 },
 {
 "itemt": "June 11ṭḥ",
 "u": "10-june-29-september-1914#june-11"
 },
 {
 
 */


-(void)parseResponse:(NSDictionary*)response
{
    
    NSDictionary *dictVolume = [response objectForKey:@"volume"];
    
    if(dictVolume)
    {
        IWDetailVolumeStructure *volume =[[IWDetailVolumeStructure alloc] init];
        volume.strIndex = [[dictVolume objectForKey:@"vol"] stringValue];
        volume.strTitle = [dictVolume objectForKey:@"t"];
        volume.strCompilationName = [dictVolume objectForKey:@"cmpn"];
        volume.strCompilationAuther = [dictVolume objectForKey:@"cmpa"];
        volume.strSubTitle = [dictVolume objectForKey:@"subt"];
        volume.strUrlPrevVolume = [dictVolume objectForKey:@"prvu"];
        volume.strUrlNextVolume = [dictVolume objectForKey:@"nxtu"];
        volume.strUrlCurrentVolume  = [dictVolume objectForKey:@"curl"];
        NSDictionary *dictTOC = [dictVolume objectForKey:@"toc"];
        
        if(dictTOC)
        {
            NSArray *arrBooksDict = [dictTOC objectForKey:@"books"];
            NSArray *arrPartsDict = [dictTOC objectForKey:@"parts"];
            NSArray *arrChaptersDict = [dictTOC objectForKey:@"chapters"];
            
            if(arrBooksDict && arrBooksDict.count > 0)
            {
                volume.arrBooks = [self getBooksArrayFromArray:arrBooksDict];
            }
            if(arrPartsDict && arrPartsDict.count > 0)
            {
                volume.arrParts = [self getPartsArrayFromArray:arrPartsDict];
            }
            else if(arrChaptersDict && arrChaptersDict.count > 0)
            {
                volume.arrChapters = [self getChaptersArrayFromArray:arrChaptersDict];
            }
        }
        
        [self sendResponse:volume];
    }
}

-(NSArray*)getBooksArrayFromArray:(NSArray*) arrBooksDict
{
    NSMutableArray *arrBooks = [[NSMutableArray alloc] init];

    for(NSDictionary *dictBook in arrBooksDict)
    {
        IWBookStructure *book = [[IWBookStructure alloc] init];
        book.strTitle = [dictBook objectForKey:@"bookt"];
        
        NSArray *arrPartsDict = [dictBook objectForKey:@"parts"];
        
        if(arrPartsDict && arrPartsDict.count > 0)//Book has parts
        {
            book.arrParts = [self getPartsArrayFromArray:arrPartsDict];
        }
        else//Book has direct chapters
        {
            NSArray *arrChaptersDict = [dictBook objectForKey:@"chapters"];
            
            if(arrChaptersDict && arrChaptersDict.count > 0)
            {
                book.arrChapters = [self getChaptersArrayFromArray:arrChaptersDict];
            }
        }
        
        [arrBooks addObject:book];
    }
    
    return [arrBooks copy];
}

-(NSArray*)getPartsArrayFromArray:(NSArray*) arrPartsDict
{
    NSMutableArray *arrParts = [[NSMutableArray alloc] init];
    
    for(NSDictionary *dictPart in arrPartsDict)
    {
        if([dictPart isKindOfClass:[NSDictionary class]] == NO)
            continue;
        
        IWPartStructure *part = [[IWPartStructure alloc] init];
        part.strTitle = [dictPart objectForKey:@"partt"];
        
        if([dictPart objectForKey:@"sections"])
        {
            NSArray *arrSectionsDict = [dictPart objectForKey:@"sections"];
            
            if(arrSectionsDict && arrSectionsDict.count > 0)
                part.arrSections = [self getSectionsArrayFromArray:arrSectionsDict];
            
            [arrParts addObject:part];

        }
        else if([dictPart objectForKey:@"chapters"])
        {
            NSArray *arrChaptersDict = [dictPart objectForKey:@"chapters"];
            
            if(arrChaptersDict && arrChaptersDict.count > 0)
                part.arrChapters = [self getChaptersArrayFromArray:arrChaptersDict];
            
            [arrParts addObject:part];
        }
    }
    
    return [arrParts copy];
}


-(NSArray*)getSectionsArrayFromArray:(NSArray*) arrSectionsDict
{
    NSMutableArray *arrSections = [[NSMutableArray alloc] init];
    
    for(NSDictionary *sectDict in arrSectionsDict)
    {
        IWSectionStructure *section = [[IWSectionStructure alloc] init];
        section.strTitle = [sectDict objectForKey:@"sect"];
        
        NSArray *arrSubsectionDict = [sectDict objectForKey:@"subsections"];
        
        if(arrSubsectionDict && arrSubsectionDict.count > 0)//has subsections
        {
            NSMutableArray *arrSubsections = [[NSMutableArray alloc] init];
            
            for (NSDictionary *dictSubsection in arrSubsectionDict)
            {
                IWSubSectionStructrue *subSection = [[IWSubSectionStructrue alloc] init];
                subSection.strTitle = [dictSubsection objectForKey:@"subst"];
                
                NSArray *arrChaptersDict = [dictSubsection objectForKey:@"chapters"];
                
                if(arrChaptersDict && arrChaptersDict.count > 0)
                    subSection.arrChapters = [self getChaptersArrayFromArray:arrChaptersDict];
                
                [arrSubsections addObject:subSection];
            }
            
            section.arrSubSections = [arrSubsections copy];
            [arrSections addObject:section];

        }
        else//has chapters
        {
            NSArray *arrChaptersDict = [sectDict objectForKey:@"chapters"];
            
            if(arrChaptersDict && arrChaptersDict.count > 0)
                section.arrChapters = [self getChaptersArrayFromArray:arrChaptersDict];

            [arrSections addObject:section];
        }
    }
    
    return [arrSections copy];
}


-(NSArray*)getChaptersArrayFromArray:(NSArray*) arrChaptersDict
{
    NSMutableArray *arrChapters = [[NSMutableArray alloc] init];
    
    for(NSDictionary *chapDict in arrChaptersDict)
    {
        IWChapterStructure *chapter = [[IWChapterStructure alloc] init];
        chapter.strTitle = [chapDict objectForKey:@"chapt"];
        chapter.strUrl = [chapDict objectForKey:@"u"];
        
        NSArray *arrDictItems = [chapDict objectForKey:@"items"];
        NSArray *arrDictSegments = [chapDict objectForKey:@"segments"];
        
        if(arrDictSegments && arrDictSegments.count > 0)//Chapter has segments
        {
            NSMutableArray *arrSegments = [[NSMutableArray alloc] init];
            
            for(NSDictionary *dictSegment in arrDictSegments)
            {
                IWSegmentStructure *segment = [[IWSegmentStructure alloc] init];
                segment.strTitle = [dictSegment objectForKey:@"segt"];
                segment.strUrl = [dictSegment objectForKey:@"u"];
                
                NSArray *arrDictItems = [dictSegment objectForKey:@"items"];
                
                if(arrDictItems && arrDictItems > 0)
                    segment.arrItems = [self getItemsArrayFromArray:arrDictItems withChapterUrl:chapter.strUrl];
                
                [arrSegments addObject:segment];
            }
            
            chapter.arrChapterSegments = [arrSegments copy];
        }
        else if(arrDictItems && arrDictItems.count > 0)//Chapter has items
        {
            chapter.arrChapterItems = [self getItemsArrayFromArray:arrDictItems withChapterUrl:chapter.strUrl];
        }
        
        [arrChapters addObject:chapter];
    }
    
    return [arrChapters copy];
}

-(NSArray*)getItemsArrayFromArray:(NSArray*) arrDictItems withChapterUrl:(NSString*) strUrl
{

    NSMutableArray *arrItems = [[NSMutableArray alloc] init];
    
    int index = 0;
    
    for(NSDictionary *dictItem in arrDictItems)
    {
        IWChaterItemStructure *chapItem = [[IWChaterItemStructure alloc] init];
        chapItem.strTitle = [dictItem objectForKey:@"itemt"];
        chapItem.strUrl = [dictItem objectForKey:@"u"];
        chapItem.strUrlParentChapter = strUrl;
        chapItem.iItemIndex = index;
        [arrItems addObject:chapItem];
        index++;
    }
    
    return [arrItems copy];
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
