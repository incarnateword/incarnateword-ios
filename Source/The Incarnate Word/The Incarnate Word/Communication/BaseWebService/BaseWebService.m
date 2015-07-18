//
//  BaseWebService.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 16/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "BaseWebService.h"
#import "WebServiceConstants.h"
////Preformance Check
//#include <sys/time.h>


#define RETRY_SLEEP  1


@interface BaseWebService ()
{
    HttpCommunication *_httpCommunication ;
    int _retryCnt ;
    
//    //Preformance Check
//    struct timeval t1;
//    struct timeval t2;
}

/**
 * @brief Converts response data from NSData to NSDictionary format
 *
 * @details This method will be implemented by child classes and have their own parsing logic.
 *
 * @return
 */
-(void)serializeResponse:(NSData *)responseData ;

/**
 * @brief Resend request in case of failer.
 *
 * @param errorCode
 *
 * @return
 */
-(void)retry:(int)errorCode ;


/**
 * @brief gets deviceInfo
 *
 * @param
 *
 * @return NSString
 *         returns device into Dictionary into stringized format
 */

@end

@implementation BaseWebService

-(id)initWithRequest:(NSString*)path
              header:(NSDictionary*)headers
                body:(NSDictionary*)body
        RequestType :(NSString *)requestType
{
    self = [super init];
    if (self)
    {

        
        NSMutableDictionary *updatedHeaders = [NSMutableDictionary dictionaryWithDictionary:headers];
        



        _httpCommunication = [[HttpCommunication alloc] initWithRequest:path header:updatedHeaders body:body RequestType:requestType];
        [_httpCommunication setQueuePriority:NSOperationQueuePriorityVeryHigh];
        [_httpCommunication setBaseServerUrl:BASE_URL];
        [_httpCommunication setRequestTimeOut:RETRY_COUNT];
        [_httpCommunication setDelegate:self];
        
        _retryCnt = 0;
    }
    return self ;
}

-(void)setCustomBaseUrl:(NSString*)strCustomBaseUrl
{
    [_httpCommunication setBaseServerUrl:strCustomBaseUrl];
}



-(NSString *)encodeString:(NSString *)urlString
{
    CFStringRef newString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)urlString, NULL, CFSTR("!*'();:@&=+@,/?#[]"), kCFStringEncodingUTF8);
    return (NSString *)CFBridgingRelease(newString);
}



-(void)parseResponse:(NSDictionary *)response
{
     NSLog(@"Subclass must overide parse response method:");
}

-(void)cancelRequest
{
    //Cancel request if not started.
    if (![_httpCommunication isExecuting])
    {
        [_httpCommunication cancel];
    }
}

-(void)updatePriority:(WebservicePriority)wsPriority
{
    if (![_httpCommunication isExecuting])
    {
        switch (wsPriority)
        {
            case WS_PRIORITY_DEFAULT:
            {
                [_httpCommunication setQueuePriority:NSOperationQueuePriorityNormal];
            }
                break;
                case WS_PRIORITY_CONTENT_HIGH:
            {
                [_httpCommunication setQueuePriority:NSOperationQueuePriorityHigh];
            }
                break;
                case WS_PRIORITY_CONTENT_LOW:
            {
               [_httpCommunication setQueuePriority:NSOperationQueuePriorityLow];
            }
                break;
                
            default:
                break;
        }
    }
}

-(void)handleException:(NSException *)exception
{
    NSLog(@"%@",[exception name]);
    WSError *error = [[WSError alloc] initWithErrorCode:WS_UNKNOWN];
    [_delegate requestFailed:self error:error];
}

-(void)sendAsyncRequest
{
    if (_delegate == nil)
    {
        NSLog(@"No need to send request");
        return ;
    }
    [_httpCommunication sendAsyncRequest];
}

-(void)receivedHttpResponse:(NSHTTPURLResponse *)httpResponse responseData:(NSData *)responseData
{
    _retryCnt = 0;
    
    //convert resonse data to NSDictionary.
    [self performSelectorInBackground:@selector(serializeResponse:) withObject:responseData];
    
}

-(void)failedHttpRequest:(WSError*)error
{
    int errorCode = [error errorCode];
    if (errorCode==WS_NETWORK_CONNECTION_LOST |
        errorCode==WS_NOT_CONNECTED_TO_INTERNET)
    {
        [self retry:errorCode];
    }
    else
    {
        [_delegate requestFailed:self error:error];
    }
}

-(NSDictionary*)sendSyncRequest:(WSError**)error
{
    NSDictionary *responseDict = nil ;
    NSData *data = [_httpCommunication sendSyncRequest:error];
    
    if ((error==nil) || (*error==nil))
    {
        responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    }
    else
    {
        //TODO:Implement retry here.
    }
    return responseDict ;
}

-(void)serializeResponse:(NSData *)responseData
{
//    //Preformance Check
//    gettimeofday(&t2, 0);
//    unsigned long diff = ((t2.tv_usec/1000)+(t2.tv_sec*1000)) - ((t1.tv_usec/1000)+(t1.tv_sec*1000));
//    NSLog(@"Time required for Thread Switch(%@) %ld: ",self,diff);
    
    @try
    {
        //Convert NSData to NSDictionary.
        if ([responseData length])
        {
            NSError* error;
            NSDictionary* jsonObject = [NSJSONSerialization JSONObjectWithData:responseData
                 
                                                                       options:NSJSONReadingAllowFragments error:&error];
            //If data is not UTF8 encoded then following workaround is used.
            if (!jsonObject)
            {
                error = nil;
                NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
                NSData *utfData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
                jsonObject = [NSJSONSerialization JSONObjectWithData:utfData
                              
                                                             options:NSJSONReadingAllowFragments error:&error];
            }
           
//        //Preformance Check
//        gettimeofday(&t2, 0);
//
//        unsigned long diff = ((t2.tv_usec/1000)+(t2.tv_sec*1000)) - ((t1.tv_usec/1000)+(t1.tv_sec*1000));
//        NSLog(@"Time required for Serialization(%@) %ld: ",self,diff);
            if (!error)
            {
                [self parseResponse:jsonObject];
            }
            else
            {
                WSError *wsError = [[WSError alloc] initWithErrorCode:WS_PARSE_ERROR];
                [_delegate requestFailed:self error:wsError];
            }
        }
        else
        {
            [self parseResponse:nil];
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception during data serialization:%@",exception);
    }
}


-(void)retry:(int)errorCode
{
    //error code may ne needed in case of retrying for specific error types
    //In case of request failer resend request maxRetryCount times otherwise raise error.
    if (_retryCnt < RETRY_COUNT)
    {
        _retryCnt++;
        
        dispatch_time_t retryTime = dispatch_time(DISPATCH_TIME_NOW, RETRY_SLEEP * NSEC_PER_SEC);
        dispatch_after( retryTime, dispatch_get_main_queue(), ^{
            [_httpCommunication start];
        });
    }
    else
    {
        _retryCnt = 0 ;
        WSError *wserror = [[WSError alloc] initWithErrorCode:errorCode];
        [self handleError:wserror];
    }
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
    if ([_delegate respondsToSelector:@selector(requestFailed:error:)])
    {
        [_delegate requestFailed:self error:error];
    }
}

-(void)dealloc
{
    NSLog(@"BaseWebService dealloc");
    [_httpCommunication setDelegate:nil];
    _httpCommunication = nil;
}

@end
