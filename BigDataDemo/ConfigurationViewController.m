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

@interface ConfigurationViewController ()
@property (nonatomic, weak) IBOutlet UITextField *vehicleIdTextField;
@property (nonatomic, weak) IBOutlet UITextField *serverUrlTextField;
@end

@implementation ConfigurationViewController
{

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


    if ([ConfigurationDataManager getVehicleId])
        [self.vehicleIdTextField setText:[ConfigurationDataManager getVehicleId]];
    else
        [self.vehicleIdTextField setText:@""];

    if ([ConfigurationDataManager getServerUrl])
        [self.serverUrlTextField setText:[ConfigurationDataManager getServerUrl]];
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
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.vehicleIdTextField)
        [ConfigurationDataManager setVehicleId:self.vehicleIdTextField.text];
    else if (textField == self.serverUrlTextField)
        [ConfigurationDataManager setServerUrl:self.serverUrlTextField.text];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.vehicleIdTextField)
        [self.serverUrlTextField becomeFirstResponder];
    else if (textField == self.serverUrlTextField)
        [self.serverUrlTextField resignFirstResponder];

    return YES;
}

@end
