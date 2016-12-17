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
        
        self .configureNotification()
        
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
    
    func configureNotification()
    {
        let dateFire: NSDateComponents = NSDateComponents()
        let getCurrentYear = dateFire.year
        let getCurrentMonth = dateFire.month
        let getCurrentDay = dateFire.day
        
        dateFire.year = getCurrentYear
        dateFire.month = getCurrentMonth
        dateFire.day = getCurrentDay
        dateFire.hour = 18
        dateFire.minute = 31
        dateFire.timeZone = NSTimeZone.defaultTimeZone()
        
        
        let calender: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let date: NSDate = calender.dateFromComponents(dateFire)!
        
        let localNotification = UILocalNotification()
        localNotification.fireDate = date // NSDate (timeIntervalSinceNow: 5)//date
        localNotification.alertBody = "A new day has begun and a fresh layer on snow lies on the mountain! Can you beat your highscore?"
        localNotification.alertAction = "open"
        localNotification.repeatInterval = NSCalendarUnit.Day
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
    }
    
    //Notifications Per Day Count
    func getNotificationsPerDayCount() ->Int
    {
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("NotificationsPerDayCount")
        {
            return NSUserDefaults.standardUserDefaults().objectForKey("NotificationsPerDayCount") as! Int
        }
        
        return 3
    }
    
    func setNotificationPerDayCount(count:Int)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(count, forKey: "NotificationsPerDayCount")
        defaults.synchronize()
    }

    //Is Notification On
    func getIsNotifcationOnValue() -> Bool
    {
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("IsNotifcationOnValue")
        {
            return NSUserDefaults.standardUserDefaults().objectForKey("IsNotifcationOnValue") as! Bool
        }
        
        return true
    }
    
    func setIsNotifcationOnValue(bIsOn:Bool)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(bIsOn, forKey: "IsNotifcationOnValue")
        defaults.synchronize()
    }
    
    //From Time
    func getFromTime() -> NSDate
    {
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("NotifcationFromDate")
        {
            return NSUserDefaults.standardUserDefaults().objectForKey("NotifcationFromDate") as! NSDate
        }
        
        let dateFire: NSDateComponents = NSDateComponents()
        let getCurrentYear = dateFire.year
        let getCurrentMonth = dateFire.month
        let getCurrentDay = dateFire.day
        
        dateFire.year = getCurrentYear
        dateFire.month = getCurrentMonth
        dateFire.day = getCurrentDay
        dateFire.hour = 10
        dateFire.minute = 0
        dateFire.timeZone = NSTimeZone.defaultTimeZone()
        
        let calender: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let date: NSDate = calender.dateFromComponents(dateFire)!
        
        return date
    }
    
    func setFromTime(date:NSDate)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(date, forKey: "NotifcationFromDate")
        defaults.synchronize()
    }
    
    //To Time
    func getToTime() -> NSDate
    {
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("NotifcationToDate")
        {
            return NSUserDefaults.standardUserDefaults().objectForKey("NotifcationToDate") as! NSDate
        }
        
        let dateFire: NSDateComponents = NSDateComponents()
        let getCurrentYear = dateFire.year
        let getCurrentMonth = dateFire.month
        let getCurrentDay = dateFire.day
        
        dateFire.year = getCurrentYear
        dateFire.month = getCurrentMonth
        dateFire.day = getCurrentDay
        dateFire.hour = 21
        dateFire.minute = 0
        dateFire.timeZone = NSTimeZone.defaultTimeZone()
        
        let calender: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let date: NSDate = calender.dateFromComponents(dateFire)!
        
        return date
    }
    
    func setToTime(date:NSDate)
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(date, forKey: "NotifcationToDate")
        defaults.synchronize()
    }
}
