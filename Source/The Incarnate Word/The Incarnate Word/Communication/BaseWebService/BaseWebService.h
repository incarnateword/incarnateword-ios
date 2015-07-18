//
//  BaseWebService.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 16/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebServiceDelegate.h"
#import "HttpCommunication.h"

typedef enum WebservicePriority
{
    WS_PRIORITY_DEFAULT,
    WS_PRIORITY_CONTENT_HIGH,
    WS_PRIORITY_CONTENT_LOW,
    
}WebservicePriority;

@interface BaseWebService : NSObject<HttpCommunicationDelegate>
{
   
}

/**
 * Reference to sender of request.Once response is received call back will be given on this object.
 */
@property(nonatomic,weak) id<WebServiceDelegate> delegate ;

/**
 * @brief This is init method to create instance of this class.This must be called by in child class's init method.
 *
 * @param path Url path component for request
 * @param headers HTTP header fields specific to request
 * @param body HTTP Body of request
 * @param requestType HTTP Request type 'GET' or 'POST'
 *
 * @return Instance of class.
 */
-(id)initWithRequest:(NSString*)path
              header:(NSDictionary*)headers
                body:(NSDictionary*)body
        RequestType :(NSString *)requestType ;

/**
 * @brief Appends session id to query string.
 *
 * @param queryStr query string of webservice request
 *
 * @return NSString
 *         returns query string appending session id
 */

-(void)setCustomBaseUrl:(NSString*)strCustomBaseUrl;

-(void)parseResponse:(NSDictionary *)response ;

/**
 * @brief Cancels request
 *
 * @return
 */
-(void)cancelRequest ;

/**
 * @brief sets operation priority
 *
 * @details
 *
 * @param   priority
 *
 * @return
 *
 */
-(void)updatePriority:(WebservicePriority)wsPriority;

/**
 * @brief Generic method to handle all exception.
 *
 * @details Handles exception occured during life time of request i.e. request sent to response received cycle.
 *
 * @param Exception occured while handling request.
 */
-(void)handleException:(NSException *)exception ;

/**
 * @brief Sends webservice request.
 *
 * @details This is public method, which will add request into NSOperationQueue.Queue will schedule for execution.
 */
-(void)sendAsyncRequest ;

/**
 * @brief Sends synchronous webservice request.
 *
 * @details This method will send synchronous request.
 *
 * @param WSError
 *      $wsError -In case of failer of error will be sent in this param.
 * @return Response in NSDictionary format.
 */
-(NSDictionary*)sendSyncRequest:(WSError**)error;

/**
 * @brief sends response to caller of webservice
 *
 * @details This method is called by subclass once response parsing is complete.
 *
 * @param id
 *      $response -Model object created from response
 * @return
 */
-(void) sendResponse:(id)response;

/**
 * @brief Generic method to handle all errors.
 *
 * @details
 *
 * @param WSError
 */
-(void) handleError:(WSError*)error ;

@end
