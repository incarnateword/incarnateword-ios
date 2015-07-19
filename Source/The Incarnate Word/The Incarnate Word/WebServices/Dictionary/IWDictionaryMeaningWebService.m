//
//  IWDictionaryMeaningWebService.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 03/06/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWDictionaryMeaningWebService.h"
#import "IWWordMeaningStructure.h"

@implementation IWDictionaryMeaningWebService

-(id)initWithWord:(NSString*) strWord AndDelegate:(id<WebServiceDelegate>)delegate
{
    self = [super initWithRequest:[NSString stringWithFormat:@"entries/%@.json",strWord] header:nil body:nil RequestType:@"GET"];
    
    //http://dictionary.incarnateword.in/entries/allured.json
    
    if (self)
    {
        [self setCustomBaseUrl:@"http://dictionary.incarnateword.in"];
        self.delegate = delegate;
    }
    
    return self ;
}

/*

 {
 "entry": {
 "definition": "**1.** Attracted as to a lure; drawn or enticed to a place or to a course of action. \r\n**2.** Attracted or tempted by something flattering or desirable; fascinated, charmed.\r\n\r\n**alluring**, **alluringly**, **allurement** \r\n\r\n---\r\n\r\n>[referring to the following lines]  \r\n\r\n>“Aware of his occult omnipotent source,  \r\nAllured by the omniscient Ecstasy,  \r\nHe felt the invasion and the nameless joy.”  \r\n\r\n*****  \r\n\r\n>“I certainly won't have ‘attracted’ [in place of ‘allured’] — there is an enormous difference between the force of the two words and merely ‘attracted by the Ecstasy’ would take away all my ecstasy in the line — nothing so tepid can be admitted. Neither do I want ‘thrill’ [in place of ‘joy’] which gives a false colour — precisely it would mean that the ecstasy was already touching him with its intensity which is far from my intention.  \r\n\r\n>Your statement that ‘joy’ is just another word for ‘ecstasy’ is surprising. ‘Comfort’, ‘pleasure’, ‘joy’, ‘bliss’, ‘rapture’, ‘ecstasy’ would then be all equal and exactly synonymous terms and all distinction of shades and colours of words would disappear from literature. As well say that ‘flashlight’ is just another word for ‘lightning’ — or that glow, gleam, glitter, sheen, blaze are all equivalents which can be employed indifferently in the same place. One can feel allured to the supreme omniscient Ecstasy and feel a nameless joy touching one without that Joy becoming itself the supreme Ecstasy. I see no loss of expressiveness by the joy coming in as a vague nameless hint of the immeasurable superior Ecstasy.” \r\n\r\n>*Letters on Savitri*\r\n",
 "url": "/allured",
 "word": "allured"
 }
 }
 
 */


-(void)parseResponse:(NSDictionary*)response
{
    NSDictionary *dict = [response objectForKey:@"entry"] ;
    
    IWWordMeaningStructure *wordMeaning = [[IWWordMeaningStructure alloc] init];
    wordMeaning.strWord = [dict objectForKey:@"word"];
    wordMeaning.strDefinition = [NSString stringWithFormat:@"#%@  %@%@",[dict objectForKey:@"word"],@"\n",[dict objectForKey:@"definition"]];
    wordMeaning.strUrl = [dict objectForKey:@"url"];

    [self sendResponse:wordMeaning];
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
