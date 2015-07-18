//
//  WSRequestOperation.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 16/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSError.h"

@protocol HttpCommunicationDelegate <NSObject>

@required
-(void)receivedHttpResponse:(NSHTTPURLResponse *)httpResponse responseData:(NSData *)responseData ;
-(void)failedHttpRequest:(WSError*)error;

@end

@interface HttpCommunication : NSOperation<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
   
}

/**
 * @brief Webservice request timeout
 *
 */
@property(assign)NSInteger requestTimeOut ;

/**
 * @brief Server hostname.
 *
 */
@property(nonatomic,copy)NSString *baseServerUrl ;

/**
 * @brief Server hostname.
 *
 */
@property(weak,nonatomic)id<HttpCommunicationDelegate> delegate ;

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
 * @brief Sends webservice request.
 *
 * @details This is public method, which will add request into NSOperationQueue.Queue will schedule for execution.
 *
 * @param completion -Completion block will give data in case of sucess and error in case of failer of webservice.
 */

-(void)sendAsyncRequestWithCompletion:(void (^)(NSHTTPURLResponse *httpResponse,NSData *responseData,WSError *error))completion ;

/**
 * @brief Sends synchronous webservice request.
 *
 * @details This method will send synchronous request.
 *
 * @param WSError
    $wsError -In case of failer of error will be sent in this param.
 */
-(NSData *)sendSyncRequest:(WSError**)wsError;


/**
 * @brief Sends webservice request.
 *
 * @details This is public method, which will start request execution.
 *
 * @param
 */

-(void)sendAsyncRequest ;
@end
