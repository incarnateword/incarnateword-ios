//
//  IWSearchWebService.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 13/12/15.
//  Copyright © 2015 Revealing Hour Creations. All rights reserved.
//

#import "BaseWebService.h"

@interface IWSearchWebService : BaseWebService

-(id)initWithSearchString:(NSString*) strSearch
            AndStartIndex:(int) start
              AndDelegate:(id<WebServiceDelegate>)delegate;


-(id)initWithSearchString:(NSString*) strSearch
                AndAuther:(NSString*) strAuther
           AndCompilation:(NSString*) strCollection
                AndVolume:(NSString*) strVolume
            AndStartIndex:(int) start
              AndDelegate:(id<WebServiceDelegate>)delegate;


-(id)initWithSearchYear:(NSString*) strYear
              WithMonth:(NSString*) strMonth
               WithDate:(NSString*) strDate
          AndStartIndex:(int) start
            AndDelegate:(id<WebServiceDelegate>)delegate;

@end
