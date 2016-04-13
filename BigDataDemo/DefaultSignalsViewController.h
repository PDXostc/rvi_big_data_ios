/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 * Copyright (c) 2016 Jaguar Land Rover.
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 *
 * File:    DefaultSignalsViewController.h
 * Project: BigDataDemo
 *
 * Created by Lilli Szafranski on 2/23/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DataViewController.h"


@interface DefaultSignalsViewController : DataViewController
@property (nonatomic, weak) UIImageView *lfDoorClosedImageView;
@property (nonatomic, weak) UIImageView *lfDoorClosedIndicatorImageView;
@property (nonatomic, weak) UIImageView *lfDoorOpenImageView;
@property (nonatomic, weak) UIImageView *lfSeatbeltOffIndicatorImageView;
@property (nonatomic, weak) UIImageView *lfSeatbeltOnIndicatorImageView;
@property (nonatomic, weak) UIImageView *lfWindowDottedLineGraphicImageView;
@property (nonatomic, weak) UIImageView *lfWindowMovingDownIndicatorImageView;
@property (nonatomic, weak) UIImageView *lfWindowMovingUpIndicatorImageView;
@property (nonatomic, weak) UIImageView *lfWindowTotallyDownIndicatorImageView;
@property (nonatomic, weak) UIImageView *lfWindowTotallyUpIndicatorImageView;
@property (nonatomic, weak) UIImageView *lfWindowUpDownGraphicImageView;
@property (nonatomic, weak) UIImageView *lrDoorClosedImageView;
@property (nonatomic, weak) UIImageView *lrDoorClosedIndicatorImageView;
@property (nonatomic, weak) UIImageView *lrDoorOpenImageView;
@property (nonatomic, weak) UIImageView *lrSeatbeltOffIndicatorImageView;
@property (nonatomic, weak) UIImageView *lrSeatbeltOnIndicatorImageView;
@property (nonatomic, weak) UIImageView *lrWindowDottedLineGraphicImageView;
@property (nonatomic, weak) UIImageView *lrWindowMovingDownIndicatorImageView;
@property (nonatomic, weak) UIImageView *lrWindowMovingUpIndicatorImageView;
@property (nonatomic, weak) UIImageView *lrWindowTotallyDownIndicatorImageView;
@property (nonatomic, weak) UIImageView *lrWindowTotallyUpIndicatorImageView;
@property (nonatomic, weak) UIImageView *lrWindowUpDownGraphicImageView;
@property (nonatomic, weak) UIImageView *rfDoorClosedImageView;
@property (nonatomic, weak) UIImageView *rfDoorClosedIndicatorImageView;
@property (nonatomic, weak) UIImageView *rfDoorOpenImageView;
@property (nonatomic, weak) UIImageView *rfSeatbeltOffIndicatorImageView;
@property (nonatomic, weak) UIImageView *rfSeatbeltOnIndicatorImageView;
@property (nonatomic, weak) UIImageView *rfWindowDottedLineGraphicImageView;
@property (nonatomic, weak) UIImageView *rfWindowMovingDownIndicatorImageView;
@property (nonatomic, weak) UIImageView *rfWindowMovingUpIndicatorImageView;
@property (nonatomic, weak) UIImageView *rfWindowTotallyDownIndicatorImageView;
@property (nonatomic, weak) UIImageView *rfWindowTotallyUpIndicatorImageView;
@property (nonatomic, weak) UIImageView *rfWindowUpDownGraphicImageView;
@property (nonatomic, weak) UIImageView *rrDoorClosedImageView;
@property (nonatomic, weak) UIImageView *rrDoorClosedIndicatorImageView;
@property (nonatomic, weak) UIImageView *rrDoorOpenImageView;
@property (nonatomic, weak) UIImageView *rrSeatbeltOffIndicatorImageView;
@property (nonatomic, weak) UIImageView *rrSeatbeltOnIndicatorImageView;
@property (nonatomic, weak) UIImageView *rrWindowDottedLineGraphicImageView;
@property (nonatomic, weak) UIImageView *rrWindowMovingDownIndicatorImageView;
@property (nonatomic, weak) UIImageView *rrWindowMovingUpIndicatorImageView;
@property (nonatomic, weak) UIImageView *rrWindowTotallyDownIndicatorImageView;
@property (nonatomic, weak) UIImageView *rrWindowTotallyUpImageView;
@property (nonatomic, weak) UIImageView *rrWindowUpDownGraphicImageView;
@property (nonatomic, weak) UIImageView *highBeamsImageView;
@property (nonatomic, weak) UIImageView *hoodClosedIndicatorImageView;
@property (nonatomic, weak) UIImageView *hoodOpenIndicatorImageView;
@property (nonatomic, weak) UIImageView *lowBeamsImageView;
@property (nonatomic, weak) UIImageView *steeringWheelCompositeImageView;
@property (nonatomic, weak) UIImageView *throttlePressureBottomLayerImageView;
@property (nonatomic, weak) UIImageView *throttlePressureGlowLayerImageView;
@property (nonatomic, weak) UIImageView *throttlePressureNeedleImageView;
@property (nonatomic, weak) UIImageView *throttlePressureTopLayerImageView;
@property (nonatomic, weak) UIImageView *trunkClosedIndicatorImageView;
@property (nonatomic, weak) UIImageView *trunkOpenIndicatorImageView;
@property (nonatomic, weak) UIImageView *vehicleOutlineExteriorImageView;
@property (nonatomic, weak) UIImageView *vehicleOutlineInteriorImageView;

@property (nonatomic, strong) NSMutableSet *allSuperWideExteriorImages;
@property (nonatomic, strong) NSMutableSet *currentlyShowingClosedDoorImages;
@end
