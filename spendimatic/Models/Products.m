//
//  Products.m
//  spendimatic
//
//  Created by LF-Mac-Air on 27/11/16.
//  Copyright © 2016 LF-Mac-Air. All rights reserved.
//

#import "Products.h"

@implementation Products

-(instancetype)init{
    
    self = [super init];
    
    if(self){
        
        _imagesBurger = @[@"burger_01",@"burger_02",@"burger_03",@"burger_04"];
        
        _itemBurger = @[@"Big Mac", @"McSpicy", @"Big n' Tasty", @"Cheeseburger"];
        
        _priceBurger = @[@"2000", @"9000", @"12000", @"5000"];
        
    }
    
    return self;
}

@end
