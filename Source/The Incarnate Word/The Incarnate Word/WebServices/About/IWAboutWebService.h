//
//  IWAboutWebService.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 30/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "BaseWebService.h"

@interface IWAboutWebService : BaseWebService

-(id)initWithPath:(NSString*) strPath AndDelegate:(id<WebServiceDelegate>)delegate;

@end
