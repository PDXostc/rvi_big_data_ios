/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 * Copyright (c) 2016 Jaguar Land Rover.
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 *
 * File:    MapDisplayViewController.m
 * Project: BigDataDemo
 *
 * Created by Lilli Szafranski on 2/23/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "MapDisplayViewController.h"
#import "Util.h"
#import "VehicleManager.h"
#import "Vehicle.h"

@interface MapDisplayViewController ()
@property (nonatomic, weak) Vehicle *vehicle;
@end

@implementation MapDisplayViewController
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

- (void)registerObservers
{
    /* Register both the signal objects themselves, as their type may change... */
    [self.vehicle addObserver:self
                   forKeyPath:kVehicleLocationKeyPath
                      options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                      context:NULL];

    [self.vehicle addObserver:self
                   forKeyPath:kVehicleBearingKeyPath
                      options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                      context:NULL];

    /* And register the signal's attributes as well, since that's what's updated. */
    [self.vehicle.location addObserver:self
                            forKeyPath:kVehicleSignalCurrentValueKeyPath
                               options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                               context:NULL];

    [self.vehicle.bearing addObserver:self
                           forKeyPath:kVehicleSignalCurrentValueKeyPath
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
    [self removeSelfAsObserverFromObject:self.vehicle
                                 keyPath:kVehicleLocationKeyPath];

    [self removeSelfAsObserverFromObject:self.vehicle
                                 keyPath:kVehicleBearingKeyPath];

    [self removeSelfAsObserverFromObject:self.vehicle.location
                                 keyPath:kVehicleSignalCurrentValueKeyPath];

    [self removeSelfAsObserverFromObject:self.vehicle.bearing
                                 keyPath:kVehicleSignalCurrentValueKeyPath];
}

- (void)transferEventAttributeObserverFromOldSignal:(Signal *)oldSignal toNewSignal:(Signal *)newSignal
{
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

    if ([keyPath isEqualToString:kVehicleLocationKeyPath] || [keyPath isEqualToString:kVehicleBearingKeyPath])
    {
        [self transferEventAttributeObserverFromOldSignal:change[NSKeyValueChangeOldKey]
                                              toNewSignal:change[NSKeyValueChangeNewKey]];

    }
    else if ([keyPath isEqualToString:kVehicleSignalCurrentValueKeyPath])
    {
        if (object == self.vehicle.location)
        {
            // TODO: Update map
        }
        else if (object == self.vehicle.bearing)
        {
            // TODO: Update compass
        }
    }
}
@end
