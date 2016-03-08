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

@interface DefaultSignalsViewController ()
@property (nonatomic, weak) Vehicle *vehicle;
@property (nonatomic, strong) IBOutlet UILabel *testLabel;

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

- (NSArray *)signalKeyPathsToObserve
{
    return @[kVehicleBreakPressureKeyPath,
             kVehicleThrottlePressureKeyPath,
             kVehicleLeftFrontKeyPath,
             kVehicleRightFrontKeyPath,
             kVehicleLeftRearKeyPath,
             kVehicleMiddleRearKeyPath,
             kVehicleRightRearKeyPath];
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

    }
    else if ([keyPath isEqualToString:kVehicleSignalCurrentValueKeyPath])
    {
        if (object == self.vehicle.throttlePressure)
        {
            self.testLabel.text = [NSString stringWithFormat:@"%d", [change[NSKeyValueChangeNewKey] integerValue]];
            // TODO: Update pressure
        }
        else if (object == self.vehicle.breakPressure)
        {
            // TODO: Update pressure
        }
        else if (object == self.vehicle.leftFront)
        {
            // TODO: Update seat belt
        }
        else if (object == self.vehicle.rightFront)
        {
            // TODO: Update seat belt
        }
        else if (object == self.vehicle.leftRear)
        {
            // TODO: Update seat belt
        }
        else if (object == self.vehicle.middleRear)
        {
            // TODO: Update seat belt
        }
        else if (object == self.vehicle.rightRear)
        {
            // TODO: Update seat belt
        }
    }
}

@end
