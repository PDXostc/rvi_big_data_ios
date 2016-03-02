/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 * Copyright (c) 2016 Jaguar Land Rover.
 *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 *
 * File:    ConfigurationViewController.m
 * Project: BigDataDemo
 *
 * Created by Lilli Szafranski on 2/23/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "ConfigurationViewController.h"
#import "Util.h"
#import "ConfigurationDataManager.h"
#import "Vehicle.h"
#import "VehicleManager.h"

@interface UITextField (BorderStuff)
- (void)addRedBorder;
- (void)removeRedBorder;
@end

@implementation UITextField (BorderStuff)
- (CALayer *)borderLayer
{   /* Probs not the most efficient to loop through on every character change, but whatevs. */
    for (CALayer *layer in [[self layer] sublayers])
        if ([layer.name isEqualToString:@"border_layer"])
            return layer;

    CALayer *borderLayer = [CALayer layer];

    borderLayer.frame = self.bounds;
    borderLayer.backgroundColor = [UIColor clearColor].CGColor;
    borderLayer.borderColor = [UIColor redColor].CGColor;
    borderLayer.cornerRadius = 5.0f;
    borderLayer.borderWidth = 2.0f;

    borderLayer.name = @"border_layer";

    [[self layer] addSublayer:borderLayer];

    return borderLayer;
}

- (void)addRedBorder
{
    [[self borderLayer] setHidden:NO];
}

- (void)removeRedBorder
{
    [[self borderLayer] setHidden:YES];
}
@end


@interface ConfigurationViewController ()
@property (nonatomic, weak) IBOutlet UITextField *vehicleIdTextField;
@property (nonatomic, weak) IBOutlet UITextField *serverUrlTextField;
@property (nonatomic, weak) IBOutlet UITextField *serverPortTextField;
@property (nonatomic, weak) Vehicle *vehicle;
@end

@implementation ConfigurationViewController
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

    UIToolbar* numberToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];

    numberToolbar.items = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                            [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];

    [numberToolbar sizeToFit];

    self.serverPortTextField.inputAccessoryView = numberToolbar;

    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    [self.vehicleIdTextField resignFirstResponder];
    [self.serverUrlTextField resignFirstResponder];
    [self.serverPortTextField resignFirstResponder];
}

- (void)doneWithNumberPad
{
    [self.serverPortTextField resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    DLog(@"");
    [super viewWillAppear:animated];

    [self registerObservers];

    if ([ConfigurationDataManager getVehicleId])
        [self.vehicleIdTextField setText:[ConfigurationDataManager getVehicleId]];
    else
        [self.vehicleIdTextField setText:@""];

    if ([ConfigurationDataManager getServerUrl])
        [self.serverUrlTextField setText:[ConfigurationDataManager getServerUrl]];
    else
        [self.serverUrlTextField setText:@""];

    if ([ConfigurationDataManager getServerPort])
        [self.serverPortTextField setText:[ConfigurationDataManager getServerPort]];
    else
        [self.serverUrlTextField setText:@""];

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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{

}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField removeRedBorder];

    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.vehicleIdTextField)
        [ConfigurationDataManager setVehicleId:self.vehicleIdTextField.text];
    else if (textField == self.serverUrlTextField)
        [ConfigurationDataManager setServerUrl:self.serverUrlTextField.text];
    else if (textField == self.serverPortTextField)
        [ConfigurationDataManager setServerPort:self.serverPortTextField.text];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [textField addRedBorder];

    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [textField addRedBorder];

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.vehicleIdTextField)
        [self.serverUrlTextField becomeFirstResponder];
    else if (textField == self.serverUrlTextField)
        [self.serverPortTextField becomeFirstResponder];
    else if (textField == self.serverPortTextField)
        [self.serverPortTextField resignFirstResponder];

    return YES;
}

- (void)registerObservers
{
    [self.vehicle addObserver:self
                   forKeyPath:kVehicleVehicleStatusKeyPath
                      options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                      context:NULL];
}

- (void)unregisterObservers
{
    [self.vehicle removeObserver:self
                      forKeyPath:kVehicleVehicleStatusKeyPath];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    DLog(@"Key: %@, old val: %@, new val: %@", keyPath, change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey]);

    if ([keyPath isEqualToString:kVehicleSignalEventAttributeKeyPath])
    {

    }
}


@end
