//
//  IWPartStructure.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWPartStructure.h"
#import "IWSectionStructure.h"
#import "IWSubSectionStructrue.h"
#import "IWChapterStructure.h"

@implementation IWPartStructure

-(NSArray *)getChaptersAndItemsFromPartArray
{
    NSMutableArray *arrFinal = [[NSMutableArray alloc] init];
    
    if(_arrSections && _arrSections > 0)
    {
        for(IWSectionStructure * section in _arrSections)
        {
            //1. Add dummy SECTION
            IWSectionStructure *dummySection = [[IWSectionStructure alloc] init];
            dummySection.strTitle = section.strTitle;
            [arrFinal addObject:dummySection];
            
            //2. Check subsection
            if(section.arrSubSections && section.arrSubSections > 0)
            {
                for (IWSubSectionStructrue *subSection in section.arrSubSections)
                {
                    //2A. Add dummy SUB_SECTION
                    IWSubSectionStructrue *dummySubSection = [[IWSubSectionStructrue alloc] init];
                    dummySubSection.strTitle = subSection.strTitle;
                    [arrFinal addObject:dummySubSection];
                    
                    //2B. Add CHAPTERS from subsections
                    NSArray *arrChap = [self getChaptersAndItemsFromChapterArray:subSection.arrChapters];
                    [arrFinal addObjectsFromArray:arrChap];
                }
            }
            //3. Check chapters
            else if(section.arrChapters && section.arrChapters > 0)
            {
                //3A. Add CHAPTERS
                NSArray *arrChap = [self getChaptersAndItemsFromChapterArray:section.arrChapters];
                [arrFinal addObjectsFromArray:arrChap];
            }
        }
    }
    else if(_arrChapters && _arrChapters > 0)
    {
        NSArray *arrChap = [self getChaptersAndItemsFromChapterArray:_arrChapters];
        [arrFinal addObjectsFromArray:arrChap];
    }
    
    return [arrFinal copy];
}

-(NSArray *)getChaptersAndItemsFromChapterArray:(NSArray*) arrChapters
{
    NSMutableArray *arrChapAndItems = [[NSMutableArray alloc] init];
    
    for(IWChapterStructure *chap in arrChapters)
    {
        [arrChapAndItems addObject:chap];
        
        /* Hide chapter segments and items as clicking on them will not take to that location in chapter
         
         if(chap.arrChapterSegments && chap.arrChapterSegments.count > 0)
         {
         for (IWSegmentStructure *segment in chap.arrChapterSegments)
         {
         IWSegmentStructure *dummySegment = [[IWSegmentStructure alloc] init];
         dummySegment.strTitle = segment.strTitle;
         dummySegment.strUrl =  segment.strUrl;
         
         [arrChapAndItems addObject:dummySegment];
         
         for(IWChaterItemStructure *chapItem in segment.arrItems)
         {
         [arrChapAndItems addObject:chapItem];
         }
         }
         }
         else if(chap.arrChapterItems && chap.arrChapterItems.count > 0)
         {
         for(IWChaterItemStructure *chapItem in chap.arrChapterItems)
         {
         [arrChapAndItems addObject:chapItem];
         }
         }
         
         */
    }
    
    return [arrChapAndItems copy];
}

@end
