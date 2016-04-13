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

@property (nonatomic, strong) NSMutableSet    *currentSeatBeltIndicatorImages;
@property (nonatomic, strong) NSMutableSet    *doorTrunkHoodClosedIndicatorImages;
@property (nonatomic, strong) NSMutableSet    *openDoorImages;
//@property (nonatomic, strong) NSMutableSet    *extendingOutExteriorIndicatorImages;

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

    [self drawThrottlePressureView:self.throttlePressureView];
    [self drawSteeringAngleView:self.steeringAngleView];
    [self drawCompositeCarView:self.compositeCarView];

    self.currentSeatBeltIndicatorImages = [NSMutableSet setWithObjects:
                                                         self.vehicleOutlineInteriorImageView,
                                                         self.lfSeatbeltOffIndicatorImageView,
                                                         self.rfSeatbeltOffIndicatorImageView,
                                                         self.lrSeatbeltOffIndicatorImageView,
                                                         self.rrSeatbeltOffIndicatorImageView,
                                                         nil];

    self.doorTrunkHoodClosedIndicatorImages = [NSMutableSet set];
    self.openDoorImages                     = [NSMutableSet set];
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
    /* Get the on/off buckle images for this seat using the string zone and key/value encoding */
    NSString    *stringForZone = [self stringForZone:zone];
    UIImageView *seatbeltOffIndicatorImageView = [self valueForKey:[NSString stringWithFormat:@"%@SeatbeltOffIndicatorImageView", stringForZone]];
    UIImageView *seatbeltOnIndicatorImageView = [self valueForKey:[NSString stringWithFormat:@"%@SeatbeltOnIndicatorImageView", stringForZone]];

    /* Remove the current indicator, and toggle it with it's opposite, hiding the one we don't want to show, and adding the one we do want to show
     * to the set of interior images. That way it will fade out/get hidden when the interior images need to be. */
    if (value) /* The person in the seat is buckled */
    {
        [self.currentSeatBeltIndicatorImages addObject:seatbeltOnIndicatorImageView];
        [self.currentSeatBeltIndicatorImages removeObject:seatbeltOffIndicatorImageView];

        seatbeltOffIndicatorImageView.hidden = YES;
    }
    else
    {
        [self.currentSeatBeltIndicatorImages addObject:seatbeltOffIndicatorImageView];
        [self.currentSeatBeltIndicatorImages removeObject:seatbeltOnIndicatorImageView];

        seatbeltOnIndicatorImageView.hidden = YES;
    }

    /* Turn off any exterior images that may be showing. */
    for (UIImageView *imageView in self.extendingOutExteriorIndicatorImages)
    {
        imageView.hidden = YES;
    }

    /* Turn on the interior set of images we want to show. */
    for (UIImageView *imageView in self.currentSeatBeltIndicatorImages)
    {
        imageView.hidden = NO;
        imageView.alpha  = 1.0;
    }

    [UIView animateWithDuration:FADE_OUT_ANIMATION_DURATION
                          delay:FADE_OUT_ANIMATION_DELAY
                        options:nil
                     animations:^{
                            for (UIImageView *imageView in self.currentSeatBeltIndicatorImages)
                                imageView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         for (UIImageView *imageView in self.openDoorImages)
                             imageView.hidden = NO;
                     }];

}

- (void)handleWindowPositionChange:(NSInteger)newPosition maxValue:(NSInteger)maxPosition zone:(Zone)zone
{

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

- (void)handleDoorStatusChange:(NSInteger)value
{
    /* Turn on the interior set of images that might be showing. */
    for (UIImageView *imageView in self.currentSeatBeltIndicatorImages)
    {
        imageView.hidden = YES;
    }

    /* If any of the values went from open to closed, briefly display the CLOSED INDICATOR (the green check-mark), then fade them all currently-
     * being-displayed-closed-indicators out. */
    if ((BOOL)(value & DF_BIT_MASK) && !(BOOL)(self.previousDoorStatus & DF_BIT_MASK))
    {
        if (self.driversSide == DRIVER_LEFT)
            [self.doorTrunkHoodClosedIndicatorImages addObject:self.lfDoorClosedIndicatorImageView];
        else if (self.driversSide == DRIVER_RIGHT)
            [self.doorTrunkHoodClosedIndicatorImages addObject:self.rfDoorClosedIndicatorImageView];
    }

    if ((BOOL)(value & PF_BIT_MASK) && !(BOOL)(self.previousDoorStatus & PF_BIT_MASK))
    {
        if (self.driversSide == DRIVER_LEFT)
            [self.doorTrunkHoodClosedIndicatorImages addObject:self.rfDoorClosedIndicatorImageView];
        else if (self.driversSide == DRIVER_RIGHT)
            [self.doorTrunkHoodClosedIndicatorImages addObject:self.lfDoorClosedIndicatorImageView];
    }

    if ((BOOL)(value & DR_BIT_MASK) && !(BOOL)(self.previousDoorStatus & DR_BIT_MASK))
    {
        if (self.driversSide == DRIVER_LEFT)
            [self.doorTrunkHoodClosedIndicatorImages addObject:self.lrDoorClosedIndicatorImageView];
        else if (self.driversSide == DRIVER_RIGHT)
            [self.doorTrunkHoodClosedIndicatorImages addObject:self.rrDoorClosedIndicatorImageView];
    }

    if ((BOOL)(value & PR_BIT_MASK) && !(BOOL)(self.previousDoorStatus & PR_BIT_MASK))
    {
        if (self.driversSide == DRIVER_LEFT)
            [self.doorTrunkHoodClosedIndicatorImages addObject:self.rrDoorClosedIndicatorImageView];
        else if (self.driversSide == DRIVER_RIGHT)
            [self.doorTrunkHoodClosedIndicatorImages addObject:self.lrDoorClosedIndicatorImageView];
    }

    if ((BOOL)(value & HOOD_BIT_MASK) && !(BOOL)(self.previousDoorStatus & HOOD_BIT_MASK))
    {
        [self.doorTrunkHoodClosedIndicatorImages addObject:self.hoodClosedIndicatorImageView];
    }

    if ((BOOL)(value & TRUNK_BIT_MASK) && !(BOOL)(self.previousDoorStatus & TRUNK_BIT_MASK))
    {
        [self.doorTrunkHoodClosedIndicatorImages addObject:self.trunkClosedIndicatorImageView];
    }

    /* Turn on the "closed-indicator" set of images we want to show. */
    for (UIImageView *imageView in self.doorTrunkHoodClosedIndicatorImages)
    {
        imageView.hidden = NO;
        imageView.alpha  = 1.0;
    }

    /* After a handful of seconds, fade out the closed-indicator images, and then remove them from the set, since we only really want to display them
     * when that particular door's state changes, and not every time any door's state changes. */
    [UIView animateWithDuration:FADE_OUT_ANIMATION_DURATION
                          delay:FADE_OUT_ANIMATION_DELAY
                        options:nil
                     animations:^{
                            for (UIImageView *imageView in self.doorTrunkHoodClosedIndicatorImages)
                                imageView.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self.doorTrunkHoodClosedIndicatorImages removeAllObjects];
                     }];

    /* The actual door/hood/trunk OPEN images (the ones w red-Xs) don't fade after so many seconds, and neither do the door-closed images (just
     * the green indicators), so hide/show those appropriately. */
    if (self.driversSide == DRIVER_LEFT)
    {
        /* Also, hold on to any open door images, as we will need to re-show them after they disappear for the display of interior images, and we need
         * to fade them in/out when displaying the window indicators */
        if (!(BOOL)(value & DF_BIT_MASK))
            [self.openDoorImages addObject:self.lfDoorOpenImageView];
        else
            [self.openDoorImages removeObject:self.lfDoorOpenImageView];

        self.lfDoorOpenImageView.hidden   =  (BOOL)(value & DF_BIT_MASK);
        self.lfDoorClosedImageView.hidden = !(BOOL)(value & DF_BIT_MASK);

        if (!(BOOL)(value & PF_BIT_MASK))
            [self.openDoorImages addObject:self.rfDoorOpenImageView];
        else
            [self.openDoorImages removeObject:self.rfDoorOpenImageView];

        self.rfDoorOpenImageView.hidden   =  (BOOL)(value & PF_BIT_MASK);
        self.rfDoorClosedImageView.hidden = !(BOOL)(value & PF_BIT_MASK);

        if (!(BOOL)(value & DR_BIT_MASK))
            [self.openDoorImages addObject:self.lrDoorOpenImageView];
        else
            [self.openDoorImages removeObject:self.lrDoorOpenImageView];

        self.lrDoorOpenImageView.hidden   =  (BOOL)(value & DR_BIT_MASK);
        self.lrDoorClosedImageView.hidden = !(BOOL)(value & DR_BIT_MASK);

        if (!(BOOL)(value & PR_BIT_MASK))
            [self.openDoorImages addObject:self.rrDoorOpenImageView];
        else
            [self.openDoorImages removeObject:self.rrDoorOpenImageView];

        self.rrDoorOpenImageView.hidden   =  (BOOL)(value & PR_BIT_MASK);
        self.rrDoorClosedImageView.hidden = !(BOOL)(value & PR_BIT_MASK);
    }
    else if (self.driversSide == DRIVER_RIGHT)
    {
        if (!(BOOL)(value & DF_BIT_MASK))
            [self.openDoorImages addObject:self.rfDoorOpenImageView];
        else
            [self.openDoorImages removeObject:self.rfDoorOpenImageView];

        self.rfDoorOpenImageView.hidden   =  (BOOL)(value & DF_BIT_MASK);
        self.rfDoorClosedImageView.hidden = !(BOOL)(value & DF_BIT_MASK);

        if (!(BOOL)(value & PF_BIT_MASK))
            [self.openDoorImages addObject:self.lfDoorOpenImageView];
        else
            [self.openDoorImages removeObject:self.lfDoorOpenImageView];

        self.lfDoorOpenImageView.hidden   =  (BOOL)(value & PF_BIT_MASK);
        self.lfDoorClosedImageView.hidden = !(BOOL)(value & PF_BIT_MASK);

        if (!(BOOL)(value & DR_BIT_MASK))
            [self.openDoorImages addObject:self.rrDoorOpenImageView];
        else
            [self.openDoorImages removeObject:self.rrDoorOpenImageView];

        self.rrDoorOpenImageView.hidden   =  (BOOL)(value & DR_BIT_MASK);
        self.rrDoorClosedImageView.hidden = !(BOOL)(value & DR_BIT_MASK);

        if (!(BOOL)(value & PR_BIT_MASK))
            [self.openDoorImages addObject:self.lrDoorOpenImageView];
        else
            [self.openDoorImages removeObject:self.lrDoorOpenImageView];

        self.lrDoorOpenImageView.hidden   =  (BOOL)(value & PR_BIT_MASK);
        self.lrDoorClosedImageView.hidden = !(BOOL)(value & PR_BIT_MASK);
    }

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
                [self handleWindowPositionChange:[change[NSKeyValueChangeNewKey] integerValue] maxValue:((Signal *)object).highVal zone:ZONE_LF];
            else if (self.driversSide == DRIVER_RIGHT)
                [self handleWindowPositionChange:[change[NSKeyValueChangeNewKey] integerValue] maxValue:((Signal *)object).highVal zone:ZONE_RF];
        }
        else if (object == self.vehicle.passengerWindowPosition)
        {
            if (self.driversSide == DRIVER_LEFT)
                [self handleWindowPositionChange:[change[NSKeyValueChangeNewKey] integerValue] maxValue:((Signal *)object).highVal zone:ZONE_RF];
            else if (self.driversSide == DRIVER_RIGHT)
                [self handleWindowPositionChange:[change[NSKeyValueChangeNewKey] integerValue] maxValue:((Signal *)object).highVal zone:ZONE_LF];
        }
        else if (object == self.vehicle.rearDriverWindowPosition)
        {
            if (self.driversSide == DRIVER_LEFT)
                [self handleWindowPositionChange:[change[NSKeyValueChangeNewKey] integerValue] maxValue:((Signal *)object).highVal zone:ZONE_LR];
            else if (self.driversSide == DRIVER_RIGHT)
                [self handleWindowPositionChange:[change[NSKeyValueChangeNewKey] integerValue] maxValue:((Signal *)object).highVal zone:ZONE_RR];
        }
        else if (object == self.vehicle.rearPassengerWindowPosition)
        {
            if (self.driversSide == DRIVER_LEFT)
                [self handleWindowPositionChange:[change[NSKeyValueChangeNewKey] integerValue] maxValue:((Signal *)object).highVal zone:ZONE_RR];
            else if (self.driversSide == DRIVER_RIGHT)
                [self handleWindowPositionChange:[change[NSKeyValueChangeNewKey] integerValue] maxValue:((Signal *)object).highVal zone:ZONE_LR];
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
