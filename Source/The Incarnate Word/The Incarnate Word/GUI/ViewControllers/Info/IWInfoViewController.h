//
//  IWInfoViewController.h
//  The Incarnate Word
//
//  Created by Aditya Deshmane on 17/06/15.
//  Copyright (c) 2015 Revealing Hour Creations. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InfoViewDelegate <NSObject>

@optional

-(void)infoViewRemoved;


@end

@interface IWInfoViewController : UIViewController

@property(readwrite,weak) id<InfoViewDelegate> delegateInfoView;
@property(readwrite) NSString *strText;

@end
