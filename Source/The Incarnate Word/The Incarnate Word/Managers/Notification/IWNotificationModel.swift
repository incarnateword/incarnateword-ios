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
    var arrQuoteItems: Array = Array<IWQuoteItem>()

    override init()
    {
        super.init()
        
        let  arr:Array = self.retrieveQuotes()!
        
        if arr.count == 0
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
            {
                self.webServiceNotificationData = IWNotificationDataWebService.init(delegate: self)
                self.webServiceNotificationData?.sendAsyncRequest()
            })
        }
        else
        {
//            self.showRandomQuote()
        }
    }
    
    
    // MARK: WebService Delegate
    
    func requestSucceed(webService: BaseWebService!, response responseModel: AnyObject!)
    {
        print("Response Quotes: \(responseModel) ")
        
        arrQuoteItems = responseModel as! Array<IWQuoteItem>
        
        self.saveQuotes(arrQuoteItems)

    }
    
    func requestFailed(webService: BaseWebService!, error: WSError!)
    {
    }
    
    // MARK: Show random quote
    
    func showRandomQuote()
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                       {
                        dispatch_async(dispatch_get_main_queue(),
                            {
                                let  arr:Array = self.retrieveQuotes()!
                                
                                    if arr.count > 0
                                    {
                                        let quoteItem: IWQuoteItem = arr[self.randomNumber(0...arr.count-1)]
                                        
                                        if quoteItem.arrListItems.count > 0
                                        {
                                            let quoteListItem: IWQuoteListItem = quoteItem.arrListItems[self.randomNumber(0...quoteItem.arrListItems.count-1)] as! IWQuoteListItem
                                            
                                            print(quoteListItem.strRefUrl)
                                            
                                            let strUrl: String =  quoteListItem.strRefUrl.stringByReplacingOccurrencesOfString("http://incarnateword.in/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                                            let arrComponent : [String] = strUrl.componentsSeparatedByString("#")
                                            
                                            IWUserActionManager.sharedManager().showChapterWithPath(arrComponent[0], andItemIndex: 0, andShouldForcePush: true, andShouldUpdateVolumeUrl: true)
                                            
                                            //IWUserActionManager.sharedManager().showChapterWithPath("sabcl/24/difficulties-of-the-path-vii", andItemIndex: 0, andShouldForcePush: true, andShouldUpdateVolumeUrl: true)
                                        }
                                    }
                        })
        })
    }

    //MARK: Random number in range
    
    func randomNumber(range: Range<Int>) -> Int
    {
        let min = range.startIndex
        let max = range.endIndex
        return Int(arc4random_uniform(UInt32(max - min))) + min
    }

    //MARK: Quotes caching
    
    func saveQuotes(quotes:[IWQuoteItem])
    {
        let archivedObject = archiveQuotesArray(quotes)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(archivedObject, forKey: "Quotes")
        defaults.synchronize()
    }
    
    func archiveQuotesArray(quotes:[IWQuoteItem]) -> NSData
    {
        let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(quotes as NSArray)
        return archivedObject
    }
    
    func retrieveQuotes() -> [IWQuoteItem]?
    {
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey("Quotes") as? NSData
        {
            return NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [IWQuoteItem]
        }
        
        return NSArray() as? [IWQuoteItem]
    }
}
