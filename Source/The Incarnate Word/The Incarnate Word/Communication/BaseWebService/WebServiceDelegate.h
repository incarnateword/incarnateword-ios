//
//  WSCommDelegate.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 16/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSError.h"

@class BaseWebService;

@protocol WebServiceDelegate <NSObject>

@required

/**
 * @brief Request sucessfully executed callback
 *
 * @details This method is required method .The class that sends webservice request must implement this method.
 *
 * @param responseModel web service response will be stored in this DS
 *
 * @return
 */

-(void)requestSucceed:(BaseWebService*)webService response:(id)responseModel;
/**
 * @brief Request failed callback
 *
 * @details This method is required method .The class that sends webservice request must implement this method.
 *
 * @param error Error or exception occured while sending webservice request.
 *
 * @return
 */
-(void)requestFailed:(BaseWebService*)webService error:(WSError*)error ;

@end
