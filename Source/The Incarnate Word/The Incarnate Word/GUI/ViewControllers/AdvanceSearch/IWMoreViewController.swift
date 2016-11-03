//
//  IWMoreViewController.swift
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 03/11/16.
//  Copyright © 2016 Revealing Hour Creations. All rights reserved.
//

import Foundation
import UIKit

class IWMoreViewController: UIViewController
{
    @IBOutlet weak var textView: UITextView!

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.navigationItem.title = "Search tips"
        self.navigationController!.navigationBar.topItem!.title = "Back"

        
        textView.font = UIFont (name: FONT_TITLE_REGULAR, size: 16.0)
        
        let strTitle1:String = "\"golden bridge\""
        let strDesc1:String = "Exact match in given order"
        
        let strTitle2:String = "`savitri satyavan`"
        let strDesc2:String = "Both \"savitri\" and \"satyavan\" in the same sentence"
        
        let strTitle3:String = "truth -ignorance"
        let strDesc3:String = "Occurrences of \"truth\" without \"ignorance\""
        
        let strMut:String = String(format:"%@\n%@\n\n%@\n%@\n\n%@\n%@",strTitle1,strDesc1,strTitle2,strDesc2,strTitle3,strDesc3)

        
        let attributedString = NSMutableAttributedString(string:strMut.copy() as! String)

        let range1 = (strMut.copy() as! NSString).rangeOfString(strTitle1)
        let range2 = (strMut.copy() as! NSString).rangeOfString(strTitle2)
        let range3 = (strMut.copy() as! NSString).rangeOfString(strTitle3)
        
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: FONT_TITLE_MEDIUM, size: 16.0)!, range: range1)
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: FONT_TITLE_MEDIUM, size: 16.0)!, range: range2)
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name: FONT_TITLE_MEDIUM, size: 16.0)!, range: range3)
        
        textView.attributedText = attributedString
    }

}