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
     
//        NSTimer.scheduledTimerWithTimeInterval(20, target: self, selector: Selector(handleNotificationAction(IWQuoteListItem())), userInfo: nil, repeats: false)

        self.configureNotification()
        
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
        
        self.configureNotification()
    }
    
    func requestFailed(webService: BaseWebService!, error: WSError!)
    {
    }
    
    // MARK: Show random quote
    
    func getRandomQuoteItem() -> IWQuoteListItem
    {
        var quoteListItem: IWQuoteListItem =  IWQuoteListItem()
        
        let  arr:Array = self.retrieveQuotes()!
                                
        if arr.count > 0
        {
            let quoteItem: IWQuoteItem = arr[self.randomNumber(0...arr.count-1)]
                                        
            if quoteItem.arrListItems.count > 0
            {
               quoteListItem = quoteItem.arrListItems[self.randomNumber(0...quoteItem.arrListItems.count-1)] as! IWQuoteListItem
            }
        }
        
        return quoteListItem
    }
    
    @objc func handleNotificationAction(quoteListItem:IWQuoteListItem)
    {
        
//        IWUserActionManager.sharedManager().showChapterWithPath("sabcl/24/difficulties-of-the-path-vii", andItemIndex: 0, andShouldForcePush: true, andShouldUpdateVolumeUrl: true, andParagraphIndex: Int32(0),andShouldForceOnRoot: true )
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
        {
            dispatch_async(dispatch_get_main_queue(),
            {
                /*
                 "ref": "http://incarnateword.in/sabcl/24/difficulties-of-the-path-vii#p13",
                 */
                
                print(quoteListItem.strRefUrl)
                
                let strUrl: String =  quoteListItem.strRefUrl.stringByReplacingOccurrencesOfString("http://incarnateword.in/", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                let arrComponent : [String] = strUrl.componentsSeparatedByString("#")
                var iParaIndex: Int = 0
                if let paragraphIndex: String = arrComponent.last
                {
                    if paragraphIndex is String
                    {
                        let index:String = paragraphIndex.stringByReplacingOccurrencesOfString("p", withString: "")
                        iParaIndex = Int(index)!
                    }
                }
                
                IWUserActionManager.sharedManager().showChapterWithPath(arrComponent[0], andItemIndex: 0, andShouldForcePush: true, andShouldUpdateVolumeUrl: true, andParagraphIndex: Int32(iParaIndex), andShouldForceOnRoot: false )
                


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
    
    func archiveQuoteListItem(quoteListItem:[IWQuoteListItem]) -> NSData
    {
        let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(quoteListItem as NSArray)
        return archivedObject
    }
    
    func retrieveQuoteListItem(data:NSData) -> [IWQuoteListItem]?
    {
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [IWQuoteListItem]
    }
    
    
    func configureNotification()
    {
        self.cancelAllNotifications()
        
        if self.getIsNotifcationOnValue() == false
        {
            print("Notification switch is OFF")
            return
        }
        
        let secondsBetween = abs(Int(self.getFromTime().timeIntervalSinceDate(self.getToTime())))
        let minuteIncrementer:Int = Int(secondsBetween/60)/self.getNotificationsPerDayCount()
        
        print("Notification Interval In Minutes: \(minuteIncrementer)")
        
        let calendar = NSCalendar.currentCalendar()
        let hour = calendar.component(NSCalendarUnit.Hour, fromDate: self.getFromTime())
        let minute = calendar.component(NSCalendarUnit.Minute, fromDate: self.getFromTime())
        
        for index in 1...self.getNotificationsPerDayCount()
        {
            if index == 1
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                {
                    self.scheduleNotification(hour, forMinute: minute)
                })
            }
            else
            {
                var nextHour = hour + Int((minute + minuteIncrementer*(index-1))/60)
                
                if nextHour > 24
                {
                    nextHour = nextHour - 24
                }
                
                let nextMinute = Int((minute + minuteIncrementer*(index-1))%60)
                
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                {
                    self.scheduleNotification(nextHour, forMinute: nextMinute)
                })

            }
        }
    }
    
    func scheduleNotification(forHour:Int, forMinute:Int)
    {
        guard let quoteListItem: IWQuoteListItem = self.getRandomQuoteItem() else
        {
            return
        }
        
        guard (quoteListItem.strAuth != nil) else
        {
            return
        }
        
        var strTitle:String = quoteListItem.strAuth;
        
        if(strTitle == "sa")
        {
            strTitle = "Sri Aurobindo"
        }
        else if(strTitle == "m")
        {
            strTitle = "The Mother"
        }
        
        let compoundString = "\(forHour):\(forMinute)"
        print("Scheduled Local Notification: "+compoundString)
        
        let dateFire: NSDateComponents = NSDateComponents()
        let getCurrentYear = dateFire.year
        let getCurrentMonth = dateFire.month
        let getCurrentDay = dateFire.day
        
        dateFire.year = getCurrentYear
        dateFire.month = getCurrentMonth
        dateFire.day = getCurrentDay
        dateFire.hour = forHour
        dateFire.minute = forMinute
        dateFire.timeZone = NSTimeZone.defaultTimeZone()
        
        
        let calender: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let date: NSDate = calender.dateFromComponents(dateFire)!
        
        let localNotification = UILocalNotification()
        localNotification.fireDate = date // NSDate (timeIntervalSinceNow: 5)//date
        
        if #available(iOS 8.2, *)
        {
            localNotification.alertTitle = strTitle
        }
        else
        {
            // Fallback on earlier versions
        }
        
        localNotification.alertBody = quoteListItem.strSelText
        localNotification.alertAction = "open"
        localNotification.repeatInterval = NSCalendarUnit.Day
        localNotification.userInfo = ["IWQuoteListItem" : self.archiveQuoteListItem([quoteListItem])]
        
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
        
        self.configureNotification()
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
        
        if bIsOn == false
        {
           self.cancelAllNotifications()
        }
        else
        {
            self.configureNotification()
        }
    }
    
    func cancelAllNotifications()
    {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
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
        if self.isValidTimeInterval(date, dateTwo: self.getToTime()) == false
        {
            return
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(date, forKey: "NotifcationFromDate")
        defaults.synchronize()
        
        self.configureNotification()
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
        if self.isValidTimeInterval(date, dateTwo: self.getFromTime()) == false
        {
            return
        }
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(date, forKey: "NotifcationToDate")
        defaults.synchronize()
        
        self.configureNotification()
    }
    
    private func isValidTimeInterval(dateOne:NSDate,dateTwo:NSDate)->Bool
    {        
        let secondsBetween = abs(Int(dateOne.timeIntervalSinceDate(dateTwo)))
        let minuteDifference:Int = Int(secondsBetween/60)
        
        return minuteDifference >= 60
    }
}
