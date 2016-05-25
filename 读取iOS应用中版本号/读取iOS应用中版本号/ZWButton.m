//
//  ZWButton.m
//  读取iOS应用中版本号
//
//  Created by rayootech on 16/4/11.
//  Copyright © 2016年 rayootech. All rights reserved.
//

#import "ZWButton.h"

@interface ZWButton ()

@end

@implementation ZWButton
-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    
    // Initialization code
    self.bgLayer = [[CALayer alloc] init];
    _bgLayer.frame = CGRectMake(0,frame.size.height-10,frame.size.width, 6);
    //    _bgLayer.backgroundColor = BaseLineColor.CGColor;
    _bgLayer.backgroundColor = [UIColor colorWithRed:243/255 green:243/255 blue:243/255 alpha:1].CGColor;
    _bgLayer.cornerRadius =2.5;
    _bgLayer.masksToBounds = YES;
    [self.layer addSublayer:_bgLayer];
    
    self.instructionsLayer = [CAShapeLayer layer];
    _instructionsLayer.frame = _bgLayer.bounds;
    _instructionsLayer.backgroundColor = [UIColor colorWithRed:243/255 green:243/255 blue:243/255 alpha:1].CGColor;
    _instructionsLayer.lineCap = kCALineCapRound;
    //_instructionsLayer.lineJoin = kCALineJoinRound;
    _instructionsLayer.lineWidth = 6;
    _instructionsLayer.cornerRadius =2.5;
    _instructionsLayer.masksToBounds = YES;
    self.path = [UIBezierPath bezierPath];
    [_path moveToPoint:CGPointMake(0,CGRectGetMidY(_instructionsLayer.frame))];
    [_path addLineToPoint:CGPointMake(CGRectGetMaxX(_instructionsLayer.frame),CGRectGetMidY(_instructionsLayer.frame))];
    _instructionsLayer.path = _path.CGPath;
    
    _instructionsLayer.strokeStart = 0.0;
    _instructionsLayer.strokeEnd = 0.0;
    
    _instructionsLayer.strokeColor = [UIColor redColor].CGColor;
    [_bgLayer addSublayer:_instructionsLayer];
    [CATransaction commit];
}




#pragma mark-设置进度
-(void) setProcess:(CGFloat)process{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _instructionsLayer.strokeEnd = process;
    [CATransaction commit];
}


@end
