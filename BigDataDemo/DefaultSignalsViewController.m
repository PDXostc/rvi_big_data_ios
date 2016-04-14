/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 * Copyright (c) 2016 Jaguar Land Rover.
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 *
 * File:    DefaultSignalsViewController.m
 * Project: BigDataDemo
 *
 * Created by Lilli Szafranski on 2/23/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "DefaultSignalsViewController.h"
#import "Util.h"
#import "Vehicle.h"
#import "VehicleManager.h"
#import "DefaultSignalsViewController+Drawing.h"

#define FADE_OUT_ANIMATION_DURATION 1.5
#define FADE_OUT_ANIMATION_DELAY    8.0

typedef enum
{
    DRIVER_UNKNOWN,
    DRIVER_LEFT,
    DRIVER_RIGHT,
} DriversSide;

typedef enum
{
    ZONE_UNKNOWN,
    ZONE_LF,
    ZONE_RF,
    ZONE_LR,
    ZONE_RR,
    ZONE_MR,
} Zone;

@interface DefaultSignalsViewController ()
@property (nonatomic, weak)   Vehicle *vehicle;
@property (nonatomic, strong) IBOutlet UIView  *throttlePressureView;
@property (nonatomic, strong) IBOutlet UIView  *steeringAngleView;
@property (nonatomic, strong) IBOutlet UILabel *testLabel;
@property (nonatomic, strong) IBOutlet UIView  *compositeCarView;
@property (nonatomic)         DriversSide       driversSide;

@property (nonatomic)         NSInteger         previousDoorStatus;
@property (nonatomic)         NSMutableArray   *previousWindowPositionForZone;

@property (nonatomic, strong) NSMutableSet     *currentlyShowingSeatBeltIndicatorImages;
@property (nonatomic, strong) NSMutableSet     *currentlyShowingWindowImages;
@property (nonatomic, strong) NSMutableSet     *recentlyClosedIndicatorImages;
@property (nonatomic, strong) NSMutableSet     *currentlyShowingOpenDoorImages;
@property (nonatomic, strong) NSMutableSet     *currentlyHiddenClosedDoorImages;
@end

@implementation DefaultSignalsViewController
{

}
/* Just in case I change the app later and the instance isn't constant throughout the app's execution. */
- (Vehicle *)vehicle
{
    return [VehicleManager vehicle];
}

- (void)viewDidLoad
{
    DLog(@"");
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    DLog(@"");
    [super viewWillAppear:animated];

    [self registerObservers];
}

- (void)viewDidAppear:(BOOL)animated
{
    DLog(@"");
    [super viewDidAppear:animated];

    self.allSuperWideExteriorImages       = [NSMutableSet set];
    self.recentlyClosedIndicatorImages    = [NSMutableSet set];
    self.currentlyShowingOpenDoorImages   = [NSMutableSet set];
    self.currentlyShowingClosedDoorImages = [NSMutableSet set];
    self.currentlyHiddenClosedDoorImages  = [NSMutableSet set];
    self.currentlyShowingWindowImages     = [NSMutableSet set];

    [self drawThrottlePressureView:self.throttlePressureView];
    [self drawSteeringAngleView:self.steeringAngleView];
    [self drawCompositeCarView:self.compositeCarView];

    self.currentlyShowingSeatBeltIndicatorImages = [NSMutableSet setWithObjects:
                                                         self.vehicleOutlineInteriorImageView,
                                                         self.lfSeatbeltOffIndicatorImageView,
                                                         self.rfSeatbeltOffIndicatorImageView,
                                                         self.lrSeatbeltOffIndicatorImageView,
                                                         self.rrSeatbeltOffIndicatorImageView,
                                                         nil];

    self.previousWindowPositionForZone = [@[@(0), @(0), @(0), @(0), @(0)] mutableCopy];
}

- (NSString *)stringForZone:(Zone)zone
{
    switch(zone) {
        case ZONE_UNKNOWN:
            return @"unknown";
        case ZONE_LF:
            return @"lf";
        case ZONE_RF:
            return @"rf";
        case ZONE_LR:
            return @"lr";
        case ZONE_RR:
            return @"rr";
        case ZONE_MR:
            return @"mr";
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    DLog(@"");
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    DLog(@"");
    [super viewDidDisappear:animated];

    [self unregisterObservers];
}

- (IBAction)onTestSliderValueChanged:(id)sender
{
    DLog(@"Value: %f", ((UISlider *)sender).value);
    [self animateChangeInThrottlePressure:self.throttlePressureView from:0.0 to:((UISlider *)sender).value total:100.0];
}

- (void)handleBuckleStateChange:(BOOL)value zone:(Zone)zone
{
    /* Get the on/off buckle images for this seat using the string zone and key/value coding */
    NSString    *stringForZone = [self stringForZone:zone];
    UIImageView *seatbeltOffIndicatorImageView = [self valueForKey:[NSString stringWithFormat:@"%@SeatbeltOffIndicatorImageView", stringForZone]];
    UIImageView *seatbeltOnIndicatorImageView = [self valueForKey:[NSString stringWithFormat:@"%@SeatbeltOnIndicatorImageView", stringForZone]];

    /* Remove the current indicator, and toggle it with it's opposite, hiding the one we don't want to show, and adding the one we do want to show
     * to the set of interior images. That way it will fade out/get hidden when the interior images need to be. */
    if (value) /* The person in the seat is buckled */
    {
        [self.currentlyShowingSeatBeltIndicatorImages addObject:seatbeltOnIndicatorImageView];
        [self.currentlyShowingSeatBeltIndicatorImages removeObject:seatbeltOffIndicatorImageView];

        seatbeltOffIndicatorImageView.hidden = YES;
    }
    else
    {
        [self.currentlyShowingSeatBeltIndicatorImages addObject:seatbeltOffIndicatorImageView];
        [self.currentlyShowingSeatBeltIndicatorImages removeObject:seatbeltOnIndicatorImageView];

        seatbeltOnIndicatorImageView.hidden = YES;
    }

    /* Turn off any exterior images that may be showing. */
    for (UIImageView *imageView in self.allSuperWideExteriorImages)
    {
        imageView.hidden = YES;
    }

    /* Turn on the interior set of images we want to show. */
    for (UIImageView *imageView in self.currentlyShowingSeatBeltIndicatorImages)
    {
        imageView.hidden = NO;
        imageView.alpha  = 1.0;
    }

    /* Get ready to fade any open door images back in */
    for (UIImageView *imageView in self.currentlyShowingOpenDoorImages)
    {
        imageView.alpha  = 0.0;
        imageView.hidden = NO;
    }

    /* Get ready to fade any closed door images back in */
    for (UIImageView *imageView in self.currentlyShowingClosedDoorImages)
    {
        imageView.alpha  = 0.0;
        imageView.hidden = NO;
    }

    [UIView animateWithDuration:FADE_OUT_ANIMATION_DURATION
                          delay:FADE_OUT_ANIMATION_DELAY
                        options:nil
                     animations:^{
                            for (UIImageView *imageView in self.currentlyShowingSeatBeltIndicatorImages)
                                imageView.alpha = 0.0;

                            for (UIImageView *imageView in self.currentlyShowingOpenDoorImages)
                                imageView.alpha = 1.0;

                            for (UIImageView *imageView in self.currentlyShowingClosedDoorImages)
                                imageView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                     }];

}

- (void)handleWindowPositionChange:(NSInteger)newPosition zone:(Zone)zone
{
    /* Get all of the appropriate images for the given zone using key/value coding */
    NSString    *stringForZone = [self stringForZone:zone];

    UIImageView *windowDottedLineGraphicImageView       = [self valueForKey:[NSString stringWithFormat:@"%@WindowDottedLineGraphicImageView"   , stringForZone]];
    UIImageView *windowUpDownGraphicImageView           = [self valueForKey:[NSString stringWithFormat:@"%@WindowUpDownGraphicImageView"       , stringForZone]];
    UIImageView *windowMovingDownIndicatorImageView     = [self valueForKey:[NSString stringWithFormat:@"%@WindowMovingDownIndicatorImageView" , stringForZone]];
    UIImageView *windowMovingUpIndicatorImageView       = [self valueForKey:[NSString stringWithFormat:@"%@WindowMovingUpIndicatorImageView"   , stringForZone]];
    UIImageView *windowTotallyUpIndicatorImageView      = [self valueForKey:[NSString stringWithFormat:@"%@WindowTotallyUpIndicatorImageView"  , stringForZone]];
    UIImageView *windowTotallyDownIndicatorImageView    = [self valueForKey:[NSString stringWithFormat:@"%@WindowTotallyDownIndicatorImageView", stringForZone]];


    /* Turn off the interior view */
    for (UIImageView *imageView in self.currentlyShowingSeatBeltIndicatorImages)
    {
        imageView.hidden = YES;
    }

    /* Fade any open door images */
    for (UIImageView *imageView in self.currentlyShowingOpenDoorImages)
    {
        [imageView.layer removeAllAnimations];

        imageView.alpha = 0.2;
    }

    /* Show (dimly) the hidden closed versions of any open doors so that we can have the dotted line come from the window */
    for (UIImageView *imageView in self.currentlyHiddenClosedDoorImages)
    {
        [imageView.layer removeAllAnimations];

        imageView.alpha  = 0.5;
        imageView.hidden = NO;
    }

    /* Show (dimly) not-hidden closed door images (which would be hidden if the interior view is showing) */
    for (UIImageView *imageView in self.currentlyShowingClosedDoorImages)
    {
        [imageView.layer removeAllAnimations];

        imageView.alpha  = 0.5;
        imageView.hidden = NO;
    }


    /* Add the background images to the set of window images that we will fade later */
    [self.currentlyShowingWindowImages addObject:windowDottedLineGraphicImageView];
    [self.currentlyShowingWindowImages addObject:windowUpDownGraphicImageView];


    /* First, just hide all the indicators for that side and remove them from our currentlyShowingWindowImage set until we
     * figure out which one we want to show */
    windowTotallyDownIndicatorImageView.hidden = YES;
    windowMovingDownIndicatorImageView.hidden  = YES;
    windowMovingUpIndicatorImageView.hidden    = YES;
    windowTotallyUpIndicatorImageView.hidden   = YES;

    [self.currentlyShowingWindowImages removeObject:windowTotallyDownIndicatorImageView];
    [self.currentlyShowingWindowImages removeObject:windowMovingDownIndicatorImageView];
    [self.currentlyShowingWindowImages removeObject:windowMovingUpIndicatorImageView];
    [self.currentlyShowingWindowImages removeObject:windowTotallyUpIndicatorImageView];


    /* Show the appropriate up/down indicators to the set of window images that we will fade later */
    NSInteger previousPosition = [self.previousWindowPositionForZone[zone] integerValue];

    if (newPosition == 1)
        [self.currentlyShowingWindowImages addObject:windowTotallyUpIndicatorImageView];
    else if (newPosition == 5)
        [self.currentlyShowingWindowImages addObject:windowTotallyDownIndicatorImageView];
    else if (!previousPosition) /* We really didn't have any data before to compare to, so don't do anything */
        ;
    else if (newPosition < 1 || newPosition > 5) /* Unknown/undefined, so ignore */
        ;
    else if (newPosition < previousPosition)
        [self.currentlyShowingWindowImages addObject:windowMovingUpIndicatorImageView];
    else if (newPosition > previousPosition)
        [self.currentlyShowingWindowImages addObject:windowMovingDownIndicatorImageView];


    /* Show the window indicators that we added to the set, and prepare them for the fade */
    for (UIImageView *imageView in self.currentlyShowingWindowImages)
    {
        imageView.hidden = NO;
        imageView.alpha  = 1.0;
    }

    /* Fade them out and put our doors back to normal */
    [UIView animateWithDuration:FADE_OUT_ANIMATION_DURATION
                          delay:FADE_OUT_ANIMATION_DELAY
                        options:nil
                     animations:^{
                            for (UIImageView *imageView in self.currentlyShowingWindowImages)
                                imageView.alpha = 0.0;

                            for (UIImageView *imageView in self.currentlyHiddenClosedDoorImages)
                                imageView.alpha = 0.0;

                            for (UIImageView *imageView in self.currentlyShowingClosedDoorImages)
                                imageView.alpha = 1.0;

                            for (UIImageView *imageView in self.currentlyShowingOpenDoorImages)
                                imageView.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         [self.currentlyShowingWindowImages removeAllObjects];
                     }];

    self.previousWindowPositionForZone[zone] = @(newPosition);
}

typedef enum
{
    DF_BIT_MASK = 1,
    PF_BIT_MASK = 2,
    DR_BIT_MASK = 4,
    PR_BIT_MASK = 8,
    TRUNK_BIT_MASK = 16,
    HOOD_BIT_MASK = 32,

} DoorStatusBitMask;

- (void)handleDoorStatusChangeFrom:(BOOL)wasClosed to:(BOOL)isClosed forZone:(Zone)zone
{
    /* Get all of the appropriate images for the given zone using key/value coding */
    NSString    *stringForZone = [self stringForZone:zone];

    UIImageView *doorOpenImageView            = [self valueForKey:[NSString stringWithFormat:@"%@DoorOpenImageView", stringForZone]];
    UIImageView *doorClosedImageView          = [self valueForKey:[NSString stringWithFormat:@"%@DoorClosedImageView", stringForZone]];
    UIImageView *doorClosedIndicatorImageView = [self valueForKey:[NSString stringWithFormat:@"%@DoorClosedIndicatorImageView", stringForZone]];

    /* If any of the values went from open to closed, briefly display the CLOSED INDICATOR (the green check-mark), then fade them all currently-
     * being-displayed-closed-indicators out. */
    if (!wasClosed && isClosed)
    {
        [self.recentlyClosedIndicatorImages addObject:doorClosedIndicatorImageView];
    }

    /* The actual door/hood/trunk OPEN images (the ones w red-Xs) don't fade after so many seconds, and neither do the door-closed images (just
     * the green indicators), so hide/show those appropriately. */
    doorOpenImageView.hidden   =  isClosed;
    doorClosedImageView.hidden = !isClosed;

    /* Also, hold on to any open/closed door images, as we will need to re-show them after they disappear for the display of interior images.
     * We split this up because we also need to fade open door images in/out when displaying the window indicators. We also need to hold on to
     * which closed door images aren't being showed, so we can show them during window operations. */
    if (!isClosed)
    {
        [self.currentlyShowingOpenDoorImages addObject:doorOpenImageView];
        [self.currentlyHiddenClosedDoorImages addObject:doorClosedImageView];
        [self.currentlyShowingClosedDoorImages removeObject:doorClosedImageView];

        [doorClosedImageView.layer removeAllAnimations];

        /* Also, if the door is now open, make sure the door-closed indicator isn't showing and removed from recentlyClosedIndicatorImages. */
        doorClosedIndicatorImageView.hidden = YES;
        [self.recentlyClosedIndicatorImages removeObject:doorClosedIndicatorImageView];

        [doorClosedIndicatorImageView.layer removeAllAnimations];
    }
    else
    {
        [self.currentlyShowingClosedDoorImages addObject:doorClosedImageView];
        [self.currentlyShowingOpenDoorImages removeObject:doorOpenImageView];
        [self.currentlyHiddenClosedDoorImages removeObject:doorClosedImageView];

        [doorOpenImageView.layer removeAllAnimations];
        [doorClosedImageView.layer removeAllAnimations];

        doorClosedImageView.alpha = 1.0;
    }
}

- (void)handleDoorStatusChange:(NSInteger)value
{
    /* Turn off the interior set of images that might be showing. */
    for (UIImageView *imageView in self.currentlyShowingSeatBeltIndicatorImages)
    {
        imageView.hidden = YES;
        [imageView.layer removeAllAnimations];
    }

    /* Turn off the window indicator set of images that might be showing. */
    for (UIImageView *imageView in self.currentlyShowingWindowImages)
    {
        imageView.hidden = YES;
        [imageView.layer removeAllAnimations];
    }

    /* Turn back on any door open/door closed images that could have been hidden by the seatbelt view */
    for (UIImageView *imageView in self.currentlyShowingOpenDoorImages)
    {
        imageView.alpha = 1.0;

        [imageView.layer removeAllAnimations];
    }

    for (UIImageView *imageView in self.currentlyShowingClosedDoorImages)
    {
        imageView.alpha = 1.0;

        [imageView.layer removeAllAnimations];
    }

    /* Depending on drivers side of car, do all the door image state change stuff for each zone, one by one */
    [self handleDoorStatusChangeFrom:(BOOL)(self.previousDoorStatus & DF_BIT_MASK)
                                  to:(BOOL)(value & DF_BIT_MASK)
                             forZone:self.driversSide == DRIVER_LEFT ? ZONE_LF : ZONE_RF];

    [self handleDoorStatusChangeFrom:(BOOL)(self.previousDoorStatus & PF_BIT_MASK)
                                  to:(BOOL)(value & PF_BIT_MASK)
                             forZone:self.driversSide == DRIVER_LEFT ? ZONE_RF : ZONE_LF];

    [self handleDoorStatusChangeFrom:(BOOL)(self.previousDoorStatus & DR_BIT_MASK)
                                  to:(BOOL)(value & DR_BIT_MASK)
                             forZone:self.driversSide == DRIVER_LEFT ? ZONE_LR : ZONE_RR];

    [self handleDoorStatusChangeFrom:(BOOL)(self.previousDoorStatus & PR_BIT_MASK)
                                  to:(BOOL)(value & PR_BIT_MASK)
                             forZone:self.driversSide == DRIVER_LEFT ? ZONE_RR : ZONE_LR];

    /* If any of the values went from open to closed, briefly display the CLOSED INDICATOR (the green check-mark), then fade them all currently-
     * being-displayed-closed-indicators out. */
    if ((BOOL)(value & HOOD_BIT_MASK) && !(BOOL)(self.previousDoorStatus & HOOD_BIT_MASK))
    {
        [self.recentlyClosedIndicatorImages addObject:self.hoodClosedIndicatorImageView];
    }

    if ((BOOL)(value & TRUNK_BIT_MASK) && !(BOOL)(self.previousDoorStatus & TRUNK_BIT_MASK))
    {
        [self.recentlyClosedIndicatorImages addObject:self.trunkClosedIndicatorImageView];
    }

    /* Turn on the "closed-indicator" set of images we want to show. */
    for (UIImageView *imageView in self.recentlyClosedIndicatorImages)
    {
        imageView.hidden = NO;
        imageView.alpha  = 1.0;

        /* And turn off any pending animations so that they all fade together - Doesn't seem to be working. */
        [imageView.layer removeAllAnimations];
    }

    /* After a handful of seconds, fade out the closed-indicator images, and then remove them from the set, since we only really want to display them
     * when that particular door's state changes, and not every time any door's state changes. */
    [UIView animateWithDuration:FADE_OUT_ANIMATION_DURATION
                          delay:FADE_OUT_ANIMATION_DELAY
                        options:nil
                     animations:^{
                            for (UIImageView *imageView in self.recentlyClosedIndicatorImages)
                                imageView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self.recentlyClosedIndicatorImages removeAllObjects];
                     }];

    /* The actual door/hood/trunk OPEN images (the ones w red-Xs) don't fade after so many seconds, and neither do the door-closed images (just
     * the green indicators), so hide/show those appropriately. */
    self.hoodOpenIndicatorImageView.hidden  = (BOOL)(value & HOOD_BIT_MASK);
    self.trunkOpenIndicatorImageView.hidden = (BOOL)(value & TRUNK_BIT_MASK);

    self.previousDoorStatus = value;
}

- (void)handleHighBeamChange:(BOOL)value
{
    self.highBeamsImageView.hidden = !value;
}

- (void)handleLowBeamChange:(BOOL)value
{
    self.lowBeamsImageView.hidden = !value;
}

- (IBAction)resetInCaseOfFunnyState:(id)sender
{
    // TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
}

- (NSArray *)signalKeyPathsToObserve
{
    return @[kVehicleBreakPressureKeyPath,
             kVehicleThrottlePressureKeyPath,
             kVehicleDoorStatusKeyPath,
             kVehicleDriverWindowPositionKeyPath,
             kVehiclePassengerWindowPositionKeyPath,
             kVehicleRearDriverWindowPositionKeyPath,
             kVehicleRearPassengerWindowPositionKeyPath,
             kVehicleDriverSeatBeltBuckleStateKeyPath,
             kVehiclePassengerSeatBeltBuckleStateKeyPath,
             kVehicleBeltReminderSensorLRKeyPath,
             kVehicleBeltReminderSensorRRKeyPath,
             kVehicleLowBeamIndicationKeyPath,
             kVehicleMainBeamIndicationKeyPath];
}

- (void)registerObservers
{
    for (NSString *keyPath in [self signalKeyPathsToObserve])
    {
        DLog(@"Adding observer for: vehicle.%@", keyPath);

        /* Register both the signal objects themselves, as their type may change when we receive SIGNAL_DESCRIPTOR stuff back... */
        [self.vehicle addObserver:self
                       forKeyPath:keyPath
                          options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                          context:NULL];

        DLog(@"Adding observer for: vehicle.%@.eventAttributes", keyPath);

        /* And register the signal's attributes as well, since that's what's updated during events. */
        [[self.vehicle valueForKey:keyPath] addObserver:self
                                             forKeyPath:kVehicleSignalCurrentValueKeyPath
                                                options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                                context:NULL];
    }

    DLog(@"Adding observer for: vehicle.%@", kVehicleNumberDoorsKeyPath);
    [self.vehicle addObserver:self
                   forKeyPath:kVehicleNumberDoorsKeyPath
                      options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                      context:NULL];

    DLog(@"Adding observer for: vehicle.%@", kVehicleNumberWindowsKeyPath);
    [self.vehicle addObserver:self
                   forKeyPath:kVehicleNumberWindowsKeyPath
                      options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                      context:NULL];

    DLog(@"Adding observer for: vehicle.%@", kVehicleNumberSeatsKeyPath);
    [self.vehicle addObserver:self
                   forKeyPath:kVehicleNumberSeatsKeyPath
                      options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                      context:NULL];

    DLog(@"Adding observer for: vehicle.%@", kVehicleDriverSideKeyPath);
    [self.vehicle addObserver:self
                   forKeyPath:kVehicleDriverSideKeyPath
                      options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                      context:NULL];
}

- (void)removeSelfAsObserverFromObject:(NSObject *)object keyPath:(NSString *)keyPath
{
    /* Just in case we screwed up KVO, catch that shit. */
    @try
    {
        DLog(@"Removing observer for: %@.%@", [object class], keyPath);
        [object removeObserver:self
                    forKeyPath:keyPath];
    }
    @catch (NSException *exception)
    {
        /* Maybe the original signal was null... */
        DLog(@"EXCEPTION THROWN: %@", exception.description);
    }

}

- (void)unregisterObservers
{
    for (NSString *keyPath in [self signalKeyPathsToObserve])
    {
        [self removeSelfAsObserverFromObject:self.vehicle keyPath:keyPath];

        DLog(@"Removing observer for: vehicle.%@.eventAttributes", keyPath);
        [self removeSelfAsObserverFromObject:[self.vehicle valueForKey:keyPath] keyPath:kVehicleSignalCurrentValueKeyPath];
    }

    [self removeSelfAsObserverFromObject:self.vehicle keyPath:kVehicleNumberDoorsKeyPath];
    [self removeSelfAsObserverFromObject:self.vehicle keyPath:kVehicleNumberWindowsKeyPath];
    [self removeSelfAsObserverFromObject:self.vehicle keyPath:kVehicleNumberSeatsKeyPath];
    [self removeSelfAsObserverFromObject:self.vehicle keyPath:kVehicleDriverSideKeyPath];
}

- (void)transferEventAttributeObserverFromOldSignal:(Signal *)oldSignal toNewSignal:(Signal *)newSignal
{
    DLog(@"");

    @try
    {
        /* Start observing the new signal's attributes (first, in case exception is thrown below)... */
        [newSignal addObserver:self
                    forKeyPath:kVehicleSignalCurrentValueKeyPath
                       options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                context:NULL];

        /* ... and stop observing the old signal's attributes. */
        [oldSignal removeObserver:self
                       forKeyPath:kVehicleSignalCurrentValueKeyPath];
    }
    @catch (NSException *exception)
    {
        /* Maybe the original signal was null or we messed up KVO or something... */
        DLog(@"EXCEPTION THROWN: %@", exception.description);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    DLog(@"Key: %@, old val: %@, new val: %@", keyPath, change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey]);

    if ([[self signalKeyPathsToObserve] containsObject:keyPath])
    {
        [self transferEventAttributeObserverFromOldSignal:change[NSKeyValueChangeOldKey]
                                              toNewSignal:change[NSKeyValueChangeNewKey]];

    }
    else if ([keyPath isEqualToString:kVehicleNumberDoorsKeyPath])
    {

    }
    else if ([keyPath isEqualToString:kVehicleNumberWindowsKeyPath])
    {

    }
    else if ([keyPath isEqualToString:kVehicleNumberSeatsKeyPath])
    {

    }
    else if ([keyPath isEqualToString:kVehicleDriverSideKeyPath])
    {
        NSString *value = change[NSKeyValueChangeNewKey];
        if ([value isEqualToString:@"LEFT"])       self.driversSide = DRIVER_LEFT;
        else if ([value isEqualToString:@"RIGHT"]) self.driversSide = DRIVER_RIGHT;
        else                                       self.driversSide = DRIVER_UNKNOWN; // TODO: MUST TEST THIS!!!!!!
    }
    else if ([keyPath isEqualToString:kVehicleSignalCurrentValueKeyPath])
    {
        if (change[NSKeyValueChangeNewKey] == [NSNull null]) return;

        if (object == self.vehicle.throttlePressure)
        {
            self.testLabel.text = [NSString stringWithFormat:@"%d", [change[NSKeyValueChangeNewKey] integerValue]];
            // TODO: Update pressure
        }
        else if (object == self.vehicle.doorStatus)
        {
            [self handleDoorStatusChange:[change[NSKeyValueChangeNewKey] integerValue]];
        }
        else if (object == self.vehicle.driverWindowPosition)
        {
            if (self.driversSide == DRIVER_LEFT)
                [self handleWindowPositionChange:[change[NSKeyValueChangeNewKey] integerValue] zone:ZONE_LF];
            else if (self.driversSide == DRIVER_RIGHT)
                [self handleWindowPositionChange:[change[NSKeyValueChangeNewKey] integerValue] zone:ZONE_RF];
        }
        else if (object == self.vehicle.passengerWindowPosition)
        {
            if (self.driversSide == DRIVER_LEFT)
                [self handleWindowPositionChange:[change[NSKeyValueChangeNewKey] integerValue] zone:ZONE_RF];
            else if (self.driversSide == DRIVER_RIGHT)
                [self handleWindowPositionChange:[change[NSKeyValueChangeNewKey] integerValue] zone:ZONE_LF];
        }
        else if (object == self.vehicle.rearDriverWindowPosition)
        {
            if (self.driversSide == DRIVER_LEFT)
                [self handleWindowPositionChange:[change[NSKeyValueChangeNewKey] integerValue] zone:ZONE_LR];
            else if (self.driversSide == DRIVER_RIGHT)
                [self handleWindowPositionChange:[change[NSKeyValueChangeNewKey] integerValue] zone:ZONE_RR];
        }
        else if (object == self.vehicle.rearPassengerWindowPosition)
        {
            if (self.driversSide == DRIVER_LEFT)
                [self handleWindowPositionChange:[change[NSKeyValueChangeNewKey] integerValue] zone:ZONE_RR];
            else if (self.driversSide == DRIVER_RIGHT)
                [self handleWindowPositionChange:[change[NSKeyValueChangeNewKey] integerValue] zone:ZONE_LR];
        }
        else if (object == self.vehicle.driverSeatBeltBuckleState)
        {
            if (self.driversSide == DRIVER_LEFT)
                [self handleBuckleStateChange:[change[NSKeyValueChangeNewKey] boolValue] zone:ZONE_LF];
            else if (self.driversSide == DRIVER_RIGHT)
                [self handleBuckleStateChange:[change[NSKeyValueChangeNewKey] boolValue] zone:ZONE_RF];
        }
        else if (object == self.vehicle.passengerSeatBeltBuckleState)
        {
            if (self.driversSide == DRIVER_LEFT)
                [self handleBuckleStateChange:[change[NSKeyValueChangeNewKey] boolValue] zone:ZONE_RF];
            else if (self.driversSide == DRIVER_RIGHT)
                [self handleBuckleStateChange:[change[NSKeyValueChangeNewKey] boolValue] zone:ZONE_LF];
        }
        else if (object == self.vehicle.beltReminderSensorLR)
        {
            [self handleBuckleStateChange:![change[NSKeyValueChangeNewKey] boolValue] zone:ZONE_LR];
        }
        else if (object == self.vehicle.beltReminderSensorRR)
        {
            [self handleBuckleStateChange:![change[NSKeyValueChangeNewKey] boolValue] zone:ZONE_RR];
        }
        else if (object == self.vehicle.lowBeamIndication)
        {
            [self handleLowBeamChange:[change[NSKeyValueChangeNewKey] boolValue]];
        }
        else if (object == self.vehicle.mainBeamIndication)
        {
            [self handleHighBeamChange:[change[NSKeyValueChangeNewKey] boolValue]];
        }
    }
}
@end
