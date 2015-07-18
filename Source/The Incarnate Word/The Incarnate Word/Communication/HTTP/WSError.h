//
//  WSError.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 16/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum WSErrorCode
{
    //HTTP 2XX ERROR CODES.
    WS_SUCCESS = 200,
    WS_AUTHORITATIVE_INFO =203 ,
    WS_NOCONTENT = 204,
    WS_RESETCONTENT =205 ,
    WS_PARTIAL_CONTENT = 206 ,
    WS_MULTI_STATUS =207 ,
    WS_ALREADY_REPOPRTED = 208 ,
    WS_IM_USED =226 ,
    
    //HTTP 3XX ERROR CODES
    WS_MULTIPLE_CHOICES= 300 ,
    WS_MOVED_PERMANETLY = 301 ,
    WS_FOUND = 302,
    WS_SEE_OTHER = 303 ,
    WS_NOT_MODIFIED = 304 ,
    WS_USE_PROXY =305,
    WS_SWITCH_PROXY = 306 ,
    WS_TEMP_REDIRECT =307 ,
    WS_PERMANENT_REDIRECT =308 ,

    //HTTP 4XX ERROR CODES
	WS_BADREQUEST =  400,
	WS_UNAUTHORIZED = 401,
	WS_PAYMENT_REQUIRED = 402,
	WS_FORBIDDEN = 403,
	WS_NOTFOUND = 404,
	WS_METHOD_NOTALLOWED = 405,
    WS_NOT_ACCEPTABLE = 406,
	WS_PROXYAUTHENTICATIONREQUIRED = 407,
	WS_REQUESTTIMEOUT = 408,
    WS_CONFLICT = 409,
    WS_GONE = 410,
    WS_LENGHT_REQUIRED = 411,
    WS_PRECONDITION_FAILED = 412,
	WS_REQUEST_TOO_LARGE = 413,
	WS_REQUEST_URI_TOO_LONG = 414,
    WS_UNSUPPORTED_MEDIA_TYPE = 415,
    WS_REQUEST_RANGE_NOT_SATISFIABLE = 416,
    WS_EXPECTATION_FAILED = 417,
	WS_AUTHENTICATION_TIMEOUT = 419,
    WS_UNPROCESSABLE_ENTITY = 422,
    WS_LOCKED = 423,
    WS_FAILED_DEPENDENCY = 424,
    WS_UPGRADE_REQUIRED = 426,
    WS_PRECONDITION_REQUIRED = 428,
    WS_TOO_MANY_REQUEST = 429,
    WS_REQUEST_HEADER_TOO_LARGE = 431,
    
    //HTTP 5XX ERROR CODES
    WS_INTERNAL_SERVERERROR = 500,
    WS_NOTIMPLEMENTED = 501,
    WS_BADGATEWAY = 502,
    WS_SERVICE_UNAVAILABLE = 503,
	WS_GATEWAY_TIMEOUT = 504,
    WS_HTTP_VERSION_NOTSUPPORTED = 505,
    WS_VARIENT_NEGOTIATES = 506,
    WS_INSUFFICIENT_STORAGE =507 ,
    WS_LOOP_DETECTED = 508 ,
    WS_BANDWIDTH_LIMIT_EXCEEDED = 509 ,
    WS_NOT_EXTENDED = 510 ,
    WS_NETWORK_AUTHENTICATION_REQUIRED = 511,
    WS_ORIGINE_ERROR =  520 ,
    WS_NETWORK_READ_TIMEOUT = 598,
    WS_NETWORK_CONNECT_TIMEOUT = 599 ,
    
    //HTTP TIME OUT
    WS_ERROR_TIMEOUT = -1001,
    WS_NET_SERVICE_TIMEOUT = -72007L,

    //HOST HOST ERROR
    WS_HOST_NOTFOUND = 1,
    WS_HOST_ERROR_UNKNOWN = 2,

	WS_UNKNOWN = 8000,
	   
    //NO INTERNET ERROR
    WS_HTTP_CONNECTION_LOST = 302,
    WS_CANNOT_CONNECT_TO_HOST = -1004,
	WS_NETWORK_CONNECTION_LOST = -1005,
	WS_NOT_CONNECTED_TO_INTERNET = -1009,
    
    //parse errors
    WS_PARSE_ERROR = -2000
    
   }WSErrorCode;

@interface WSError : NSObject

/**
 * @brief Error code
 */
@property(nonatomic,assign) WSErrorCode errorCode;

/**
 * @brief Error subcodes
 */
@property(nonatomic,assign) int errorSubCode;

/**
 * @brief  Error description
 */
@property(nonatomic,strong) NSString *errorDescription;

/**
 * @brief Initialize WSError
 *
 * @details Initialize WSError for a error. Will read appropriate description for given error code.
 *
 * @param WSErrorCode $errorCode
 *      Error Code
 *
 * @return id
 *   returns WSError object
 */
- (id) initWithErrorCode:(WSErrorCode) errorCode;

/**
 * @brief Initialize WSError
 *
 * @details Initialize WSError for a error. Will read appropriate description for given error code.
 *
 * @param errorCode Error Code
 *
 * @param description Additional description about error
 *
 * @return returns WSError object
 */
- (id) initWithErrorCode:(WSErrorCode) errorCode
          andDescription:(NSString *) errorDescription;

/**
 * @brief Initialize WSError
 *
 * @details Initialize WSError for a error. Will append given description to default description for given error code.
 *
 * @param errorCode Error Code
 *
 * @param errorSubCode Error sub code for additional info.
 *
 * @param description Additional description about error
 *
 * @return id
 *   returns WSError object
 */
- (id) initWithErrorCode:(WSErrorCode) errorCode
         andErrorSubCode:(int)errorSubCode
          andDescription:(NSString *) errorDescription;


@end
