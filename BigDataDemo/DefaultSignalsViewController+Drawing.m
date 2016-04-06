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
#import "Util.h"

typedef enum
{
    NONE = 0,
    TOP_LEFT = 1,
    TOP_RIGHT = 2,
    BOTTOM_LEFT = 4,
    BOTTOM_RIGHT = 8
} RoundedCorners;

@implementation DefaultSignalsViewController (Drawing)

#define MINIMUM_TP_NEEDLE_ANGLE 0
#define MAXIMUM_TP_NEEDLE_ANGLE 270
#define MINIMUM_TP_GLOW_ALPHA   0.2
#define MAXIMUM_TP_GLOW_ALPHA   1.0
- (void)drawThrottlePressureView:(UIView *)throttlePressureView
{
    CALayer *glowLayer = [CALayer layer];
    CALayer *bottomLayer = [CALayer layer];
    CALayer *needleLayer = [CALayer layer];
    CALayer *topLayer    = [CALayer layer];

    glowLayer.contents = (id)[UIImage imageNamed:@"throttle_pressure_glow_layer.png"].CGImage;
    bottomLayer.contents = (id)[UIImage imageNamed:@"throttle_pressure_bottom_layer.png"].CGImage;
    needleLayer.contents = (id)[UIImage imageNamed:@"throttle_pressure_needle.png"].CGImage;
    topLayer.contents = (id)[UIImage imageNamed:@"throttle_pressure_top_layer.png"].CGImage;

    glowLayer.frame =
            bottomLayer.frame =
                    needleLayer.frame =
                            topLayer.frame = throttlePressureView.bounds;

//    bottomLayer.anchorPoint =
//            needleLayer.anchorPoint =
//                    topLayer.anchorPoint = throttlePressureView.center;

    needleLayer.name = @"NEEDLE";
    glowLayer.name = @"GLOW";

    glowLayer.opacity = MINIMUM_TP_GLOW_ALPHA;

    [[throttlePressureView layer] addSublayer:glowLayer];
    [[throttlePressureView layer] addSublayer:bottomLayer];
    [[throttlePressureView layer] addSublayer:needleLayer];
    [[throttlePressureView layer] addSublayer:topLayer];
}

- (void)drawSteeringAngleView
{

}

- (void)animateChangeInThrottlePressure:(UIView *)throttlePressureView from:(float)from to:(float)to total:(float)total
{
    DLog(@"");

    CALayer *needleLayer = nil;
    CALayer *glowLayer = nil;

    for (CALayer *layer in throttlePressureView.layer.sublayers) {
        if ([layer.name isEqualToString:@"NEEDLE"])
            needleLayer = layer;
        else if ([layer.name isEqualToString:@"GLOW"])
            glowLayer = layer;
    }

    CGFloat newAlpha = (CGFloat)(((to/total) * (MAXIMUM_TP_GLOW_ALPHA - MINIMUM_TP_GLOW_ALPHA)) + MINIMUM_TP_GLOW_ALPHA);
    CGFloat newAngle = (CGFloat)((((to/total) * (MAXIMUM_TP_NEEDLE_ANGLE - MINIMUM_TP_NEEDLE_ANGLE)) + MINIMUM_TP_NEEDLE_ANGLE) * ((CGFloat)(M_PI) / 180.0));


    CABasicAnimation* fadeAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnim.fromValue = @(glowLayer.opacity);
    fadeAnim.toValue = @(newAlpha);
    fadeAnim.duration = 0.05;
    [glowLayer addAnimation:fadeAnim forKey:@"opacity"];

    // Change the actual data value in the layer to the final value.
    glowLayer.opacity = newAlpha;

    CABasicAnimation *animateZRotation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animateZRotation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(newAngle, 0, 0, 1.0)];
    animateZRotation.duration = 0.05;
    [needleLayer addAnimation:animateZRotation forKey:@"rotate"];

    needleLayer.transform = CATransform3DMakeRotation(newAngle, 0, 0, 1.0);

//    [UIView animateWithDuration:0.1
//                            animations:^{
//                                    needleLayer.transform = CATransform3DMakeRotation(newAngle, 0.0, 0.0, 1.0);
//                                    glowLayer.opacity = newAlpha;
//                            }
//                            completion:^(BOOL finished){
//
//                    }];
}

- (CGMutablePathRef)roundedRectangleForFrame:(CGRect)frame withRadius:(CGFloat)cornerRadius corners:(RoundedCorners)roundedCorners
{
    CGMutablePathRef path = CGPathCreateMutable();

    CGFloat bottomLeftCornerRadius  = roundedCorners & BOTTOM_LEFT  ? cornerRadius : 0;
    CGFloat bottomRightCornerRadius = roundedCorners & BOTTOM_RIGHT ? cornerRadius : 0;
    CGFloat topLeftCornerRadius     = roundedCorners & TOP_LEFT     ? cornerRadius : 0;
    CGFloat topRightCornerRadius    = roundedCorners & TOP_RIGHT    ? cornerRadius : 0;

    CGPathMoveToPoint(path, NULL, 0, frame.size.height - bottomLeftCornerRadius);
    CGPathAddLineToPoint(path, NULL, 0, topLeftCornerRadius);
    CGPathAddArc(path, NULL, topLeftCornerRadius, topLeftCornerRadius, topLeftCornerRadius, M_PI, -M_PI_2, NO);
    CGPathAddLineToPoint(path, NULL, frame.size.width - topRightCornerRadius, 0);
    CGPathAddArc(path, NULL, frame.size.width - topRightCornerRadius, topRightCornerRadius, topRightCornerRadius, -M_PI_2, 0, NO);
    CGPathAddLineToPoint(path, NULL, frame.size.width, frame.size.height - bottomRightCornerRadius);
    CGPathAddArc(path, NULL, frame.size.width - bottomRightCornerRadius, frame.size.height - bottomRightCornerRadius, bottomRightCornerRadius, 0, M_PI_2, NO);
    CGPathAddLineToPoint(path, NULL, bottomLeftCornerRadius, frame.size.height);
    CGPathAddArc(path, NULL, (bottomLeftCornerRadius), frame.size.height - bottomLeftCornerRadius, bottomLeftCornerRadius, M_PI_2, M_PI, NO);

    return path;
}

- (void)drawHood:(UIView *)hoodView
{
    CGFloat cornerRadius = 10;
    CGRect frame = hoodView.bounds;

    CAShapeLayer *shapeLayer = [CAShapeLayer layer];

//    shapeLayer.path = [self roundedRectangleForFrame:frame withRadius:cornerRadius corners:TOP_LEFT | TOP_RIGHT];
//
//    shapeLayer.backgroundColor = [[UIColor clearColor] CGColor];
//    shapeLayer.frame           = frame;
//    shapeLayer.masksToBounds   = NO;
//    shapeLayer.fillColor       = [[UIColor grayColor] CGColor];
//    shapeLayer.strokeColor     = [[UIColor clearColor] CGColor];
//    shapeLayer.lineWidth       = 0;
//    shapeLayer.lineCap         = kCALineCapRound;
//
//    [hoodView.layer addSublayer:shapeLayer];
}

- (CAShapeLayer *)shapeLayerForDoorWithFrame:(CGRect)frame corners:(RoundedCorners)roundedCorners
{
    CGFloat cornerRadius = 5;

    CAShapeLayer *shapeLayer = [CAShapeLayer layer];

    shapeLayer.path = [self roundedRectangleForFrame:frame withRadius:cornerRadius corners:roundedCorners];

    shapeLayer.backgroundColor = [[UIColor clearColor] CGColor];
    shapeLayer.frame           = frame;
    shapeLayer.masksToBounds   = NO;
    shapeLayer.fillColor       = [[UIColor grayColor] CGColor];
    shapeLayer.strokeColor     = [[UIColor clearColor] CGColor];
    shapeLayer.lineWidth       = 0;
    shapeLayer.lineCap         = kCALineCapRound;

    return shapeLayer;
}

#define DOOR_WIDTH 10
- (void)drawLeftFrontDoorView:(UIView *)doorView
{
    [doorView.layer addSublayer:[self shapeLayerForDoorWithFrame:CGRectMake(doorView.frame.size.width - DOOR_WIDTH, 0, DOOR_WIDTH, doorView.frame.size.height)
                                                         corners:TOP_LEFT]];
}

- (void)drawLeftRearDoorView:(UIView *)doorView
{
    [doorView.layer addSublayer:[self shapeLayerForDoorWithFrame:CGRectMake(doorView.frame.size.width - DOOR_WIDTH, 0, DOOR_WIDTH, doorView.frame.size.height)
                                                         corners:BOTTOM_LEFT]];
}

- (void)drawRightFrontDoorView:(UIView *)doorView
{
    [doorView.layer addSublayer:[self shapeLayerForDoorWithFrame:CGRectMake(0, 0, DOOR_WIDTH, doorView.frame.size.height)
                                                         corners:TOP_RIGHT]];
}

- (void)drawRightRearDoorView:(UIView *)doorView
{
    [doorView.layer addSublayer:[self shapeLayerForDoorWithFrame:CGRectMake(0, 0, DOOR_WIDTH, doorView.frame.size.height)
                                                         corners:BOTTOM_RIGHT]];
}

- (void)drawTrunk:(UIView *)trunkView
{

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
