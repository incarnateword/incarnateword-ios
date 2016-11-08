//
//  WSRequestOperation.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 16/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "HttpCommunication.h"
#import "Reachability.h"

#define DEFAULT_REQUEST_TIMEOUT 30
#define MAX_CONCURRENT_OPERATIONS 5

/**
 * This queue will schedule all web service request
 */
static NSOperationQueue *_serverOperationQueue = nil ;

@interface HttpCommunication ()
{
    /**
     * Url path component for request
     */
    NSString *_urlPathComponent;
    
    /**
     * HTTP header fields specific to request.
     */
    NSDictionary*_headers;

    /**
     * HTTP Body of request
     */
    NSDictionary *_body;
    
    /**
     * HTTP Request type 'GET' or 'POST'
     */
    NSString *_requestType;
    
    /**
     * Connection object
     */
    NSURLConnection *_connection ;
    
    /**
     * The response received from server will be appended in this object.
     */
    NSMutableData *_responseData ;
    
    /**
     * The _httpResponse received from server having all header fileds.
     */
    NSHTTPURLResponse *_httpResponse ;

    
    /**
     * Response status. e.g. _status = 200 for success
     */
    NSInteger _status;
    
    /**
     * Network connectivity
     */
    Reachability *_reachability ;
}

/**
 * @brief Creates HTTP headers in dictionary format.
 *
 * @details This method will read headers from request and combine with common headers specific to all request.
 *
 * @return HTTP header in dictionary format.
*/
-(NSDictionary*)createHeaders ;

/**
 * @brief Creates HTTP request.
 *
 * @details Creates HTTP request.Sets all params such as headers,body,request type etc.
 *
 * @return NSMutableURLRequest
 */
-(NSMutableURLRequest*)createRequest ;


@end

@implementation HttpCommunication

+(void) initialize
{
    if (! _serverOperationQueue)
    	_serverOperationQueue = [[NSOperationQueue alloc] init];
}

-(id)initWithRequest:(NSString*)path
              header:(NSDictionary*)headers
                body:(NSDictionary*)body
        RequestType :(NSString *)requestType

{
    self = [super init];
    
    if (self)
    {
        _reachability = [Reachability reachabilityForInternetConnection];
        _urlPathComponent = path ;
        _body = body ;
        _headers = headers ;
        _requestType = requestType ;
        _serverOperationQueue.maxConcurrentOperationCount = MAX_CONCURRENT_OPERATIONS;
    }
    return self ;
}

-(void)sendAsyncRequestWithCompletion:(void (^)(NSHTTPURLResponse *httpResponse,NSData *responseData,WSError *error))completion
{
    //Add webservice request into operationQueue
    [_serverOperationQueue addOperation:self];
}

-(void)sendAsyncRequest
{
    if (self) {
        [_serverOperationQueue addOperation:self];
    }
}

-(NSData *)sendSyncRequest:(WSError**)wsError
{
    NSError * error = nil;
    NSURLRequest *request = [self createRequest];
    NSURLResponse *response ;
    NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSInteger status = [(NSHTTPURLResponse*)response statusCode];
    
    if (status==WS_SUCCESS)
    {
        if(wsError!=nil)
        {
            *wsError =nil;
        }
        return data;
    }
    else
    {
        if(wsError!=nil)
        {
            *wsError = [[WSError alloc] initWithErrorCode:(WSErrorCode)status];
        }
    }
    return data ;
}

#pragma mark-
#pragma mark Web service Request configuration

-(void)cancelRequest
{
    //Cancel request if not started.
    if (![self isExecuting])
    {
        [self cancel];
    }
}

-(NSDictionary*)createHeaders
{
    NSMutableDictionary *headers = [NSMutableDictionary dictionaryWithDictionary:_headers];
    return headers ;
}

-(NSData *)getBodyData
{
    NSData *data = nil ;
    if (_body)
    {
        //Convert NSDictionary to NSData.
        @try
        {
            data = [NSKeyedArchiver archivedDataWithRootObject:_body];
        }
        @catch (NSException *exception)
        {
            NSLog(@"Handle request formation error");
        }
    }
    return data;
}

-(NSMutableURLRequest*)createRequest
{
//    NSString *urlString = [[NSString stringWithFormat:@"%@/%@",_baseServerUrl,_urlPathComponent] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@",_baseServerUrl,_urlPathComponent] ;
    
    NSString *urlFinal = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:urlFinal];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setHTTPMethod:_requestType];
    [request setAllHTTPHeaderFields:[self createHeaders]];
    [request setHTTPBody:[self getBodyData]];
    
    //if request time out is  specified then use it otherwise set default timeout
    if (_requestTimeOut)
    {
        [request setTimeoutInterval:_requestTimeOut];
    }
    else
    {
        [request setTimeoutInterval:DEFAULT_REQUEST_TIMEOUT];
    }
    NSLog(@"Request time=%@\nHTTP Request:%@\n\n HTTP Request  headers:%@",[NSDate date],request.URL,[request allHTTPHeaderFields]);

    return request;
}

-(NSString *)encodeString:(NSString *)urlString
{
    CFStringRef newString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)urlString, NULL, CFSTR("!*'();:@&=+@,/?#[]"), kCFStringEncodingUTF8);
    return (NSString *)CFBridgingRelease(newString);
}
-(void)main
{
    @autoreleasepool
    {
        if ([_reachability currentReachabilityStatus]!=NotReachable)
        {
            NSURLRequest *request = [self createRequest];
            _responseData = [[NSMutableData alloc] init];
            _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [_connection scheduleInRunLoop:[NSRunLoop mainRunLoop]
                                   forMode:NSRunLoopCommonModes];
            [_connection start];
        }
        else
        {
            //In case of network loss,execute completion block with error
            WSError *error = [[WSError  alloc] initWithErrorCode:WS_NOT_CONNECTED_TO_INTERNET];
            [self.delegate failedHttpRequest:error];
        }
    }
}

#pragma mark-
#pragma mark NSURLConnection Delegates


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _httpResponse = (NSHTTPURLResponse *) response;
    _status = [_httpResponse statusCode];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *responseString = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
    NSLog(@"HTTP RESPONSE TIME=%@\n\nHTTP STATUS CODE=%d\n\nHTTP STATUS MESSAGE=%@\n\nHTTP RESPONSE HEADERS=%@\n\n HTTP RESPONSE STRING=%@",[NSDate date],_status,
                [NSHTTPURLResponse localizedStringForStatusCode:_status],
                _httpResponse.allHeaderFields,
                responseString);
    if (_status==WS_SUCCESS)
    {
        [self.delegate receivedHttpResponse:_httpResponse responseData:_responseData];
    }
    else
    {
      NSString *errorMessage = [NSString stringWithCString:[_responseData bytes] encoding:NSUTF8StringEncoding];
      WSError *error = [[WSError alloc] initWithErrorCode:(WSErrorCode)_status andDescription:errorMessage];
      [self.delegate failedHttpRequest:error];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    WSErrorCode errorCode ;
    switch ([error code]) {
            
            //NSURL connection error codes
        case kCFURLErrorUnknown: //= -998,
             errorCode = WS_UNKNOWN;
             break;
        case kCFURLErrorUnsupportedURL: // -1002,
        case kCFURLErrorBadURL:
             errorCode = WS_BADREQUEST;
             break;
        case kCFURLErrorTimedOut:
             errorCode = WS_ERROR_TIMEOUT;
             break;
        case kCFURLErrorCannotFindHost:// = -1003,
             errorCode = WS_HOST_NOTFOUND;
             break;
        case kCFURLErrorCannotConnectToHost: //= -1004,
             errorCode = WS_CANNOT_CONNECT_TO_HOST;
             break;
        case kCFURLErrorNetworkConnectionLost: //= -1005,
             errorCode = WS_NETWORK_CONNECTION_LOST;
             break;
        case kCFURLErrorResourceUnavailable: // -1008,
             errorCode = WS_FOUND;
             break;
        case kCFURLErrorNotConnectedToInternet: //-1009,
             errorCode = WS_NOT_CONNECTED_TO_INTERNET ;
             break;
        case kCFURLErrorUserCancelledAuthentication: //= -1012,
        case kCFURLErrorUserAuthenticationRequired: //= -1013,
             errorCode = WS_NETWORK_AUTHENTICATION_REQUIRED;
             break;
            
        case kCFURLErrorDNSLookupFailed: // -1006,
        case kCFURLErrorHTTPTooManyRedirects: // -1007,
        case kCFURLErrorRedirectToNonExistentLocation:// = -1010,
        case kCFURLErrorBadServerResponse: //= -1011,
        case kCFURLErrorCancelled: //= -999,
        case kCFURLErrorZeroByteResource: //= -1014,
        case kCFURLErrorCannotDecodeRawData: //= -1015,
        case kCFURLErrorCannotDecodeContentData: //= -1016,
        case kCFURLErrorCannotParseResponse: //= -1017,
        case kCFURLErrorInternationalRoamingOff: //= -1018,
        case kCFURLErrorCallIsActive: //= -1019,
        case kCFURLErrorDataNotAllowed: //= -1020,
        case kCFURLErrorRequestBodyStreamExhausted: //= -1021,
        case kCFURLErrorFileDoesNotExist: //= -1100,
        case kCFURLErrorFileIsDirectory: //= -1101,
        case kCFURLErrorNoPermissionsToReadFile: //= -1102,
        case kCFURLErrorDataLengthExceedsMaximum: //= -1103,

        default:
            errorCode = WS_UNKNOWN;
            break;
    }
    WSError *wsError = [[WSError alloc] initWithErrorCode:errorCode];
    [self.delegate failedHttpRequest:wsError];
}

-(void)dealloc
{
    NSLog(@"HttpCommunication dealloc");
}

@end
