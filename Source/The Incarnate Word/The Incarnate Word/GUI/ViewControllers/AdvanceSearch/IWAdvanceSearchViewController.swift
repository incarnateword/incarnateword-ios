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
        let vc:UIViewController = (self.storyboard?.instantiateViewControllerWithIdentifier("IWAdvanceSearchResultViewController"))!
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}