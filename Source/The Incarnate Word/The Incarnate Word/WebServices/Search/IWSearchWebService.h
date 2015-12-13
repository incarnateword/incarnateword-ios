//
//  IWSearchWebService.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 13/12/15.
//  Copyright © 2015 Revealing Hour Creations. All rights reserved.
//

#import "BaseWebService.h"

@interface IWSearchWebService : BaseWebService

-(id)initWithSearchString:(NSString*) strSearch AndDelegate:(id<WebServiceDelegate>)delegate;

@end
