//
//  IWAdvanceSearchContainerTableViewController.swift
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 27/06/16.
//  Copyright © 2016 Revealing Hour Creations. All rights reserved.
//

import Foundation
import UIKit

@objc protocol ContainerViewDelegate
{
    optional func cellSelectedAuther()
    optional func cellSelectedCompilation()
    optional func cellSelectedVolume()
}

class IWAdvanceSearchContainerTableViewController: UITableViewController
{
    @IBOutlet weak var cellAuther: UITableViewCell!
    @IBOutlet weak var cellCompilation: UITableViewCell!
    @IBOutlet weak var cellVolume: UITableViewCell!
    
    var delegateContainerView:ContainerViewDelegate?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        
        if (delegateContainerView != nil)
        {
            if cell === cellAuther
            {
                delegateContainerView?.cellSelectedAuther!()
            }
            else if cell === cellCompilation
            {
                delegateContainerView?.cellSelectedCompilation!()
            }
            else if cell === cellVolume
            {
                delegateContainerView?.cellSelectedVolume!()
            }
        }
    }
}