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

    @IBOutlet weak var switchNotification: UISwitch!
    @IBOutlet weak var labelNotificationsPerDay: UILabel!
    @IBOutlet weak var cellTimeFrom: UITableViewCell!
    @IBOutlet weak var cellTimeTo: UITableViewCell!
    
    @IBAction func notificationPerDayStepperValueChanged(sender: AnyObject)
    {
    }
    
    @IBAction func notitifacationSwitchValueChanged(sender: AnyObject)
    {
    }
}
