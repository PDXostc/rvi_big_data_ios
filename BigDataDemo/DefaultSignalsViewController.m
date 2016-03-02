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
@end

@implementation DefaultSignalsViewController
{

}

- (void)viewDidLoad
{
    DLog(@"");
    [super viewDidLoad];

    self.vehicle = [VehicleManager vehicle];
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
//    [self.vehicle addObserver:self
//                   forKeyPath:kVehicleLocationKeyPath
//                      options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
//                      context:NULL];
//
//    [self.vehicle addObserver:self
//                   forKeyPath:kVehicleBearingKeyPath
//                      options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
//                      context:NULL];
    // TODO: On value change as well
}

- (void)unregisterObservers
{
//    [self.vehicle removeObserver:self
//                      forKeyPath:kVehicleLocationKeyPath];
//
//    [self.vehicle removeObserver:self
//                      forKeyPath:kVehicleBearingKeyPath];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    DLog(@"Key: %@, old val: %@, new val: %@", keyPath, change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey]);

    if ([keyPath isEqualToString:kVehicleLocationKeyPath])
    {

    }
    else if ([keyPath isEqualToString:kVehicleBearingKeyPath])
    {

    }
}

@end
