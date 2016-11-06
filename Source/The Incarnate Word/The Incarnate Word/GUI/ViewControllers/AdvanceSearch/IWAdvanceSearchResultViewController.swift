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
    
    var strYear:String = ""
    var strMonth:String = ""
    var strDay:String = ""
    
    var webServiceSerch:IWSearchWebService?;
    var arrSearchResult = [AnyObject]()
    var _bSearchRequestIsInProgress:Bool = false;
    var _iTotalNumberOfRecords:Int = 0;
    var _selectedSegment:EnumSelectedSegment = .SelectedSegmentFilter

    @IBOutlet weak var constraintHeightViewSearchResult: NSLayoutConstraint!
    @IBOutlet weak var constraintHeightViewLoadingMore: NSLayoutConstraint!
    @IBOutlet weak var tableViewResult: UITableView!
    @IBOutlet weak var labelCount: UILabel!
    
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
        
        _bSearchRequestIsInProgress = true
        _iTotalNumberOfRecords = 0;
        constraintHeightViewLoadingMore.constant = 0;
        constraintHeightViewLoadingMore.constant = 0;
        tableViewResult.tableFooterView = UIView()
        self.navigationItem.title = strSearch
        
        let backButton = UIBarButtonItem(
            title: "Back",
            style: UIBarButtonItemStyle.Plain,
            target: nil,
            action: nil
        )
        
        self.navigationItem.backBarButtonItem = backButton
        
        if _selectedSegment == .SelectedSegmentFilter
        {
        
        webServiceSerch = IWSearchWebService.init(searchString: strSearch, andAuther: strAuther, andCompilation: strCollection, andVolume: strVolume, andStartIndex: 0, andDelegate: self)
            
        }
        else if _selectedSegment == .SelectedSegmentGoToDate
        {
            webServiceSerch = IWSearchWebService.init(searchYear:strYear,withMonth:strMonth,withDate:strDay,andAuther: strAuther,andStartIndex:0, andDelegate: self)
        }

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
        
        lblText.font = UIFont (name: FONT_TITLE_REGULAR, size: 16.0)
        lblTitle.text = ""
        
        if isObjectNil(searchItem.strTitle) == false
        {
            lblTitle.text = " "+searchItem.strTitle;
        }
        
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
        
        
        let strStrongStart:String = "<strong>",strStrongEnd:String = "</strong>"
        
        var attributedString = NSMutableAttributedString(string:strMut.copy() as! String)

        
        if strMut.rangeOfString(strStrongStart) != nil && strMut.rangeOfString(strStrongEnd) != nil
        {
            let r1:Range  = strMut.rangeOfString(strStrongStart)!
            let r2:Range  = strMut.rangeOfString(strStrongEnd)!
            
            strMut = strMut.stringByReplacingOccurrencesOfString(strStrongStart, withString: "")
            strMut = strMut.stringByReplacingOccurrencesOfString(strStrongEnd, withString: "")
            
            let index = strStrongStart.characters.count + strStrongEnd.characters.count + 1
            
            let rSub:Range = r1.startIndex ... r2.endIndex.advancedBy(-index)
            
            let sub:String = strMut.substringWithRange(rSub)
     
            let searchQuery = sub
            
            attributedString = NSMutableAttributedString(string:strMut.copy() as! String)
            
            let range = (strMut.copy() as! NSString).rangeOfString(searchQuery)
                
            attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: FONT_TITLE_MEDIUM, size: 16.0)!, range: range)
        }
        
        lblText.attributedText = attributedString
        
        return cell
    }
    
    func isObjectNil(object:AnyObject!) -> Bool
    {
        if let _:AnyObject = object
        {
            return false
        }
        
        return true
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        let searchItem:IWSearchItemStructure = arrSearchResult[indexPath.row] as! IWSearchItemStructure
        IWUserActionManager.sharedManager().showChapterWithPath(searchItem.strChapterUrl, andItemIndex: 0, andShouldForcePush:true)
    }

    // MARK: WebService Delegate
    
    public func requestSucceed(webService: BaseWebService!, response responseModel: AnyObject!)
    {
        _bSearchRequestIsInProgress = false

        print("Response: \(responseModel) ")
        
        let searchResult = responseModel as! IWSearchStructure;
        let totalRecordInt32:Int32 = searchResult.iCountRecord
        _iTotalNumberOfRecords = Int(totalRecordInt32);

        if (searchResult.arrSearchItems != nil)
        {
           arrSearchResult += searchResult.arrSearchItems
            
            
          self.updateTableContent()
        }
        
        constraintHeightViewLoadingMore.constant = 0
        
        if (arrSearchResult.count == 0)
        {
            let alert = UIAlertController(title: "No Records", message: "No records found for given search.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
                self.navigationController?.popViewControllerAnimated(true)
            }));
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func updateTableContent()
    {
        
//        _constraintViewSearchResultHeight.constant = HEIGHT_SEARCH_RESULT_VIEW;
        
        if(_iTotalNumberOfRecords != 0)
        {
            constraintHeightViewSearchResult.constant = 20
            labelCount.text = String(format: "%d of %d results", arrSearchResult.count,_iTotalNumberOfRecords)
            


        }
        else
        {
            labelCount.text = "";
        }
        
        
        tableViewResult.performSelectorOnMainThread(#selector(tableViewResult.reloadData), withObject: nil, waitUntilDone: false)

    }
    
    public func requestFailed(webService: BaseWebService!, error: WSError!)
    {
        _bSearchRequestIsInProgress = false
        constraintHeightViewLoadingMore.constant = 0
        
        if (arrSearchResult.count == 0)
        {
            let alert = UIAlertController(title: "Error", message: "Search request failed.", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action:UIAlertAction) in
                self.navigationController?.popViewControllerAnimated(true)
            }));
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: ScrollView Delegate
    
    public func scrollViewDidScroll(scrollView: UIScrollView)
    {
        
        let scrollViewHeight = scrollView.frame.size.height;
        let scrollContentSizeHeight = scrollView.contentSize.height;
        let scrollOffset = scrollView.contentOffset.y;
        
        if (scrollOffset == 0)//Top
        {
        }
        else
        if (scrollOffset + scrollViewHeight) == scrollContentSizeHeight//Bottom
        {
            self.lazyLoadPage()
        }
    }
    
    public func lazyLoadPage()
    {
        if(_bSearchRequestIsInProgress == false && arrSearchResult.count < _iTotalNumberOfRecords)
        {
            constraintHeightViewLoadingMore.constant = 24
            _bSearchRequestIsInProgress = true;
//            _constraintViewLoadingMoreItemHeight.constant = HEIGHT_LOADING_MORE_ITEM_VIEW;

            
            if _selectedSegment == .SelectedSegmentFilter
            {
                webServiceSerch = IWSearchWebService.init(searchString: strSearch, andAuther: strAuther, andCompilation: strCollection, andVolume: strVolume, andStartIndex: Int32(arrSearchResult.count), andDelegate: self)
            }
            else if _selectedSegment == .SelectedSegmentGoToDate
            {
                webServiceSerch = IWSearchWebService.init(searchYear:strYear,withMonth:strMonth,withDate:strDay,andAuther: strAuther,andStartIndex:Int32(arrSearchResult.count), andDelegate: self)
            }
            
            webServiceSerch?.sendAsyncRequest()
        }
    }


}
