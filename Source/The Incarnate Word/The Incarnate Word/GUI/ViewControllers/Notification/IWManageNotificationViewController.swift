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
    var bIsFromCellExpanded:Bool = false
    var bIsToCellExpanded:Bool = false
    
    @IBOutlet weak var switchNotification: UISwitch!
    @IBOutlet weak var labelNotificationsPerDay: UILabel!
    @IBOutlet weak var cellTimeFrom: UITableViewCell!
    @IBOutlet weak var datePickerFrom: UIDatePicker!
    @IBOutlet weak var datePickerTo: UIDatePicker!
    
    @IBAction func notificationPerDayStepperValueChanged(sender: AnyObject)
    {
    }
    
    @IBAction func notitifacationSwitchValueChanged(sender: AnyObject)
    {
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

}
