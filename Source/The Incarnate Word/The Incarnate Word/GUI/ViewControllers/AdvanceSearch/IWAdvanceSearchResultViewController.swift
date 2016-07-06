//
//  IWAdvanceSearchResultViewController.swift
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 29/06/16.
//  Copyright © 2016 Revealing Hour Creations. All rights reserved.
//

import Foundation
import UIKit

public class IWAdvanceSearchResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,WebServiceDelegate
{
    var strSearch:String = "";
    var strAuther:String = "";
    var strCollection:String = "";
    var strVolume:String = "";
    var webServiceSerch:IWSearchWebService?;

    // MARK: View Life Cycle
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
    }

    // MARK: TableView Callbacks
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "CustomCell")
        return cell
        
    }

    // MARK: WebService Delegate
    
    public func requestSucceed(webService: BaseWebService!, response responseModel: AnyObject!)
    {
        
    }
    
    public func requestFailed(webService: BaseWebService!, error: WSError!)
    {
        
    }
}
