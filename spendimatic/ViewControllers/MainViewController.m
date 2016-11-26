//
//  MainViewController.m
//  spendimatic
//
//  Created by LF-Mac-Air on 26/11/16.
//  Copyright © 2016 LF-Mac-Air. All rights reserved.
//

#import "MainViewController.h"
#import "ScannerViewController.h"

@interface MainViewController ()

@property (nonatomic, strong) ScannerViewController *scannerVC;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    _scannerVC = [[ScannerViewController alloc] init];
    [self.view addSubview:_scannerVC.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
