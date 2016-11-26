//
//  Burger.m
//  spendimatic
//
//  Created by LF-Mac-Air on 26/11/16.
//  Copyright © 2016 LF-Mac-Air. All rights reserved.
//

#import "Burger.h"

@interface Burger ()

@property (nonatomic) float screenWidth;
@property (nonatomic) float screenHeight;

@end

@implementation Burger


-(instancetype)initWithFrame:(CGRect)frame{

    self = [super initWithFrame:frame];
    
    if(self){
        
        _screenWidth = frame.size.width;
        _screenHeight = frame.size.height;
    }
    
    return self;
}

@end
