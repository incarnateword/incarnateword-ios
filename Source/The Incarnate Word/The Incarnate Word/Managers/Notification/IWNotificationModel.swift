//
//  IWNotificationModel.swift
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 12/12/16.
//  Copyright © 2016 Revealing Hour Creations. All rights reserved.
//

import Foundation
import UIKit

class IWNotificationModel:NSObject,WebServiceDelegate
{
    static let sharedInstance = IWNotificationModel()
    var webServiceNotificationData:IWNotificationDataWebService?;

    override init()
    {
        super.init()
        
        webServiceNotificationData = IWNotificationDataWebService.init(delegate: self)
        webServiceNotificationData?.sendAsyncRequest()

    }
    
    
    // MARK: WebService Delegate
    
    func requestSucceed(webService: BaseWebService!, response responseModel: AnyObject!)
    {
        print("Response Quotes: \(responseModel) ")
    }
    
    func requestFailed(webService: BaseWebService!, error: WSError!)
    {
    }
}
