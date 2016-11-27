//
//  ScannerViewController.h
//  spendimatic
//
//  Created by LF-Mac-Air on 26/11/16.
//  Copyright © 2016 LF-Mac-Air. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@interface ScannerViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *orderLogsMutableArray;
@property (nonatomic) NSInteger totalPrice;

@end
