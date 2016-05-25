//
//  ZWButton.h
//  读取iOS应用中版本号
//
//  Created by rayootech on 16/4/11.
//  Copyright © 2016年 rayootech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZWButton : UIButton
@property CALayer *bgLayer;
@property CAShapeLayer *instructionsLayer;
@property UIBezierPath *path;
#pragma mark-设置进度
-(void) setProcess:(CGFloat)process;

@end
