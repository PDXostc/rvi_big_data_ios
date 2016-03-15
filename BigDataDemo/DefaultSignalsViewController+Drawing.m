/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. 
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    DefaultSignalsViewController+Drawing.m
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 3/15/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "DefaultSignalsViewController+Drawing.h"


@implementation DefaultSignalsViewController (Drawing)

- (void)drawHood:(UIView *)hoodView
{
    CGFloat cornerRadius = 10;
    CGRect frame = hoodView.bounds;

    CAShapeLayer *shapeLayer = [CAShapeLayer layer];

    CGMutablePathRef path = CGPathCreateMutable();

    CGPathMoveToPoint(path, NULL, 0, frame.size.height);// - cornerRadius);
    CGPathAddLineToPoint(path, NULL, 0, cornerRadius);
    CGPathAddArc(path, NULL, cornerRadius, cornerRadius, cornerRadius, M_PI, -M_PI_2, NO);
    CGPathAddLineToPoint(path, NULL, frame.size.width - cornerRadius, 0);
    CGPathAddArc(path, NULL, frame.size.width - cornerRadius, cornerRadius, cornerRadius, -M_PI_2, 0, NO);
    CGPathAddLineToPoint(path, NULL, frame.size.width, frame.size.height);// - cornerRadius);
    //CGPathAddArc(path, NULL, frame.size.width - cornerRadius, frame.size.height - cornerRadius, cornerRadius, 0, M_PI_2, NO);
    CGPathAddLineToPoint(path, NULL, 0/*cornerRadius*/, frame.size.height);
    //CGPathAddArc(path, NULL, cornerRadius, frame.size.height - cornerRadius, cornerRadius, M_PI_2, M_PI, NO);

    shapeLayer.path = path;
    CGPathRelease(path);

    shapeLayer.backgroundColor = [[UIColor clearColor] CGColor];
    shapeLayer.frame           = frame;
    shapeLayer.masksToBounds   = NO;
    shapeLayer.fillColor       = [[UIColor grayColor] CGColor];
    shapeLayer.strokeColor     = [[UIColor clearColor] CGColor];
    shapeLayer.lineWidth       = 0;
    shapeLayer.lineCap         = kCALineCapRound;

    [hoodView.layer addSublayer:shapeLayer];
}

//- (void)updateTemperatureBars
//{
//    [self drawTemperateBar:self.tempBarLeft
//                     value:[self.pickerLeft selectedRowInComponent:0]];
//    [self drawTemperateBar:self.tempBarRight
//                     value:[self.pickerRight selectedRowInComponent:0]];
//
//}
//
//- (void)makeGradientForBar:(UIView *)tempBar
//{
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = tempBar.bounds;
//
//    gradient.anchorPoint = CGPointMake(0, 0);
//    gradient.position    = CGPointMake(0, 0);
//    gradient.startPoint  = CGPointMake(0.5, GRADIENT_UNIT_HEIGHT);
//    gradient.endPoint    = CGPointMake(0.5, 0.0);
//
//    gradient.colors = @[(__bridge id)[[UIColor colorWithRed:(CGFloat)(252.0 / 255.0)
//                                                      green:(CGFloat)(138.0 / 255.0)
//                                                       blue:(CGFloat)(10.0  / 255.0)
//                                                      alpha:1.0] CGColor], (__bridge id)[[UIColor clearColor] CGColor]];
//
//    [tempBar.layer insertSublayer:gradient atIndex:0];
//}
//
//- (void)makeGradientForPicker:(UIView *)picker
//{
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = picker.bounds;
//
//    gradient.anchorPoint = CGPointMake(0, 0);
//    gradient.position    = CGPointMake(0, 0);
//
//    gradient.locations   = @[@(0.0),
//                             @(GRADIENT_UNIT_HEIGHT * 2.0),
//                             @(1.0 - GRADIENT_UNIT_HEIGHT * 2.0),
//                             @(1.0)];
//
//    gradient.colors = @[(__bridge id)[[UIColor colorWithRed:(CGFloat)(142.0 / 255.0)
//                                                      green:(CGFloat)(205.0 / 255.0)
//                                                       blue:(CGFloat)(223.0 / 255.0)
//                                                      alpha:0.8] CGColor],
//                        (__bridge id)[[UIColor clearColor] CGColor],
//                        (__bridge id)[[UIColor clearColor] CGColor],
//                        (__bridge id)[[UIColor colorWithRed:(CGFloat)(142.0 / 255.0)
//                                                      green:(CGFloat)(205.0 / 255.0)
//                                                       blue:(CGFloat)(223.0 / 255.0)
//                                                      alpha:0.8] CGColor]];
//
//    [picker.layer insertSublayer:gradient atIndex:0];
//}
@end
