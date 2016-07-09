//
//  IWAdvanceSearchViewController.swift
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 24/06/16.
//  Copyright © 2016 Revealing Hour Creations. All rights reserved.
//

import Foundation
import UIKit



class IWAdvanceSearchViewController: UIViewController,ContainerViewDelegate,SelectionViewDelegate
{
    var vcContainerTable:IWAdvanceSearchContainerTableViewController!
    var vcSelection:IWSelectionViewController?
    
    
    //MARK: View Life Cycle
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        vcSelection = (self.storyboard?.instantiateViewControllerWithIdentifier("IWSelectionViewController"))! as? IWSelectionViewController

    }
    
    
    //MARK: Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "AdvanceSearchTableContainer"
        {
            vcContainerTable = segue.destinationViewController as! IWAdvanceSearchContainerTableViewController
            vcContainerTable.delegateContainerView = self;
        }
    }
    
    
    //MARK: IBACtions
    
    @IBAction func buttonAdvanceSearchClicked(sender: AnyObject)
    {
        let vc = (self.storyboard?.instantiateViewControllerWithIdentifier("IWAdvanceSearchResultViewController"))! as? IWAdvanceSearchResultViewController
        
        //http://incarnateword.in/search?q=mother&auth=sa&comp=sabcl&vol=01
        vc!.strSearch       = "mother"
        vc!.strAuther       = "sa"
        vc!.strCollection   = "sabcl"
        vc!.strVolume       = "01"
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    

    //MARK: ContainerViewDelegate

    func cellSelectedAuther()
    {
        print("Auther Cell Selected")
        vcSelection?.arrDataSource = ["One","Two"]
        self.navigationController?.pushViewController(vcSelection!, animated: true)
    }
    
    func cellSelectedCompilation()
    {
        print("Compilation Cell Selected")
        vcSelection?.arrDataSource = ["One","Two"]
        self.navigationController?.pushViewController(vcSelection!, animated: true)
    }
    
    func cellSelectedVolume()
    {
        print("Volume Cell Selected")
        vcSelection?.arrDataSource = ["One","Two"]
        self.navigationController?.pushViewController(vcSelection!, animated: true)
    }
    
    
    //MARK: ContainerViewDelegate
    
    func selectionViewSelectedItems(selectionItems:[AnyObject])
    {

    }

}