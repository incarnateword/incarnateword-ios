//
//  IWAdvanceSearchViewController.swift
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 24/06/16.
//  Copyright © 2016 Revealing Hour Creations. All rights reserved.
//

import Foundation
import UIKit

class IWAdvanceSearchViewController: UIViewController
{
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
    }
    
    @IBAction func buttonAdvanceSearchClicked(sender: AnyObject)
    {
        let vc = (self.storyboard?.instantiateViewControllerWithIdentifier("IWAdvanceSearchResultViewController"))! as? IWAdvanceSearchResultViewController
        
        //http://incarnateword.in/search?q=mother&auth=sa&comp=sabcl&vol=01
        vc!.strSearch = "mother"
        vc!.strAuther = "sa"
        vc!.strCollection = "sabcl"
        vc!.strVolume = "01"
        
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}