//
//  ItemList.m
//  spendimatic
//
//  Created by LF-Mac-Air on 27/11/16.
//  Copyright © 2016 LF-Mac-Air. All rights reserved.
//

#import "ItemList.h"
#import "cUIScrollView.h"

@interface ItemList ()

@property (nonatomic) float screenWidth;
@property (nonatomic) float screenHeight;

@property (nonatomic, strong) cUIScrollView *scrollView;

@end

@implementation ItemList

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if(self){
        
        _screenWidth = frame.size.width;
        _screenHeight = frame.size.height;
    }
    
    return self;
}

-(void)didMoveToSuperview{
    
    _scrollView = [[cUIScrollView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
    //_scrollView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, (_screenHeight / 3) * _itemArray.count);
    [self addSubview:_scrollView];
    
    for (int i = 0; i < _itemArray.count; i++) {
        
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, i * (_screenHeight / 3), _scrollView.frame.size.width, _screenHeight / 3)];
        containerView.backgroundColor = [UIColor whiteColor];
        [_scrollView addSubview:containerView];
        
        NSString *imageName = [_imageArray objectAtIndex:i];
        
        UIImageView *itemImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        //itemImageView.backgroundColor = [UIColor lightGrayColor];
        itemImageView.frame = CGRectMake(20, 10, containerView.frame.size.height - 20, containerView.frame.size.height - 20);
        itemImageView.contentMode = UIViewContentModeScaleAspectFill;
        itemImageView.clipsToBounds = YES;
        [containerView addSubview:itemImageView];
        
        UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(itemImageView.frame.origin.x + itemImageView.frame.size.width + 10, 0, containerView.frame.size.width / 3, containerView.frame.size.height)];
        //itemLabel.backgroundColor = [UIColor brownColor];
        itemLabel.text = [_itemArray objectAtIndex:i];
        itemLabel.numberOfLines = 0;
        itemLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [containerView addSubview:itemLabel];
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(containerView.frame.size.width - (itemLabel.frame.size.width - 20), 0, (containerView.frame.size.width / 3) - 30, containerView.frame.size.height)];
        //priceLabel.backgroundColor = [UIColor brownColor];
        priceLabel.text = [NSString stringWithFormat:@"P%@",[_priceArray objectAtIndex:i]];
        priceLabel.numberOfLines = 0;
        priceLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [containerView addSubview:priceLabel];
        
        UIView *seperator = [[UIView alloc] initWithFrame:CGRectMake(0, i * (containerView.frame.size.height - 1), containerView.frame.size.width, 1)];
        seperator.backgroundColor = [UIColor lightGrayColor];
        [_scrollView addSubview:seperator];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
        button.tag = i;
        [containerView addSubview:button];
        
        [button addTarget:self action:@selector(didSelectItemEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)didSelectItemEvent:(UIButton*)sender{
    
    [_delegate didSelectItem:self item:sender];
}

@end
