//
//  IWBookStructure.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 07/06/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWBookStructure.h"
#import "IWPartStructure.h"
#import "IWChapterStructure.h"

@implementation IWBookStructure

-(NSArray *)getChaptersAndItemsFromBookArray
{
    NSMutableArray *arrFinal = [[NSMutableArray alloc] init];
    
    if(_arrParts && _arrParts > 0)//Book has parts
    {
        for(IWPartStructure *part in _arrParts)
        {
            //If volume has book then add dummy part as Book will be sections and not part
            IWPartStructure *dummyPart = [[IWPartStructure alloc] init];
            dummyPart.strTitle = part.strTitle;
            [arrFinal addObject:dummyPart];
            
            NSArray *arrPartContent =  [part getChaptersAndItemsFromPartArray];
            [arrFinal addObjectsFromArray:arrPartContent];
        }
    }
    else//Book has direct chapters
    {
        if(_arrChapters && _arrChapters > 0)
        {
            NSArray *arrChapContent = [self getChaptersAndItemsFromChapterArray:_arrChapters];
            [arrFinal addObjectsFromArray:arrChapContent];
        }
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
