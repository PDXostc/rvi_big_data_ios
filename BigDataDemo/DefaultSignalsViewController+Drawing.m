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

//typedef enum
//{
//    NONE = 0,
//    TOP_LEFT = 1,
//    TOP_RIGHT = 2,
//    BOTTOM_LEFT = 4,
//    BOTTOM_RIGHT = 8
//} RoundedCorners;

typedef enum
{
    LF,
    RF,
    LR,
    RR,
} Window;

@implementation DefaultSignalsViewController (Drawing)

- (void)addImageView:(UIImageView *)imageView toCompositeCarView:(UIView *)compositeCarView andPropertyWithName:(NSString *)propertyName
{
    [self setValue:imageView forKey:propertyName];

    imageView.frame = compositeCarView.bounds;

    /* Hide all but the door closed image views, as they're default showing... */
    if (![propertyName containsString:@"DoorClosedImageView"])
        imageView.hidden = YES;
        /* and put them in the currentlyShowingClosedDoorImages set. */
    else
        [self.currentlyShowingClosedDoorImages addObject:imageView];

    imageView.contentScaleFactor = UIViewContentModeScaleAspectFit;

    [compositeCarView addSubview:imageView];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:compositeCarView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:compositeCarView
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:compositeCarView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:compositeCarView
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0.0]];
}

//- (void)removeImageView:(UIImageView *)imageView fromCompositeCarView:(UIView *)compositeCarView andPropertyWithName:(NSString *)propertyName
//{
//    [imageView removeFromSuperview];
//    [self setValue:nil forKey:propertyName];
//}

- (void)drawCompositeCarView:(UIView *)compositeCarView numberOfDoors:(NSInteger)numberOfDoors numberOfSeats:(NSInteger)numberOfSeats
{
    NSArray *exteriorCompositeImageNamesAndProperties = @[
            @{ @"vehicle_outline_exterior.png"         : @"vehicleOutlineExteriorImageView"      },
            @{ @"LF_door_closed.png"                   : @"lfDoorClosedImageView"                },
            @{ @"LF_door_closed_indicator.png"         : @"lfDoorClosedIndicatorImageView"       },
            @{ @"LF_door_open.png"                     : @"lfDoorOpenImageView"                  },
            @{ @"LF_window_animated_gradient.png"      : @"lfWindowAnimatedGradientImageView"    },
            @{ @"LF_window_dotted_line_graphic.png"    : @"lfWindowDottedLineGraphicImageView"   },
            @{ @"LF_window_up_down_graphic.png"        : @"lfWindowUpDownGraphicImageView"       },
            @{ @"LF_window_moving_down_indicator.png"  : @"lfWindowMovingDownIndicatorImageView" },
            @{ @"LF_window_moving_up_indicator.png"    : @"lfWindowMovingUpIndicatorImageView"   },
            @{ @"LF_window_totally_down_indicator.png" : @"lfWindowTotallyDownIndicatorImageView"},
            @{ @"LF_window_totally_up_indicator.png"   : @"lfWindowTotallyUpIndicatorImageView"  },
            @{ @"LR_door_closed.png"                   : @"lrDoorClosedImageView"                },
            @{ @"LR_door_closed_indicator.png"         : @"lrDoorClosedIndicatorImageView"       },
            @{ @"LR_door_open.png"                     : @"lrDoorOpenImageView"                  },
            @{ @"LR_window_animated_gradient.png"      : @"lrWindowAnimatedGradientImageView"    },
            @{ @"LR_window_dotted_line_graphic.png"    : @"lrWindowDottedLineGraphicImageView"   },
            @{ @"LR_window_up_down_graphic.png"        : @"lrWindowUpDownGraphicImageView"       },
            @{ @"LR_window_moving_down_indicator.png"  : @"lrWindowMovingDownIndicatorImageView" },
            @{ @"LR_window_moving_up_indicator.png"    : @"lrWindowMovingUpIndicatorImageView"   },
            @{ @"LR_window_totally_down_indicator.png" : @"lrWindowTotallyDownIndicatorImageView"},
            @{ @"LR_window_totally_up_indicator.png"   : @"lrWindowTotallyUpIndicatorImageView"  },
            @{ @"RF_door_closed.png"                   : @"rfDoorClosedImageView"                },
            @{ @"RF_door_closed_indicator.png"         : @"rfDoorClosedIndicatorImageView"       },
            @{ @"RF_door_open.png"                     : @"rfDoorOpenImageView"                  },
            @{ @"RF_window_animated_gradient.png"      : @"rfWindowAnimatedGradientImageView"    },
            @{ @"RF_window_dotted_line_graphic.png"    : @"rfWindowDottedLineGraphicImageView"   },
            @{ @"RF_window_up_down_graphic.png"        : @"rfWindowUpDownGraphicImageView"       },
            @{ @"RF_window_moving_down_indicator.png"  : @"rfWindowMovingDownIndicatorImageView" },
            @{ @"RF_window_moving_up_indicator.png"    : @"rfWindowMovingUpIndicatorImageView"   },
            @{ @"RF_window_totally_down_indicator.png" : @"rfWindowTotallyDownIndicatorImageView"},
            @{ @"RF_window_totally_up_indicator.png"   : @"rfWindowTotallyUpIndicatorImageView"  },
            @{ @"RR_door_closed.png"                   : @"rrDoorClosedImageView"                },
            @{ @"RR_door_closed_indicator.png"         : @"rrDoorClosedIndicatorImageView"       },
            @{ @"RR_door_open.png"                     : @"rrDoorOpenImageView"                  },
            @{ @"RR_window_animated_gradient.png"      : @"rrWindowAnimatedGradientImageView"    },
            @{ @"RR_window_dotted_line_graphic.png"    : @"rrWindowDottedLineGraphicImageView"   },
            @{ @"RR_window_up_down_graphic.png"        : @"rrWindowUpDownGraphicImageView"       },
            @{ @"RR_window_moving_down_indicator.png"  : @"rrWindowMovingDownIndicatorImageView" },
            @{ @"RR_window_moving_up_indicator.png"    : @"rrWindowMovingUpIndicatorImageView"   },
            @{ @"RR_window_totally_down_indicator.png" : @"rrWindowTotallyDownIndicatorImageView"},
            @{ @"RR_window_totally_up_indicator.png"   : @"rrWindowTotallyUpIndicatorImageView"  },
            @{ @"high_beams.png"                       : @"highBeamsImageView"                   },
            @{ @"hood_closed_indicator.png"            : @"hoodClosedIndicatorImageView"         },
            @{ @"hood_open_indicator.png"              : @"hoodOpenIndicatorImageView"           },
            @{ @"low_beams.png"                        : @"lowBeamsImageView"                    },
            @{ @"trunk_closed_indicator.png"           : @"trunkClosedIndicatorImageView"        },
            @{ @"trunk_open_indicator.png"             : @"trunkOpenIndicatorImageView"          },
     ];

    NSArray *interiorCompositeImageNamesAndProperties = @[
            @{ @"vehicle_outline_interior.png"         : @"vehicleOutlineInteriorImageView"      },
            @{ @"LF_seatbelt_off_indicator.png"        : @"lfSeatbeltOffIndicatorImageView"      },
            @{ @"LF_seatbelt_on_indicator.png"         : @"lfSeatbeltOnIndicatorImageView"       },
            @{ @"LR_seatbelt_off_indicator.png"        : @"lrSeatbeltOffIndicatorImageView"      },
            @{ @"LR_seatbelt_on_indicator.png"         : @"lrSeatbeltOnIndicatorImageView"       },
            @{ @"RF_seatbelt_off_indicator.png"        : @"rfSeatbeltOffIndicatorImageView"      },
            @{ @"RF_seatbelt_on_indicator.png"         : @"rfSeatbeltOnIndicatorImageView"       },
            @{ @"RR_seatbelt_off_indicator.png"        : @"rrSeatbeltOffIndicatorImageView"      },
            @{ @"RR_seatbelt_on_indicator.png"         : @"rrSeatbeltOnIndicatorImageView"       }
     ];

    NSString *doorPrefix = numberOfDoors == 2 ? @"2DR_" : numberOfDoors == 4 ? @"4DR_" : @"";
    NSString *seatPrefix = numberOfSeats == 2 ? @"2SE_" : numberOfSeats == 4 ? @"4SE_" : numberOfSeats == 5 ? @"5SE_" : @"";

    [[compositeCarView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    for (NSDictionary *dictionary in exteriorCompositeImageNamesAndProperties)
    {
        NSString *imageName    = dictionary.allKeys[0];
        NSString *propertyName = dictionary.allValues[0];

        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", doorPrefix, imageName]]];

        if (imageView)
        {
            [self addImageView:imageView toCompositeCarView:compositeCarView andPropertyWithName:propertyName];

            /* Turn this into a masking layer and draw the gradient */
            if ([propertyName containsString:@"lfWindowAnimatedGradientImageView"])
                [self morphAnimatedWindowGradientView:imageView
                               withGradientStartPoint:[self startPointForWindow:LF doors:numberOfDoors]
                                            stopPoint:[self stopPointForWindow: LF doors:numberOfDoors]];
            else if ([propertyName containsString:@"rfWindowAnimatedGradientImageView"])
                [self morphAnimatedWindowGradientView:imageView
                               withGradientStartPoint:[self startPointForWindow:RF doors:numberOfDoors]
                                            stopPoint:[self stopPointForWindow: RF doors:numberOfDoors]];
            else if ([propertyName containsString:@"lrWindowAnimatedGradientImageView"])
                [self morphAnimatedWindowGradientView:imageView
                               withGradientStartPoint:[self startPointForWindow:LR doors:numberOfDoors]
                                            stopPoint:[self stopPointForWindow: LR doors:numberOfDoors]];
            else if ([propertyName containsString:@"rrWindowAnimatedGradientImageView"])
                [self morphAnimatedWindowGradientView:imageView
                               withGradientStartPoint:[self startPointForWindow:RR doors:numberOfDoors]
                                            stopPoint:[self stopPointForWindow: RR doors:numberOfDoors]];

            /* All the window-related indicator images, and the door open indicator images extend off of the side of the car outline and should
             * be hidden when the interior outline appears. Instead of writing them all out, use a little regex to stick them in the set of images
             * that should be hidden. */
            if ([propertyName containsString:@"Window"])
                [self.allSuperWideExteriorImages addObject:imageView];
            else if ([propertyName containsString:@"DoorOpenImageView"])
                [self.allSuperWideExteriorImages addObject:imageView];
            else if ([propertyName containsString:@"DoorClosed"])
                [self.allSuperWideExteriorImages addObject:imageView];

        }
        else
        {
            [self setValue:nil forKey:propertyName];
        }
    }

    for (NSDictionary *dictionary in interiorCompositeImageNamesAndProperties)
    {
        NSString *imageName    = dictionary.allKeys[0];
        NSString *propertyName = dictionary.allValues[0];

        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@", seatPrefix, imageName]]];

        if (imageView)
        {
            [self addImageView:imageView toCompositeCarView:compositeCarView andPropertyWithName:propertyName];
        }
        else
        {
            [self setValue:nil forKey:propertyName];
        }
    }

    self.vehicleOutlineExteriorImageView.hidden = NO;
}

#define WINDOW_VIEW_ANCHOR_H_POSITION   0.5
#define WINDOW_VIEW_ANCHOR_V_POSITION   0.65
#define COMPOSITE_VIEW_WIDTH            1240
#define COMPOSITE_VIEW_HEIGHT           1820
#define COMPOSITE_VIEW_AMOUNT_BIGGER_H  100.0
#define COMPOSITE_VIEW_AMOUNT_BIGGER_V  50.0
#define WINDOW_VIEW_PERCENTAGE_BIGGER_H 0.04
#define WINDOW_VIEW_PERCENTAGE_BIGGER_V 0.057

CGPoint makeGradientPointFromPoint(CGFloat x, CGFloat y)
{
    return CGPointMake((CGFloat)((x + (COMPOSITE_VIEW_AMOUNT_BIGGER_H / 2)) / (COMPOSITE_VIEW_WIDTH  + COMPOSITE_VIEW_AMOUNT_BIGGER_H)),
                       (CGFloat)((y + (COMPOSITE_VIEW_AMOUNT_BIGGER_V    )) / (COMPOSITE_VIEW_HEIGHT + COMPOSITE_VIEW_AMOUNT_BIGGER_V)));
}

- (CGPoint)startPointForWindow:(Window)window doors:(NSInteger)doors
{
    if (doors == 2)
    {
        switch (window)
        {
            case LF: return makeGradientPointFromPoint(370, 1337);//(394, 1471);//(0.328, 0.653); /* (370, 1337) when composite view is (1240, 1820) */
            case RF: return makeGradientPointFromPoint(870, 1337);//(846, 1471);//(0.672, 0.653); /* (870, 1337) when composite view is (1240, 1820) */
            default: return CGPointMake(0.0, 0.0);
        }
    }
    else if (doors == 4)
    {
        switch (window)
        {
            case LF: return makeGradientPointFromPoint(389, 1276);//(0.328, 0.653); /* (389, 1276) when composite view is (1240, 1820) */
            case RF: return makeGradientPointFromPoint(851, 1276);//(0.672, 0.653); /* (851, 1276) when composite view is (1240, 1820) */
            case LR: return makeGradientPointFromPoint(394, 1469);//(0.331, 0.757); /* (394, 1469) when composite view is (1240, 1820) */
            case RR: return makeGradientPointFromPoint(846, 1469);//(0.669, 0.757); /* (846, 1469) when composite view is (1240, 1820) */
        }

    }

    return CGPointMake(0.0, 0.0);
}

- (CGPoint)stopPointForWindow:(Window)window doors:(NSInteger)doors
{
    if (doors == 2)
    {
        switch (window)
        {
            case LF: return makeGradientPointFromPoint(357, 1277);//(289, 990);//(0.328, 0.653); /* (357, 1277) when composite view is (1240, 1820) */
            case RF: return makeGradientPointFromPoint(883, 1277);//(0.672, 0.653); /* (883, 1277) when composite view is (1240, 1820) */
            default: return CGPointMake(0.0, 0.0);
        }
    }
    else if (doors == 4)
    {
        /* (389, 1210) and (434, 895) when composite view is (1240, 1754) but then we add another 5.7% to the bottom and 8% to each side
         * so it doesn't cut off when animated making it (1340, 1854) */

        switch (window) {
            case LF: return makeGradientPointFromPoint(434, 961) ; /* (434, 961) when composite view is (1240, 1820) */
            case RF: return makeGradientPointFromPoint(806, 961) ; /* (806, 961) when composite view is (1240, 1820) */
            case LR: return makeGradientPointFromPoint(310, 1211); /* (310, 1211) when composite view is (1240, 1820) */
            case RR: return makeGradientPointFromPoint(930, 1211); /* (930, 1211) when composite view is (1240, 1820) */
        }

    }

    return CGPointMake(0.0, 0.0);
}

- (void)morphAnimatedWindowGradientView:(UIImageView *)maskImageView withGradientStartPoint:(CGPoint)startPoint stopPoint:(CGPoint)stopPoint
{
    CALayer *maskLayer    = [CALayer layer];
    UIImage *mask         = maskImageView.image;

    maskImageView.image   = nil;

    DLog(@"%g %g", mask.size.width, mask.size.height);
    maskLayer.contents    = (id)mask.CGImage;
    maskLayer.frame       = maskImageView.layer.bounds;

    maskImageView.layer.mask = maskLayer;

    CGRect frame = maskImageView.bounds;

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = frame;
    gradient.frame = CGRectMake(0, 0,
                                (CGFloat)(frame.size.width + (2.0 * WINDOW_VIEW_PERCENTAGE_BIGGER_H * frame.size.width)),
                                (CGFloat)(frame.size.height + (WINDOW_VIEW_PERCENTAGE_BIGGER_V * frame.size.height)));

//    gradient.borderWidth = 2.0;
//    gradient.borderColor = [UIColor redColor].CGColor;

    gradient.anchorPoint = CGPointMake(WINDOW_VIEW_ANCHOR_H_POSITION, WINDOW_VIEW_ANCHOR_V_POSITION);
    gradient.position    = CGPointMake((CGFloat)((maskImageView.bounds.size.width) * WINDOW_VIEW_ANCHOR_H_POSITION),
                                       (CGFloat)((maskImageView.bounds.size.height + (WINDOW_VIEW_PERCENTAGE_BIGGER_V * frame.size.height)) * WINDOW_VIEW_ANCHOR_V_POSITION));

    gradient.startPoint  = startPoint;
    gradient.endPoint    = stopPoint;

    gradient.colors = @[(__bridge id)[[UIColor colorWithRed:(CGFloat)(255.0 / 255.0)
                                                      green:(CGFloat)(255.0 / 255.0)
                                                       blue:(CGFloat)(255.0 / 255.0)
                                                      alpha:0.5] CGColor],
                        (__bridge id)[[UIColor colorWithRed:(CGFloat)(255.0 / 255.0)
                                                      green:(CGFloat)(255.0 / 255.0)
                                                       blue:(CGFloat)(255.0 / 255.0)
                                                      alpha:0.001] CGColor]];


            //(__bridge id)[[UIColor clearColor] CGColor]];

    [maskImageView.layer insertSublayer:gradient atIndex:0];
}

#define MINIMUM_TP_NEEDLE_ANGLE 0
#define MAXIMUM_TP_NEEDLE_ANGLE 270
#define MINIMUM_TP_GLOW_ALPHA   0.2
#define MAXIMUM_TP_GLOW_ALPHA   1.0
- (void)drawThrottlePositionView:(UIView *)throttlePressureView
{
    CALayer *backgroundLayer     = [CALayer layer];
    CALayer *backgroundMaskLayer = [CALayer layer];
    CALayer *glowLayer           = [CALayer layer];
    CALayer *middleLayer         = [CALayer layer];
    CALayer *needleLayer         = [CALayer layer];
    CALayer *topLayer            = [CALayer layer];

    backgroundMaskLayer.contents = (id)[UIImage imageNamed:@"throttle_position_glow_layer.png"].CGImage;
    glowLayer.contents           = (id)[UIImage imageNamed:@"throttle_position_glow_layer.png"].CGImage;
    middleLayer.contents         = (id)[UIImage imageNamed:@"throttle_position_bottom_layer.png"].CGImage;
    needleLayer.contents         = (id)[UIImage imageNamed:@"throttle_position_needle.png"].CGImage;
    topLayer.contents            = (id)[UIImage imageNamed:@"throttle_position_top_layer.png"].CGImage;

    backgroundLayer.frame =
            backgroundMaskLayer.frame =
                    middleLayer.frame =
                            glowLayer.frame =
                                    needleLayer.frame =
                                            topLayer.frame = throttlePressureView.bounds;

    backgroundLayer.backgroundColor = [UIColor grayColor].CGColor;
    backgroundLayer.mask = backgroundMaskLayer;

//    middleLayer.anchorPoint =
//            needleLayer.anchorPoint =
//                    topLayer.anchorPoint = throttlePositionView.center;

    needleLayer.name = @"NEEDLE";
    glowLayer.name = @"GLOW";

    glowLayer.opacity = MINIMUM_TP_GLOW_ALPHA;

    [[throttlePressureView layer] addSublayer:backgroundLayer];
    [[throttlePressureView layer] addSublayer:glowLayer];
    [[throttlePressureView layer] addSublayer:middleLayer];
    [[throttlePressureView layer] addSublayer:needleLayer];
    [[throttlePressureView layer] addSublayer:topLayer];

    CALayer *throttlePressureLabel = throttlePressureView.layer.sublayers[0];
    throttlePressureLabel.zPosition = 6;
}

- (void)drawSteeringAngleView:(UIView *)steeringAngleView
{
    CALayer *steeringLayer = [CALayer layer];

    steeringLayer.contents = (id)[UIImage imageNamed:@"steering_wheel_composite.png"].CGImage;
    steeringLayer.frame    = steeringAngleView.bounds;

    [[steeringAngleView layer] addSublayer:steeringLayer];
}

- (void)animateGradientView:(UIImageView *)gradientView to:(NSInteger)to byAngle:(CGFloat)angle
{
    CALayer *layer = [gradientView.layer sublayers][0];

    NSInteger inverseValue = 5 - to;

    CGFloat newAngle = (CGFloat)(inverseValue * angle * ((CGFloat)(M_PI) / 180.0));

    CABasicAnimation *animateZRotation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animateZRotation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(newAngle, 0, 0, 1.0)];
    animateZRotation.duration = 0.05;
    [layer addAnimation:animateZRotation forKey:@"rotate"];

    layer.transform = CATransform3DMakeRotation(newAngle, 0, 0, 1.0);
}

- (void)animateChangeInThrottlePosition:(UIView *)throttlePressureView from:(float)from to:(float)to total:(float)total
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
}

- (void)animateChangeInSteeringAngle:(UIView *)steeringAngleView from:(float)from to:(float)to total:(float)total
{
    DLog(@"");

    CALayer *layer = [steeringAngleView.layer sublayers][0];;

    CGFloat newAngle = (CGFloat)(to * ((CGFloat)(M_PI) / 180.0));

    CABasicAnimation *animateZRotation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animateZRotation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(newAngle, 0, 0, 1.0)];
    animateZRotation.duration = 0.05;
    [layer addAnimation:animateZRotation forKey:@"rotate"];

    layer.transform = CATransform3DMakeRotation(newAngle, 0, 0, 1.0);
}
@end
