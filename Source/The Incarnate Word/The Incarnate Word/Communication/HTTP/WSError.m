//
//  WSError.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 16/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "WSError.h"

@implementation WSError

// Initialize With Error code.
- (id) initWithErrorCode:(WSErrorCode) errorCode
{
    self = [super init];
    if (self)
    {
        _errorCode = errorCode;
        _errorDescription = [self getErrorDescriptionFor:_errorCode];
    }
    return self;
}

// Initialize With Error code and Error sub code
- (id) initWithErrorCode:(WSErrorCode) errorCode
          andDescription:(NSString *) description
{
    self = [super init];
    if (self)
    {
        _errorCode = errorCode;
        if (description)
        {
            _errorDescription = [[NSString alloc] initWithFormat:@"%@",description];
        }
        else
        {
            _errorDescription = [self getErrorDescriptionFor:_errorCode];
        }
    }
    return self;
}

// Initialize With Error code Error sub code and Error Description
- (id) initWithErrorCode:(WSErrorCode) errorCode
         andErrorSubCode:(int)errorSubCode
          andDescription:(NSString *) description
{
    self = [super init];
    if (self)
    {
        _errorCode = errorCode;
        _errorSubCode = errorSubCode;
        if (description)
        {
            _errorDescription = [[NSString alloc] initWithFormat:@"%@.%@",[self getErrorDescriptionFor:_errorCode],description];
        }
        else
        {
            _errorDescription = [self getErrorDescriptionFor:_errorCode];
        }
    }
    return self;
}

// Basic description of different errors.
- (NSString *) getErrorDescriptionFor:(WSErrorCode) errorCode
{
    NSString *description = nil;
    
    switch (errorCode)
    {
        case WS_AUTHORITATIVE_INFO:
             description = @"ERROR : The server successfully processed the request, but is returning information that may be from another source.";
             break;
        case WS_RESETCONTENT:
             description = @"ERROR : The server successfully processed the request, but did not return any content";
             break;
        case WS_PARTIAL_CONTENT:
             description = @"ERROR : The server is delivering only part of the resource (byte serving) due to a range header sent by the client";
             break;
        case WS_ALREADY_REPOPRTED :
             description = @"ERROR : The members of a DAV binding have already been enumerated in a previous reply to this request, and are not being included again";
             break;
        case  WS_IM_USED :
            description = @"ERROR : The server has fulfilled a GET request for the resource, and the response is a representation of the result of one or more instance-manipulations applied to the current instance.";
            break;
        case WS_NOCONTENT:
             description = @"ERROR : The server successfully processed the request, but did not return any content";
            break;
        case WS_BADREQUEST :
             description = @"ERROR : The request cannot be fulfilled due to bad syntax";
             break;
        case WS_UNAUTHORIZED :
             description = @"ERROR : Authentication is required";
             break;
        case  WS_PAYMENT_REQUIRED :
             description = @"ERROR : Payment is required";
             break;
        case  WS_FORBIDDEN :
             description = @"ERROR : The request was a valid request, but the server is refusing to respond to it";
             break;
        case  WS_NOTFOUND :
             description = @"ERROR : The requested resource could not be found but may be available again in the future";
            break;
        case WS_NOT_ACCEPTABLE:
             description = @"ERROR: The requested resource is only capable of generating content not acceptable according to the Accept headers sent in the request";
             break;
        case  WS_METHOD_NOTALLOWED :
             description = @"ERROR : A request was made of a resource using a request method not supported by that resource";
             break;
        case  WS_PROXYAUTHENTICATIONREQUIRED :
             description = @"ERROR : The client must first authenticate itself with the proxy";
             break;
        case WS_CONFLICT:
            description = @"ERROR : The request could not be processed because of conflict in the request.";
            break;
        case WS_GONE:
            description = @"ERROR : The resource requested is no longer available and will not be available again";
            break;
        case WS_LENGHT_REQUIRED:
            description = @"ERROR : The request did not specify the length of its content, which is required by the requested resource";
            break;
        case WS_PRECONDITION_FAILED:
            description = @"ERROR : The server does not meet one of the preconditions that the requester put on the request";
            break;
        case  WS_REQUESTTIMEOUT :
             description = @"ERROR : The server timed out waiting for the request";
             break;
        case  WS_ERROR_TIMEOUT :
            description = @"ERROR : The server timed out waiting for the request";
            break;
        case  WS_NET_SERVICE_TIMEOUT:
            description = @"ERROR : The server timed out waiting for the request";
            break;
        case  WS_REQUEST_TOO_LARGE :
             description = @"ERROR : The request is larger than the server is willing or able to process";
             break;
        case  WS_REQUEST_URI_TOO_LONG :
             description = @"ERROR : The URI provided was too long for the server to process";
             break;
        case WS_UNSUPPORTED_MEDIA_TYPE:
            description = @"ERROR : The request entity has a media type which the server or resource does not support";
            break;
        case WS_REQUEST_RANGE_NOT_SATISFIABLE:
            description = @"ERROR : The client has asked for a portion of the file (byte serving), but the server cannot supply that portion";
            break;
        case WS_EXPECTATION_FAILED:
            description = @"ERROR : The server cannot meet the requirements of the Expect request-header field.";
            break;
        case  WS_AUTHENTICATION_TIMEOUT :
             description = @"ERROR :  Previously valid authentication has expired";
             break;
        case WS_UNPROCESSABLE_ENTITY:
            description = @"ERROR :  The request was well-formed but was unable to be followed due to semantic errors";
            break;
        case WS_LOCKED:
            description = @"ERROR :  The resource that is being accessed is locked.";
            break;
        case WS_FAILED_DEPENDENCY:
            description = @"ERROR :  The request failed due to failure of a previous request.";
            break;
        case WS_UPGRADE_REQUIRED:
            description = @"ERROR :  The client should switch to a different protocol such as TLS/1.0.";
            break;
        case WS_PRECONDITION_REQUIRED:
            description = @"ERROR :  The origin server requires the request to be conditional.";
            break;
        case WS_TOO_MANY_REQUEST:
            description = @"ERROR :  The user has sent too many requests.";
            break;
        case WS_REQUEST_HEADER_TOO_LARGE:
            description = @"ERROR :  The server is unwilling to process the request because either an individual header field, or all the header fields collectively, are too large.";
            break;
        case WS_NETWORK_AUTHENTICATION_REQUIRED :
             description = @"ERROR : The client needs to authenticate to gain network access";
             break;
        case WS_ORIGINE_ERROR:
            description = @"ERROR : The client needs to authenticate to gain network access";
            break;
        case WS_HTTP_VERSION_NOTSUPPORTED :
             description = @"ERROR : he server does not support the HTTP protocol version used in the request";
             break;
        case WS_VARIENT_NEGOTIATES:
            description = @"ERROR : Transparent content negotiation for the request results in a circular reference.";
            break;
        case WS_INSUFFICIENT_STORAGE:
            description = @"ERROR : The server is unable to store the representation needed to complete the request.";
            break;
        case WS_LOOP_DETECTED:
            description = @"ERROR : The server detected an infinite loop while processing the request.";
            break;
        case WS_BANDWIDTH_LIMIT_EXCEEDED:
            description = @"ERROR : Bandwidth limit exceeded ";
            break;
        case WS_NOT_EXTENDED:
            description = @"ERROR : Further extensions to the request are required for the server to fulfil it.";
            break;
        case WS_GATEWAY_TIMEOUT :
             description = @"ERROR : The server was acting as a gateway or proxy and did not receive a timely response from the upstream server";
             break;
        case WS_SERVICE_UNAVAILABLE :
             description = @"ERROR : The server is currently unavailable (because it is overloaded or down for maintenance)";
             break;
        case WS_BADGATEWAY :
             description = @"ERROR : The server was acting as a gateway or proxy and received an invalid response from the upstream server.";
             break;
        case WS_INTERNAL_SERVERERROR :
             description = @"ERROR : An unexpected condition was encountered ";
             break;
        case WS_NOTIMPLEMENTED :
             description = @"ERROR : The server either does not recognize the request method, or it lacks the ability to fulfil the request";
             break;
        case WS_UNKNOWN :
             description = @"ERROR : Unknown";
             break;
        case WS_HOST_NOTFOUND :
             description = @"ERROR : Host not found";
             break;
        case WS_HOST_ERROR_UNKNOWN:
             description = @"ERROR : Host unknown error";
             break;
        case WS_HTTP_CONNECTION_LOST :
             description = @"ERROR : HTTP coonection is lost";
             break;
        case WS_NETWORK_CONNECTION_LOST :
             description = @"ERROR : Network connection is lost";
             break;
        case WS_NOT_CONNECTED_TO_INTERNET :
             description = @"No network connection detected. Please ensure you are connected to a network source and try again.";
             break;
                   
        default:
            description = @"ERROR : Unknown";
            break;
    }
    
    return description;
}

@end
