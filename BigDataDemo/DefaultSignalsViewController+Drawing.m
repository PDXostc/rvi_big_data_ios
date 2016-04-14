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

- (void)drawSteeringAngleView:(UIView *)steeringAngleView
{

}

- (void)drawCompositeCarView:(UIView *)compositeCarView
{
    NSArray *compositeImageNamesAndProperties = @[
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

    for (NSDictionary *dictionary in compositeImageNamesAndProperties)
    {
        NSString    *imageName    = dictionary.allKeys[0];
        NSString    *propertyName = dictionary.allValues[0];

        UIImageView *imageView    = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];

        [self setValue:imageView forKey:propertyName];

        imageView.frame  = compositeCarView.bounds;

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

        /* Turn this into a masking layer */
        if ([propertyName containsString:@"lfWindowAnimatedGradientImageView"])
            [self morphAnimatedWindowGradientView:imageView withGradientStartPoint:CGPointMake(0.314, 0.69) stopPoint:CGPointMake(0.35, 0.51)];
        else if ([propertyName containsString:@"rfWindowAnimatedGradientImageView"])
            [self morphAnimatedWindowGradientView:imageView withGradientStartPoint:CGPointMake(0.686, 0.69) stopPoint:CGPointMake(0.65, 0.51)];
        else if ([propertyName containsString:@"lrWindowAnimatedGradientImageView"])
            [self morphAnimatedWindowGradientView:imageView withGradientStartPoint:CGPointMake(0.318, 0.8) stopPoint:CGPointMake(0.25, 0.653)];
        else if ([propertyName containsString:@"rrWindowAnimatedGradientImageView"])
            [self morphAnimatedWindowGradientView:imageView withGradientStartPoint:CGPointMake(0.682, 0.8) stopPoint:CGPointMake(0.75, 0.653)];


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

    self.vehicleOutlineExteriorImageView.hidden = NO;
}

- (void)morphAnimatedWindowGradientView:(UIImageView *)maskImageView withGradientStartPoint:(CGPoint)startPoint stopPoint:(CGPoint)stopPoint
{
    CALayer *maskLayer    = [CALayer layer];
    UIImage *mask         = maskImageView.image;

    maskImageView.image   = nil;

    DLog(@"%g %g", mask.size.width, mask.size.height);
    maskLayer.contents    = (id)mask.CGImage;
    maskLayer.frame       = maskImageView.layer.bounds;

    maskImageView.layer.mask            = maskLayer;

    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = maskImageView.bounds;

    gradient.anchorPoint = CGPointMake(0, 0);
    gradient.position    = CGPointMake(0, 0);

    gradient.startPoint  = startPoint;
    gradient.endPoint    = stopPoint;

    gradient.colors = @[(__bridge id)[[UIColor colorWithRed:(CGFloat)(255.0 / 255.0)
                                                      green:(CGFloat)(255.0 / 255.0)
                                                       blue:(CGFloat)(255.0 / 255.0)
                                                      alpha:0.5] CGColor], (__bridge id)[[UIColor clearColor] CGColor]];

    [maskImageView.layer insertSublayer:gradient atIndex:0];
}

- (void)animateGradientView:(UIImageView *)gradientView from:(NSInteger)from to:(NSInteger)to
{
    CALayer *layer = [gradientView.layer sublayers][0];

    NSInteger inverseValue = to;//5 - to;

    CGPoint newPosition = CGPointMake(0.0, (CGFloat)(20 * inverseValue));

    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [layer valueForKey:@"position"];
    animation.toValue = [NSValue valueWithCGPoint:newPosition];
    layer.position = newPosition;
    [layer addAnimation:animation forKey:@"position"];
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
@end
