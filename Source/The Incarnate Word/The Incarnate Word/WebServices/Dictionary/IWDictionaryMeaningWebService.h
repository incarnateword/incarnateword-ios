//
//  IWDictionaryMeaningWebService.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 03/06/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "BaseWebService.h"

@interface IWDictionaryMeaningWebService : BaseWebService

-(id)initWithWord:(NSString*) strWord AndDelegate:(id<WebServiceDelegate>)delegate;

@end
