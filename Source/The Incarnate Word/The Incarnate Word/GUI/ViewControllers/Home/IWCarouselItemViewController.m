//
//  IWCarouselItemViewController.m
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 01/06/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import "IWCarouselItemViewController.h"

@interface IWCarouselItemViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblQuote;
@end

@implementation IWCarouselItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _lblQuote.text = _strQuote;
}



@end
