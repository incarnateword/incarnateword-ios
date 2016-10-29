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


class IWSelectionViewController: UIViewController,UITableViewDataSource,UITableViewDelegate
{
    var arrDataSource:[AnyObject]    = []
    var arrSelectionList:[AnyObject]        = []
    var delegateSelectionView: SelectionViewDelegate?;
    var arrPreviousSelection:[AnyObject] = []
    var bAllowMultipleSelection:Bool = false
    
    @IBOutlet weak var tableViewList: UITableView!
    
    override func viewDidLoad()
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
        
        tableViewList.tableFooterView = UIView()

    }
    
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        tableViewList.reloadData()
        arrSelectionList.removeAll()
        
        //keep only one element if multiple selection not allowed
        if bAllowMultipleSelection == false && arrPreviousSelection.count > 1
        {
            var firstObject = arrPreviousSelection[0]
            arrPreviousSelection.removeAll()
            arrPreviousSelection[0] = firstObject
        }
        
        arrSelectionList += arrPreviousSelection

    }
    
    @IBAction func buttonCancelClicked()
    {
        arrPreviousSelection.removeAll()

        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func buttonDoneClicked()
    {
        arrPreviousSelection.removeAll()
        
        if (delegateSelectionView != nil)
        {
            delegateSelectionView?.selectionViewSelectedItems(arrSelectionList)
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: TableView Callbacks
      func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrDataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomCell", forIndexPath: indexPath)
        
        let label:UILabel = cell.viewWithTag(501) as! UILabel
        let imageViewCheck:UIImageView = cell.viewWithTag(201) as! UIImageView
        
        
        imageViewCheck.image = nil
        let title:String = (arrDataSource[indexPath.row] as? String)!
        
        for str in arrSelectionList
        {
            if str as! String == title
            {
                imageViewCheck.image = UIImage(named:"ic_check")
                break
            }
        }
        
        label.text = title
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if bAllowMultipleSelection == false
        {
            arrSelectionList.removeAll()
        }
        
        
        if arrSelectionList.count == 0
        {
            arrSelectionList = [arrDataSource[indexPath.row]]
        }
        else
        {
            let title = arrDataSource[indexPath.row] as! String
            
            if let index = (arrSelectionList as! [String]).indexOf(title)
            {
                arrSelectionList.removeAtIndex(index)
            }
            else
            {
                arrSelectionList += [title]
            }
        }
        
        tableView.reloadData()

    }
    
}