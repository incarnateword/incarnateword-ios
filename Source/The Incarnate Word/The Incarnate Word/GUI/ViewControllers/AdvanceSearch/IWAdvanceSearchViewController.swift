//
//  IWAdvanceSearchViewController.swift
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 24/06/16.
//  Copyright © 2016 Revealing Hour Creations. All rights reserved.
//

import Foundation
import UIKit



class IWAdvanceSearchViewController: UIViewController,ContainerViewDelegate
{
    var vcContainerTable:IWAdvanceSearchContainerTableViewController!
    
    
    //MARK: View Life Cycle
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
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
    }
    
    func cellSelectedCompilation()
    {
        print("Compilation Cell Selected")
    }
    
    func cellSelectedVolume()
    {
        print("Volume Cell Selected")
    }
}