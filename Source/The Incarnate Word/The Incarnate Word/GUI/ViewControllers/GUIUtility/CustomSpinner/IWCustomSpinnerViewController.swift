//
//  IWCustomSpinnerViewController.swift
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 12/06/16.
//  Copyright © 2016 Revealing Hour Creations. All rights reserved.
//

import Foundation
import UIKit

class IWCustomSpinnerViewController: UIViewController
{
    var _bShouldFlipHorizontally:Bool = true
    private var _timerLoading:NSTimer?
    
    @IBOutlet weak var viewLoading: UIView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        viewLoading.layer.cornerRadius = 3.0;
        viewLoading.backgroundColor = UIColor.blackColor();
        self.startLoadingAnimation()
    }
    

// MARK: - Loading

func startLoadingAnimation()
{
    viewLoading.hidden = false;
    _timerLoading  = NSTimer.scheduledTimerWithTimeInterval(0.7, target: self, selector: #selector(IWCustomSpinnerViewController.animateLoading), userInfo: nil, repeats: true)
}

func stopLoadingAnimation()
{
        if (_timerLoading != nil && _timerLoading!.valid == true)
        {
            _timerLoading?.invalidate()
        }
        
        _timerLoading = nil;
        viewLoading.hidden = true;
}

func animateLoading()
{
    
    let animationOption = (_bShouldFlipHorizontally ?  UIViewAnimationOptions.TransitionFlipFromRight : UIViewAnimationOptions.TransitionFlipFromBottom )
    
    UIView .transitionWithView(viewLoading,
                               duration: 0.5,
                               options: animationOption,
                               animations:  {},
                               completion: {_ in
                                //transition completion
                                if self._bShouldFlipHorizontally { self._bShouldFlipHorizontally = false} else { self._bShouldFlipHorizontally = true };
    })
}

deinit
{
    stopLoadingAnimation();
}
    
    
}


