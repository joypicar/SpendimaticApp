//
//  OrderNoViewController.m
//  spendimatic
//
//  Created by LF-Mac-Air on 27/11/16.
//  Copyright © 2016 LF-Mac-Air. All rights reserved.
//

#import "OrderNoViewController.h"

@interface OrderNoViewController () <UIScrollViewDelegate>

@property (nonatomic) float screenWidth;
@property (nonatomic) float screenHeight;

@property (strong, nonatomic) UIView *cameraContainerView;
@property (nonatomic, strong) UIView *successFlashView;
@property (nonatomic, strong) UIView *failedFlashView;
@property (strong, nonatomic) UILabel *scanningStatusLabel;

@property (nonatomic, strong) UIView *bannerView;
@property (nonatomic, strong) UIView *tabMenuView;
@property (nonatomic, strong) UIView *lowerPanelView;

//@property (nonatomic, strong) UIScrollView *dataLogsScrollView;
@property (nonatomic, strong) UIScrollView *orderLogsScrollView;

@property (nonatomic, strong) UILabel *totalLabel;

@end

@implementation OrderNoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initialize];
    
    [self initScannerLayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initialize{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _screenWidth = self.view.frame.size.width;
    _screenHeight = self.view.frame.size.height;
}

-(void)initScannerLayout{
    
    _cameraContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
    _cameraContainerView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_cameraContainerView];
    
    NSLog(@"Load logs : -> %@", _orderLogsMutableArray);
    
    _scanningStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, _cameraContainerView.frame.size.width, 20)];
    //_scanningStatusLabel.backgroundColor = [UIColor blackColor];
    _scanningStatusLabel.textColor = [UIColor greenColor];
    _scanningStatusLabel.font = [UIFont systemFontOfSize:12];
    
    _bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight / 8)];
    _bannerView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_bannerView];
    
    _tabMenuView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _bannerView.frame.origin.y + _bannerView.frame.size.height, _screenWidth, 50)];
    _tabMenuView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_tabMenuView];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_McDo"]];
    //logoImageView.backgroundColor = [UIColor lightGrayColor];
    logoImageView.frame = CGRectMake((_bannerView.frame.size.width / 2) - ((_bannerView.frame.size.height - 30) / 2), 20, _bannerView.frame.size.height - 30, _bannerView.frame.size.height - 30);
    logoImageView.contentMode = UIViewContentModeScaleAspectFill;
    logoImageView.clipsToBounds = YES;
    [_bannerView addSubview:logoImageView];
    
    UIImageView *spendImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_spendimatic"]];
    //logoImageView.backgroundColor = [UIColor lightGrayColor];
    spendImageView.frame = CGRectMake((_tabMenuView.frame.size.width / 2) - 100, 0, 200, _tabMenuView.frame.size.height);
    spendImageView.contentMode = UIViewContentModeScaleAspectFit;
    spendImageView.clipsToBounds = YES;
    [_tabMenuView addSubview:spendImageView];
    
    [self initLowerPanel];
}

-(void)initLowerPanel{
    
    _lowerPanelView = [[UIView alloc] initWithFrame:CGRectMake(0, _screenHeight - 150, _screenWidth, 150)];
    _lowerPanelView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_lowerPanelView];
    
    UILabel *quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    //quantityLabel.backgroundColor = [UIColor greenColor];
    quantityLabel.text = @"QTY";
    quantityLabel.textColor = [UIColor whiteColor];
    quantityLabel.textAlignment = NSTextAlignmentCenter;
    [_lowerPanelView addSubview:quantityLabel];
    
    UILabel *yourOrderLabel = [[UILabel alloc] initWithFrame:CGRectMake(quantityLabel.frame.size.width, 0, 120, 40)];
    //yourOrderLabel.backgroundColor = [UIColor orangeColor];
    yourOrderLabel.text = @"Your Order";
    yourOrderLabel.textColor = [UIColor whiteColor];
    yourOrderLabel.textAlignment = NSTextAlignmentCenter;
    [_lowerPanelView addSubview:yourOrderLabel];
    
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(yourOrderLabel.frame.origin.x + yourOrderLabel.frame.size.width, 0, 60, 40)];
    //priceLabel.backgroundColor = [UIColor blueColor];
    priceLabel.text = @"Price";
    priceLabel.textColor = [UIColor whiteColor];
    priceLabel.textAlignment = NSTextAlignmentCenter;
    [_lowerPanelView addSubview:priceLabel];
    
    _totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(priceLabel.frame.origin.x + priceLabel.frame.size.width, 0, _lowerPanelView.frame.size.width - (priceLabel.frame.origin.x + priceLabel.frame.size.width), _lowerPanelView.frame.size.height / 2)];
    //totalLabel.backgroundColor = [UIColor lightGrayColor];
    _totalLabel.text = [NSString stringWithFormat:@"Total Price\nP %li",(long)_totalPrice];
    _totalLabel.numberOfLines = 0;
    _totalLabel.textColor = [UIColor whiteColor];
    _totalLabel.textAlignment = NSTextAlignmentCenter;
    [_lowerPanelView addSubview:_totalLabel];
    
    /*
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelButton.frame = CGRectMake(_totalLabel.frame.origin.x + 10, _totalLabel.frame.size.height, _totalLabel.frame.size.width - 20, _totalLabel.frame.size.height / 2);
    cancelButton.backgroundColor = [UIColor yellowColor];
    cancelButton.layer.cornerRadius = 5;
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [_lowerPanelView addSubview:cancelButton];
    
    [cancelButton addTarget:self action:@selector(cancelEvent) forControlEvents:UIControlEventTouchUpInside];
    */
    _orderLogsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, quantityLabel.frame.size.height, _lowerPanelView.frame.size.width - _totalLabel.frame.size.width, _lowerPanelView.frame.size.height - quantityLabel.frame.size.height - 5)];
    _orderLogsScrollView.delegate = self;
    //_orderLogsScrollView.layer.cornerRadius = _cameraContainerView.layer.cornerRadius;
    _orderLogsScrollView.contentSize = CGSizeMake(_orderLogsScrollView.frame.size.width, _orderLogsScrollView.frame.size.height);
    //_orderLogsScrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [_lowerPanelView addSubview:_orderLogsScrollView];
    
    for (int i = 0; i < _orderLogsMutableArray.count; i++) {
        
        [self orderLogs:[NSString stringWithFormat:@"%@",[_orderLogsMutableArray objectAtIndex:i]] row:i];
    }
}

-(void)orderLogs:(NSString*)param row:(int)row{
    
    NSLog(@"order log param = %@", param);
    
    _orderLogsScrollView.contentSize = CGSizeMake(_orderLogsScrollView.frame.size.width, 15 * (row + 1));
    
    if(_orderLogsScrollView.contentSize.height > _orderLogsScrollView.frame.size.height){
        
        CGPoint scrollDownPoint = CGPointMake(0, _orderLogsScrollView.contentSize.height - _orderLogsScrollView.bounds.size.height);
        
        [_orderLogsScrollView setContentOffset:scrollDownPoint animated:YES];
    }
    
    UILabel *logLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, row * 15, _orderLogsScrollView.frame.size.width, 15)];
    //logLabel.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.3];
    logLabel.textColor = [UIColor whiteColor];
    logLabel.font = [UIFont systemFontOfSize:10];
    logLabel.text = param;
    
    // If we want customize text format/color for verify and decline
    /*
     if([stats isEqualToString:@"verify"]){
     logLabel.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
     }else{
     logLabel.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
     }
     */
    [_orderLogsScrollView addSubview:logLabel];
}

@end

