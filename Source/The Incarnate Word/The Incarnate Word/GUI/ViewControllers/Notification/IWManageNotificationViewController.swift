//
//  IWManageNotificationViewController.swift
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 29/11/16.
//  Copyright © 2016 Revealing Hour Creations. All rights reserved.
//


import Foundation
import UIKit

class IWManageNotificationViewController: UITableViewController
{
    
    private var bIsFromCellExpanded:Bool = false
    private var bIsToCellExpanded:Bool = false
    private var dateSelectedFrom:NSDate?
    private var dateSelectedTo:NSDate?
    
    
    @IBOutlet weak var switchNotification: UISwitch!
    @IBOutlet weak var labelNotificationsPerDay: UILabel!
    @IBOutlet weak var cellTimeFrom: UITableViewCell!
    @IBOutlet weak var datePickerFrom: UIDatePicker!
    @IBOutlet weak var datePickerTo: UIDatePicker!
    @IBOutlet weak var labelFromDetail: UILabel!
    @IBOutlet weak var labelToDetail: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        self.configureUI()
    }
    
    private func configureUI()
    {
        switchNotification.on = IWNotificationModel.sharedInstance.getIsNotifcationOnValue()
        
        self.updateNotificationPerDayText()
        

        self.updateFromDateLabel()
        self.updateToDateLabel()
    }
    

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        var rowHeight: CGFloat = 44
        
        if indexPath.section == 1 && indexPath.row == 0
        {
            datePickerFrom.hidden = !bIsFromCellExpanded
            
            if bIsFromCellExpanded
            {
                rowHeight = 200
            }
        }
        else if indexPath.section == 1 && indexPath.row == 1
        {
            datePickerTo.hidden = !bIsToCellExpanded
            
            if bIsToCellExpanded
            {
                rowHeight = 200
            }
        }
        
        return rowHeight
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if indexPath.section == 1 && indexPath.row == 0
        {
            bIsFromCellExpanded = !bIsFromCellExpanded
            
            if bIsFromCellExpanded
            {
                bIsToCellExpanded = false
            }
            
            self.tableView.reloadData()
        }
        else if indexPath.section == 1 && indexPath.row == 1
        {
            bIsToCellExpanded = !bIsToCellExpanded
            
            if bIsToCellExpanded
            {
                bIsFromCellExpanded = false
            }
            
            self.tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerLabel:UILabel = UILabel()
        headerLabel.font = UIFont (name: FONT_TITLE_REGULAR, size: 16.0)
        headerLabel.textColor = UIColor.darkGrayColor()

        switch (section)
        {
            case 1:
                
                headerLabel.text = "    Time Interval (minimum 1 hour)";

            default:
                headerLabel.text = "";
        }
        
        return headerLabel
    }
    
    @IBAction func notificationPerDayStepperValueChanged(sender: AnyObject)
    {
        let notifStepper: UIStepper = sender as! UIStepper
        IWNotificationModel.sharedInstance.setNotificationPerDayCount(Int(notifStepper.value))
        self.updateNotificationPerDayText()
    }
    
    @IBAction func notitifacationSwitchValueChanged(sender: AnyObject)
    {
        let notifSwitch: UISwitch = sender as! UISwitch
        IWNotificationModel.sharedInstance.setIsNotifcationOnValue(notifSwitch.on)
    }
    
    
    @IBAction func datePickerValueChanged(sender: AnyObject)
    {
        var dateSelected:NSDate = datePickerFrom.date
        
        if sender === datePickerTo
        {
            dateSelected = datePickerTo.date
        }
        
        let calendar = NSCalendar.currentCalendar()
        let hour = calendar.component(NSCalendarUnit.Hour, fromDate: dateSelected)
        let minute = calendar.component(NSCalendarUnit.Minute, fromDate: dateSelected)
        
        
        let dateFire: NSDateComponents = NSDateComponents()
        let getCurrentYear = dateFire.year
        let getCurrentMonth = dateFire.month
        let getCurrentDay = dateFire.day
        
        dateFire.year = getCurrentYear
        dateFire.month = getCurrentMonth
        dateFire.day = getCurrentDay
        dateFire.hour = hour
        dateFire.minute = minute
        dateFire.timeZone = NSTimeZone.defaultTimeZone()
        
        let calender: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let date: NSDate = calender.dateFromComponents(dateFire)!
        
        if sender === datePickerFrom
        {
            IWNotificationModel.sharedInstance.setFromTime(date)
            self.updateFromDateLabel()
  
        }
        else if sender === datePickerTo
        {
            IWNotificationModel.sharedInstance.setToTime(date)
            self.updateToDateLabel()
        }
    }
    
    private func updateNotificationPerDayText()
    {
        stepper.value = Double(IWNotificationModel.sharedInstance.getNotificationsPerDayCount())

        let strPerDayNotif:String = String(format: "Notifications per day (%d)",IWNotificationModel.sharedInstance.getNotificationsPerDayCount())
        labelNotificationsPerDay.text = strPerDayNotif
    }
    
    private func updateFromDateLabel()
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh : mm a"
        
        
        let fromDate:NSDate = IWNotificationModel.sharedInstance.getFromTime()
        datePickerFrom.date = fromDate
        labelFromDetail.text = dateFormatter.stringFromDate(fromDate)
    }
    
    private func updateToDateLabel()
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh : mm a"
        
        let toDate:NSDate = IWNotificationModel.sharedInstance.getToTime()
        datePickerTo.date = toDate
        labelToDetail.text = dateFormatter.stringFromDate(toDate)
    }
    

}



