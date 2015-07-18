//
//  IWVolumeWebService.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "BaseWebService.h"

@interface IWVolumeWebService : BaseWebService

-(id)initWithPath:(NSString*) strPath AndDelegate:(id<WebServiceDelegate>)delegate;

@end
