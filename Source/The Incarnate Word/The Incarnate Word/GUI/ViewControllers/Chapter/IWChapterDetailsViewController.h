//
//  IWChapterViewController.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/05/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IWDetailChapterStructure.h"

@interface IWChapterDetailsViewController : UIViewController

@property(nonatomic) NSString *strChapterPath;
@property(nonatomic) int       iItemIndex;
@property(nonatomic) int       iParagraphIndex;

@property(nonatomic) IWDetailChapterStructure *offlineDetailChapterStructure;

-(void)setupVC;

@end
