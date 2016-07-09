//
//  IWSelectionViewController.swift
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 06/07/16.
//  Copyright © 2016 Revealing Hour Creations. All rights reserved.
//

import Foundation
import UIKit


protocol SelectionViewDelegate
{
    func selectionViewSelectedItems(selectionItems:[AnyObject])
}


public class IWSelectionViewController: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    public var arrDataSource:[AnyObject]    = []
    var arrSelectionList:[AnyObject]        = []
    
    @IBOutlet weak var tableViewList: UITableView!
    
    override public func viewDidLoad()
    {

        super.viewDidLoad()

        
        let buttonleft = UIBarButtonItem(
            title: "Cancel",
            style: .Plain,
            target: self,
            action: #selector(buttonCancelClicked)
        )
        self.navigationItem.leftBarButtonItem = buttonleft

        
        let buttonRight = UIBarButtonItem(
            title: "Done",
            style: .Plain,
            target: self,
            action: #selector(buttonDoneClicked)
        )
        
        self.navigationItem.rightBarButtonItem = buttonRight
    }
    
    @IBAction func buttonCancelClicked()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func buttonDoneClicked()
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: TableView Callbacks
     public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrDataSource.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomCell", forIndexPath: indexPath)
        
        cell.textLabel?.text = arrDataSource[indexPath.row] as? String
        
        return cell
    }
}