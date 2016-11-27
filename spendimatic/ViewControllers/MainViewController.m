//
//  MainViewController.m
//  spendimatic
//
//  Created by LF-Mac-Air on 26/11/16.
//  Copyright © 2016 LF-Mac-Air. All rights reserved.
//

#import "MainViewController.h"
#import "ItemList.h"
#import "Products.h"
#import "ScannerViewController.h"

@interface MainViewController () <ItemListDelegate, UIScrollViewDelegate>

@property (nonatomic) float screenWidth;
@property (nonatomic) float screenHeight;

@property (nonatomic, strong) UIView *bannerView;
@property (nonatomic, strong) UIView *tabMenuView;
@property (nonatomic, strong) UIView *lowerPanelView;

@property (nonatomic, strong) NSArray *categoryArray;
@property (nonatomic, strong) NSMutableArray *tabButtonArray;
@property (nonatomic, strong) NSMutableArray *orderLogsMutableArray;

@property (nonatomic) int orderCounter;
@property (nonatomic, strong) UILabel *totalLabel;
@property (nonatomic, strong) Products *products;
@property (nonatomic) NSInteger totalPrice;

@property (nonatomic, strong) UIScrollView *switchMenuScrollView;
@property (nonatomic, strong) UIScrollView *orderLogsScrollView;
@property (nonatomic, strong) UIView *underLineIndicator;

@property (nonatomic, strong) ScannerViewController *scannerVC;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initialize];
    
    [self initFastFoodBanner];
    
    [self initMenuTab];
    
    [self initLowerPanel];
    
    [self initMenuList];
    
    //_scannerVC = [[ScannerViewController alloc] init];
    //[self.view addSubview:_scannerVC.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initialize{
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    _screenWidth = self.view.frame.size.width;
    _screenHeight = self.view.frame.size.height;
    
    _orderCounter = 0;
    _totalPrice = 0;
    
    _orderLogsMutableArray = [[NSMutableArray alloc] init];
}

-(void)initFastFoodBanner{

    _bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight / 8)];
    _bannerView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:_bannerView];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_McDo"]];
    //logoImageView.backgroundColor = [UIColor lightGrayColor];
    logoImageView.frame = CGRectMake((_bannerView.frame.size.width / 2) - ((_bannerView.frame.size.height - 30) / 2), 20, _bannerView.frame.size.height - 30, _bannerView.frame.size.height - 30);
    logoImageView.contentMode = UIViewContentModeScaleAspectFill;
    logoImageView.clipsToBounds = YES;
    [_bannerView addSubview:logoImageView];
}

-(void)initMenuTab{

    _tabMenuView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _bannerView.frame.origin.y + _bannerView.frame.size.height, _screenWidth, 50)];
    _tabMenuView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_tabMenuView];
    
    _tabButtonArray = [[NSMutableArray alloc] init];
    _categoryArray = @[@"Burgers",@"Chicken",@"Drinks",@"Desserts"];
    
    for (int i = 0; i < _categoryArray.count; i++) {
     
        UIButton *categoryButton = [UIButton buttonWithType:UIButtonTypeSystem];
        categoryButton.frame = CGRectMake(i * (_tabMenuView.frame.size.width / _categoryArray.count), 0, _tabMenuView.frame.size.width / _categoryArray.count, _tabMenuView.frame.size.height);
        categoryButton.tag = i;
        [categoryButton setTitle:[_categoryArray objectAtIndex:i] forState:UIControlStateNormal];
        [categoryButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_tabMenuView addSubview:categoryButton];
        
        [categoryButton addTarget:self action:@selector(didSelectTabEvent:) forControlEvents:UIControlEventTouchUpInside];
        
        [_tabButtonArray addObject:categoryButton];
    }
    
    _underLineIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, _tabMenuView.frame.size.height - 3, _tabMenuView.frame.size.width / _categoryArray.count, 3)];
    _underLineIndicator.backgroundColor = [UIColor yellowColor];
    [_tabMenuView addSubview:_underLineIndicator];
    
    [self underLineAnimation:0];
}

-(void)initMenuList{
    
    _switchMenuScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _tabMenuView.frame.origin.y + _tabMenuView.frame.size.height, _screenWidth, _screenHeight - (_bannerView.frame.size.height + _tabMenuView.frame.size.height + _lowerPanelView.frame.size.height))];
    _switchMenuScrollView.backgroundColor = [UIColor whiteColor];
    _switchMenuScrollView.contentSize = CGSizeMake(_screenWidth * _categoryArray.count, _switchMenuScrollView.frame.size.height);
    _switchMenuScrollView.pagingEnabled = YES;
    _switchMenuScrollView.scrollEnabled = NO;
    [self.view addSubview:_switchMenuScrollView];
    
    _products = [[Products alloc] init];
    
    ItemList *burgerList = [[ItemList alloc] initWithFrame:CGRectMake(0, 0, _switchMenuScrollView.frame.size.width, _switchMenuScrollView.frame.size.height)];
    burgerList.delegate = self;
    //burgerList.backgroundColor = [UIColor purpleColor];
    burgerList.imageArray = _products.imagesBurger;
    burgerList.itemArray = _products.itemBurger;
    burgerList.priceArray = _products.priceBurger;
    [_switchMenuScrollView addSubview:burgerList];
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
    
    UILabel *yourOrderLabel = [[UILabel alloc] initWithFrame:CGRectMake(quantityLabel.frame.size.width, 0, _screenWidth - (_screenWidth / 3), 40)];
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
    _totalLabel.text = @"Total Price\nP 0";
    _totalLabel.numberOfLines = 0;
    _totalLabel.textColor = [UIColor whiteColor];
    _totalLabel.textAlignment = NSTextAlignmentCenter;
    [_lowerPanelView addSubview:_totalLabel];
    
    UIButton *payButton = [UIButton buttonWithType:UIButtonTypeSystem];
    payButton.frame = CGRectMake(_totalLabel.frame.origin.x + 10, _totalLabel.frame.size.height, _totalLabel.frame.size.width - 20, _totalLabel.frame.size.height / 2);
    payButton.backgroundColor = [UIColor yellowColor];
    payButton.layer.cornerRadius = 5;
    [payButton setTitle:@"Pay now" forState:UIControlStateNormal];
    [_lowerPanelView addSubview:payButton];
    
    [payButton addTarget:self action:@selector(payNowEvent) forControlEvents:UIControlEventTouchUpInside];
    
    _orderLogsMutableArray = [[NSMutableArray alloc] init];
    
    _orderLogsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, quantityLabel.frame.size.height, _lowerPanelView.frame.size.width - _totalLabel.frame.size.width, _lowerPanelView.frame.size.height - quantityLabel.frame.size.height - 5)];
    _orderLogsScrollView.delegate = self;
    //_orderLogsScrollView.layer.cornerRadius = _cameraContainerView.layer.cornerRadius;
    _orderLogsScrollView.contentSize = CGSizeMake(_orderLogsScrollView.frame.size.width, _orderLogsScrollView.frame.size.height);
    //_orderLogsScrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [_lowerPanelView addSubview:_orderLogsScrollView];
}

-(void)didSelectTabEvent:(UIButton*)sender{
    
    [self underLineAnimation:sender.tag];
    
    CGRect toVisible = CGRectMake(_screenWidth * sender.tag, _switchMenuScrollView.frame.origin.y, _switchMenuScrollView.frame.size.width, _switchMenuScrollView.frame.size.height);
    
    [_switchMenuScrollView scrollRectToVisible:toVisible animated:YES];
}

-(void)underLineAnimation:(NSInteger)counter{
    
    [UIView transitionWithView:_underLineIndicator
                      duration:0.2f
                       options:UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        
                            _underLineIndicator.frame = CGRectMake(_underLineIndicator.frame.size.width * counter, _underLineIndicator.frame.origin.y, _underLineIndicator.frame.size.width, _underLineIndicator.frame.size.height);
                        
                        for (int i = 0; i < _tabButtonArray.count; i++) {
                            
                            UIButton *button = [_tabButtonArray objectAtIndex:i];
                            
                            if(i == counter){
                                
                                [button setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
                            }else{
                                
                                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                            }
                        }
                        
                    }completion:nil];
}

-(void)orderLogs:(NSString*)param price:(NSString*)price row:(int)row{
    
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
    logLabel.text = [NSString stringWithFormat:@"1 %@ %@", param, price];
    
    [_orderLogsMutableArray addObject:logLabel.text];
    
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

-(void)payNowEvent{
    
    NSLog(@"pay now");
    
    _scannerVC = [[ScannerViewController alloc] init];
    _scannerVC.orderLogsMutableArray = _orderLogsMutableArray;
    _scannerVC.totalPrice = _totalPrice;
    //[self.view addSubview:_scannerVC.view];
    
    [self.navigationController presentViewController:_scannerVC animated:YES completion:nil];
}

/*
 * Delegate
 */

-(void)didSelectItem:(ItemList *)itemList item:(UIButton *)sender{
    
    [self orderLogs:[itemList.itemArray objectAtIndex:sender.tag] price:[itemList.priceArray objectAtIndex:sender.tag] row:_orderCounter];
    
    NSLog(@"item %li %@",(long)sender.tag,[itemList.itemArray objectAtIndex:sender.tag]);
    
    NSInteger price = [[_products.priceBurger objectAtIndex:sender.tag] integerValue];
    
    _totalPrice = _totalPrice + price;
    
    _totalLabel.text = [NSString stringWithFormat:@"Total Price\nP %li",(long)_totalPrice];
    
    _orderCounter++;
}
@end
