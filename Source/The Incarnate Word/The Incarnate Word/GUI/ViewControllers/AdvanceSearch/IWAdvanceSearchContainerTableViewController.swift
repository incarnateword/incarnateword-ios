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
    optional func cellSelectedYear()
    optional func cellSelectedMonth()
    optional func cellSelectedDate()
}

enum EnumSelectedSegment
{
    case SelectedSegmentFilter
    case SelectedSegmentGoToDate
}

class IWAdvanceSearchContainerTableViewController: UITableViewController
{
    @IBOutlet weak var cellAuther: UITableViewCell!
    @IBOutlet weak var cellCompilation: UITableViewCell!
    @IBOutlet weak var cellVolume: UITableViewCell!
    
    @IBOutlet weak var cellYear: UITableViewCell!
    @IBOutlet weak var cellMonth: UITableViewCell!
    @IBOutlet weak var cellDate: UITableViewCell!
    
    var delegateContainerView:ContainerViewDelegate?
    var _selectedSegment:EnumSelectedSegment = .SelectedSegmentFilter

    func updateTableContent()
    {
        self.tableView.reloadData()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
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
            else if cell === cellYear
            {
                delegateContainerView?.cellSelectedYear!()
            }
            else if cell === cellMonth
            {
                delegateContainerView?.cellSelectedMonth!()
            }
            else if cell === cellDate
            {
                delegateContainerView?.cellSelectedDate!()
            }
        }
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if(_selectedSegment == .SelectedSegmentFilter)
        {
            if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2
            {
                return 44
            }
        }
        
        if(_selectedSegment == .SelectedSegmentGoToDate)
        {
            if indexPath.row == 0 || indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 5
            {
                return 44
            }
        }
        
        return 0
        
    }
}