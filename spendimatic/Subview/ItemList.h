//
//  ItemList.h
//  spendimatic
//
//  Created by LF-Mac-Air on 27/11/16.
//  Copyright © 2016 LF-Mac-Air. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ItemList;

@protocol ItemListDelegate

-(void)didSelectItem:(ItemList*)itemList item:(UIButton*)sender;

@end

@interface ItemList : UIView

@property (nonatomic, strong) NSArray *imageArray;
@property (nonatomic, strong) NSArray *itemArray;
@property (nonatomic, strong) NSArray *priceArray;

@property (nonatomic, weak) id <ItemListDelegate> delegate;

@end
