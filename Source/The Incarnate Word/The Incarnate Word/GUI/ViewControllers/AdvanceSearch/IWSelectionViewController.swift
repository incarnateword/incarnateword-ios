//
//  IWSelectionViewController.swift
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 06/07/16.
//  Copyright © 2016 Revealing Hour Creations. All rights reserved.
//

import Foundation
import UIKit

public class IWSelectionViewController: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    public var arrDataSource:[AnyObject]       = []
    public var arrSelectionList:[AnyObject]    = []
    
    @IBOutlet weak var tableViewList: UITableView!
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    // MARK: TableView Callbacks
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrDataSource.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomCell", forIndexPath: indexPath)
        
        return cell
    }
}