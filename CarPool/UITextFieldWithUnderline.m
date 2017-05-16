//
//  UITextFieldWithUnderline.m
//  CarPool
//
//  Created by Nathan Chen on 5/6/17.
//  Copyright © 2017 Nathan Chen. All rights reserved.
//

#import "UITextFieldWithUnderline.h"

@implementation UITextFieldWithUnderline


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGPoint startPoint = CGPointMake(rect.origin.x, rect.origin.y+rect.size.height);
    CGPoint endPoint = CGPointMake(rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    path.lineWidth = 1.0;
    [self.tintColor setStroke];
    [path stroke];
}

@end
