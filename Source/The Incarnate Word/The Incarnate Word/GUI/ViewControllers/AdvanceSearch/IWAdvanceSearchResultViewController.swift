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
    var arrSearchResult = [AnyObject]()

    @IBOutlet weak var tableViewResult: UITableView!
    
    // MARK: View Life Cycle
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    public override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
    }
 
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        
        webServiceSerch = IWSearchWebService.init(searchString: strSearch, andAuther: strAuther, andCompilation: strCollection, andVolume: strVolume, andStartIndex: 0, andDelegate: self)
        webServiceSerch?.sendAsyncRequest()
        
    }

    
    // MARK: TableView Callbacks
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return arrSearchResult.count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CustomCell", forIndexPath: indexPath)

        
        
        let searchItem:IWSearchItemStructure = arrSearchResult[indexPath.row] as! IWSearchItemStructure
        let  lblTitle:UILabel       = cell.viewWithTag(201) as! UILabel
        let  lblText:UILabel       = cell.viewWithTag(202) as! UILabel
        lblTitle.text = searchItem.strTitle;
        
        var strMut:String = ""
        
        
        for str in searchItem.arrHighlightText
        {
            if (str.isKindOfClass(NSNull) == false)
            {
                strMut = strMut+str.stringByReplacingOccurrencesOfString("\n", withString: " ")
                strMut = strMut+"... "
            }
        }
        
        strMut = strMut.stringByReplacingOccurrencesOfString("<em>", withString: "")
        strMut = strMut.stringByReplacingOccurrencesOfString("</em>", withString: "")


        
        lblText.text = strMut;
        
        
        
        return cell
        
    }

    // MARK: WebService Delegate
    
    public func requestSucceed(webService: BaseWebService!, response responseModel: AnyObject!)
    {
        print("Response: \(responseModel) ")
        
        let searchResult = responseModel as! IWSearchStructure;
        
       arrSearchResult = NSArray().arrayByAddingObjectsFromArray(searchResult.arrSearchItems)
        
        tableViewResult.performSelectorOnMainThread(#selector(tableViewResult.reloadData), withObject: nil, waitUntilDone: false)
    }
    
    public func requestFailed(webService: BaseWebService!, error: WSError!)
    {
        
    }
}
