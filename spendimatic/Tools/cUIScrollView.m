//
//  cUIScrollView.m
//  ZPass-Sandbox
//
//  Created by LF-Mac-Air on 28/6/16.
//  Copyright © 2016 LF-Mac-Air. All rights reserved.
//
/*
 * Custom Scrollview with delay touch so it doesnt effect the scrolling
 * while there are other items like button on top layer.
 */

#import "cUIScrollView.h"

@implementation cUIScrollView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.delaysContentTouches = NO;
    }
    
    return self;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    if ([view isKindOfClass:UIButton.class]) {
        return YES;
    }
    
    return [super touchesShouldCancelInContentView:view];
}

@end
