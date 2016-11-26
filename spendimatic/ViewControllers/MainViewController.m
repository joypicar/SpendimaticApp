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

@property (nonatomic) float screenWidth;
@property (nonatomic) float screenHeight;

@property (nonatomic, strong) UIView *tabMenuView;
@property (nonatomic, strong) UIView *lowerPanelView;

@property (nonatomic, strong) NSArray *categoryArray;

@property (nonatomic, strong) UIScrollView *switchMenuScrollView;

@property (nonatomic, strong) ScannerViewController *scannerVC;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initialize];
    
    [self initFastFoodBanner];
    
    [self initMenuTab];
    
    [self lowerPanel];
    
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
}

-(void)initFastFoodBanner{

    //UIView *bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
}

-(void)initMenuTab{

    _tabMenuView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
    _tabMenuView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_tabMenuView];
    
    _categoryArray = @[@"",@""];
    
    for (int i = 0; i < _categoryArray.count; i++) {
     
        UIButton *categoryButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [categoryButton setTitle:[_categoryArray objectAtIndex:i] forState:UIControlStateNormal];
        [categoryButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [_tabMenuView addSubview:categoryButton];
    }
}

-(void)initMenuList{
    
    _switchMenuScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _tabMenuView.frame.origin.y + _tabMenuView.frame.size.height, _screenWidth, _screenHeight - (_tabMenuView.frame.size.height + _lowerPanelView.frame.size.height))];
    _switchMenuScrollView.backgroundColor = [UIColor greenColor];
    _switchMenuScrollView.contentSize = CGSizeMake(_screenWidth * _categoryArray.count, _switchMenuScrollView.frame.size.height);
    _switchMenuScrollView.pagingEnabled = YES;
    [self.view addSubview:_switchMenuScrollView];

    
    
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _tabMenuView.frame.origin.y + _tabMenuView.frame.size.height, _screenWidth, 0)];
    scrollView.backgroundColor = [UIColor lightGrayColor];
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, (_screenHeight / 5));
}

-(void)initLower{
    
    _lowerPanelView = [[UIView alloc] initWithFrame:CGRectMake(0, _screenHeight - 200, _screenWidth, 200)];
    _lowerPanelView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_lowerPanelView];
}

@end
