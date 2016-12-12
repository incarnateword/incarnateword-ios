//
//  IWNotificationDataWebService.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 12/12/16.
//  Copyright © 2016 Revealing Hour Creations. All rights reserved.
//

#import "IWNotificationDataWebService.h"
#import "IWQuoteItem.h"
#import "IWQuoteListItem.h"

@implementation IWNotificationDataWebService

-(id)initWithDelegate:(id<WebServiceDelegate>)delegate
{
    self = [super initWithRequest:[NSString stringWithFormat:@"quotes.json?"] header:nil body:nil RequestType:@"GET"];
    
    if (self)
    {
        //        [self setCustomBaseUrl:@"http://dictionary.incarnateword.in"];
        self.delegate = delegate;
    }
    return self ;
}

/*
 {
	"quotes": [{
 "t": "Letters on Yoga - III",
 "comp": "sabcl",
 "vol": "24",
 "list": [{
 "ref": "http://incarnateword.in/sabcl/24/difficulties-of-the-path-vii#p13",
 "sel": "\u003cp\u003eSuicide is an absurd solution; he is quite mistaken in thinking that it will give him peace. He will only carry his difficulties with him into a more miserable condition of existence beyond and bring them back to another life on earth. The only remedy is to shake off these morbid ideas and face life with a clear will for some definite work to be done as the life’s aim and with a quiet and active courage.\u003c/p\u003e",
 "auth": "sa",
 "tags": ["suicide"]
 }, {
 "ref": "http://incarnateword.in/sabcl/24/difficulties-of-the-path-vii#p14",
 "sel": "\u003cp\u003eSadhana has to be done in the body, it cannot be done by the soul without the body. When the body drops, the soul goes wandering in other worlds−and finally it comes back to another life and another body. Then all the difficulties it had not solved meet it again in the new life. So what is the use of leaving the body?\u003c/p\u003e\u003cp\u003eMoreover, if one throws away the body wilfully, one suffers much in the other worlds and when one is born again, it is in worse, not in better conditions.\u003c/p\u003e\u003cp\u003eThe only sensible thing is to face the difficulties in this life and this body and conquer them.\u003c/p\u003e",
 "auth": "sa",
 "tags": ["suicide"]
 }, {
 "ref": "http://incarnateword.in/sabcl/24/difficulties-of-the-path-vii#p3",
 "sel": "\u003cp\u003eThat is the inconvenience of going away from a difficulty,−it runs after one,−or rather one carries it with oneself, for the difficulty is truly inside, not outside. Outside circumstances only give it the occasion to manifest itself and so long as the inner difficulty is not conquered, the circumstances will always crop up one way or another.\u003c/p\u003e",
 "auth": "sa",
 "tags": ["Difficulties"]
 }, {
 "ref": "http://incarnateword.in/sabcl/24/difficulties-of-the-path-vii#p21",
 "sel": "\u003cp\u003eThe real rest is in the inner life founded in peace and silence and absence of desire. There is no other rest−for without that the machine goes on whether one is interested in it or not. The inner \u003cem\u003emukti\u003c/em\u003e is the only remedy.\u003c/p\u003e",
 "auth": "sa",
 "tags": ["rest"]
 }, {
 "ref": "http://incarnateword.in/sabcl/24/difficulties-of-the-path-vii#p19",
 "sel": "\u003cp\u003eThat is not right. Throwing away the life does not improve the chances for the next time. It is in this life and body that one must get things done.\u003c/p\u003e",
 "auth": "sa",
 "tags": ["suicide"]
 }, {
 "ref": "http://incarnateword.in/sabcl/24/difficulties-of-the-path-vii#p17",
 "sel": "\u003cp\u003eDeath is not a way to succeed in sadhana. If you die in that way, you will only have the same difficulties again with probably less favourable circumstances.\u003c/p\u003e",
 "auth": "sa",
 "tags": ["suicide"]
 }, {
 "ref": "http://incarnateword.in/sabcl/24/difficulties-of-the-path-vii#p18",
 "sel": "\u003cp\u003eNo man ever succeeded in this sadhana by his own merit. To become open and plastic to the Mother is the one thing needed.\u003c/p\u003e",
 "auth": "sa",
 "tags": ["success", "merit"]
 }]
	}, {
 "t": "Essays in Philosophy and Yoga",
 "comp": "cwsa",
 "vol": "13",
 "list": [{
 "ref": "http://incarnateword.in/cwsa/13/fate-and-free-will#p1",
 "sel": "as our goal, and every fresh step in our human progress is a further approximation to our ideal. But are we free in ourselves? We seem to be free, to do that which we choose and not that which is chosen for us; but it is possible that the freedom may be illusory and our apparent freedom may be a real and iron bondage. We may be bound by predestination, the will of a Supreme Intelligent Power, or blind inexorable Nature, or the necessity of our own previous development.",
 "auth": "sa"
 }, {
*/

-(void)parseResponse:(NSDictionary*)response
{
    NSArray *quotes = [response objectForKey:@"quotes"];
    NSMutableArray  *arrResult = [[NSMutableArray alloc] init];
    
    if(quotes && quotes.count > 0)
    {
        
        for (NSDictionary *dict in quotes)
        {
            IWQuoteItem *quoteItem = [IWQuoteItem new];
            
            /*
             
             {
             "t": "Letters on Yoga - III",
             "comp": "sabcl",
             "vol": "24",
             "list":
            
            @property(nonatomic)    NSString    *strTitle;
            @property(nonatomic)    NSString    *strCompilation;
            @property(nonatomic)    int         volume;
            @property(nonatomic)    NSArray     *arrListItems;
             
             */

            if([dict objectForKey:@"t"])
            {
                quoteItem.strTitle = [dict objectForKey:@"t"];
            }
            
            if([dict objectForKey:@"comp"])
            {
                quoteItem.strCompilation = [dict objectForKey:@"comp"];
            }
            
            if([dict objectForKey:@"vol"])
            {
                quoteItem.volume = [[dict objectForKey:@"vol"] intValue];
            }
            
            if([dict objectForKey:@"list"])
            {
                NSArray *arrList    = [dict objectForKey:@"list"];
            
                /*
                 {
                 "ref": "http://incarnateword.in/sabcl/24/difficulties-of-the-path-vii#p13",
                 "sel": "\u003cp\u003eSuicide is an absurd solution; he is quite mistaken in thinking that it will give him peace. He will only carry his difficulties with him into a more miserable condition of existence beyond and bring them back to another life on earth. The only remedy is to shake off these morbid ideas and face life with a clear will for some definite work to be done as the life’s aim and with a quiet and active courage.\u003c/p\u003e",
                 "auth": "sa",
                 "tags": ["suicide"]
                 }
                
                @property(nonatomic)    NSString    *strRefUrl;
                @property(nonatomic)    NSString    *strSelText;
                @property(nonatomic)    NSString    *strAuth;
                @property(nonatomic)    NSArray     *arrTags;
                 
                 */
                
                NSMutableArray *arrListItems = [NSMutableArray new];
                
                for (NSDictionary *dictListItems in arrList)
                {
                    NSLog(@"~~~~ %@",dictListItems);
                    
                    IWQuoteListItem *quoteListItem = [IWQuoteListItem new];
                    
                    if([dictListItems objectForKey:@"ref"])
                    {
                        quoteListItem.strRefUrl = [dictListItems objectForKey:@"ref"];
                    }
                    
                    if([dictListItems objectForKey:@"sel"])
                    {
                        quoteListItem.strSelText = [dictListItems objectForKey:@"sel"];
                    }
                    
                    if([dictListItems objectForKey:@"auth"])
                    {
                        quoteListItem.strAuth = [dictListItems objectForKey:@"auth"];
                    }
                    
                    if([dictListItems objectForKey:@"arrTags"])
                    {
                        quoteListItem.arrTags = [dictListItems objectForKey:@"arrTags"];
                    }
                    
                    [arrListItems addObject:quoteListItem];
                    
                }
                
                
                quoteItem.arrListItems = [arrListItems copy];
            }
            
            [arrResult addObject:quoteItem];
        }
        

    }
    
    [self sendResponse:arrResult];
}

#pragma mark-
#pragma mark Call back to caller

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
