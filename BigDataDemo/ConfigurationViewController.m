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
#import "BackendServerManager.h"

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


typedef enum
{
    CONNECTING,
    CONNECTED,
    DISCONNECTED,
} ServerStatus;


@interface ConfigurationViewController ()
@property (nonatomic, weak) IBOutlet UITextField *vehicleIdTextField;
@property (nonatomic, weak) IBOutlet UITextField *serverUrlTextField;
@property (nonatomic, weak) IBOutlet UITextField *serverPortTextField;
@property (nonatomic, weak) IBOutlet UILabel     *statusLabel;
@property (nonatomic, weak) IBOutlet UIButton    *reconnectButton;
@property (nonatomic, weak) IBOutlet UIButton    *clearCacheButton;

@property (nonatomic, weak) Vehicle *vehicle;
@property (nonatomic)       ServerStatus assumedServerStatus;
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

    numberToolbar.items = @[[[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(next)],
                            [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
            [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)]];

    [numberToolbar sizeToFit];

    self.vehicleIdTextField.inputAccessoryView  = numberToolbar;
    self.serverUrlTextField.inputAccessoryView  = numberToolbar;
    self.serverPortTextField.inputAccessoryView = numberToolbar;

    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(done:)];
    [self.view addGestureRecognizer:singleFingerTap];

    self.assumedServerStatus = [BackendServerManager isConnected] ? CONNECTED : DISCONNECTED;

    [self setLabelForServerStatus:self.assumedServerStatus vehicleStatus:self.vehicle.vehicleStatus];
}

- (void)done:(UITapGestureRecognizer *)recognizer
{
    [self.vehicleIdTextField resignFirstResponder];
    [self.serverUrlTextField resignFirstResponder];
    [self.serverPortTextField resignFirstResponder];
}

- (void)next
{
    if ([self.vehicleIdTextField isFirstResponder])
        [self.serverUrlTextField becomeFirstResponder];
    else if ([self.serverUrlTextField isFirstResponder])
        [self.serverPortTextField becomeFirstResponder];
    else if ([self.serverPortTextField isFirstResponder])
        [self.vehicleIdTextField becomeFirstResponder];
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

//    if (textField != self.vehicleIdTextField)
//    {
//        self.assumedServerStatus = CONNECTING;
//        [self setLabelForServerStatus:self.assumedServerStatus vehicleStatus:self.vehicle.vehicleStatus];
//    }
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
    [self next];

    return YES;
}

- (IBAction)reconnectButtonClicked:(id)sender
{
//    self.assumedServerStatus = CONNECTING;
//    [self setLabelForServerStatus:self.assumedServerStatus vehicleStatus:self.vehicle.vehicleStatus];
    [BackendServerManager restart];
}

- (IBAction)clearCacheButtonPressed:(id)sender
{

}

- (void)registerObservers
{
    [self.vehicle addObserver:self
                   forKeyPath:kVehicleVehicleStatusKeyPath
                      options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                      context:NULL];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backendServerWillConnect:)
                                                 name:kBackendServerWillConnectNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backendServerDidConnect:)
                                                 name:kBackendServerDidConnectNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backendServerDidDisconnect:)
                                                 name:kBackendServerDidDisconnectNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backendServerDidDisconnect:)
                                                 name:kBackendServerDidFailToConnectNotification
                                               object:nil];

}

- (void)setLabelForServerStatus:(ServerStatus)serverStatus vehicleStatus:(VehicleStatus)vehicleStatus
{
    NSMutableString *string = [NSMutableString stringWithString:@"Server status: "];

    switch (serverStatus)
    {
        case CONNECTING:
            [string appendString:@"Connecting\n"];
            break;
        case CONNECTED:
            [string appendString:@"Connected\n"];
            break;
        case DISCONNECTED:
            [string appendString:@"Disconnected\n"];
            break;
    }

    [string appendString:@"Vehicle status: "];
    switch (vehicleStatus)
    {
        case VEHICLE_STATUS_UNKNOWN:
            [string appendString:@"Unknown"];
            break;
        case VEHICLE_STATUS_CONNECTED:
            [string appendString:@"Connected"];
            break;
        case VEHICLE_STATUS_NOT_CONNECTED:
            [string appendString:@"Not connected"];
            break;
        case VEHICLE_STATUS_INVALID_ID:
            [string appendString:@"Invalid ID"];
            break;
    }

    self.statusLabel.text = string;
}

- (void)unregisterObservers
{
    /* Just in case we screwed up KVO, catch that shit. */
    @try
    {
        [self.vehicle removeObserver:self
                          forKeyPath:kVehicleVehicleStatusKeyPath];
    }
    @catch (NSException *exception)
    {
        /* Maybe the original signal was null... */
        DLog(@"EXCEPTION THROWN: %@", exception.description);
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    DLog(@"Key: %@, old val: %@, new val: %@", keyPath, change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey]);

    if ([keyPath isEqualToString:kVehicleVehicleStatusKeyPath])
    {
        VehicleStatus value;
        [change[NSKeyValueChangeNewKey] getValue:&value];
        [self setLabelForServerStatus:self.assumedServerStatus vehicleStatus:value];
    }
}

- (void)backendServerWillConnect:(id)backendServerWillConnect
{
    DLog(@"");

    [self setAssumedServerStatus:CONNECTING];
    [self setLabelForServerStatus:self.assumedServerStatus vehicleStatus:self.vehicle.vehicleStatus];
}

- (void)backendServerDidConnect:(NSNotification *)notification
{
    DLog(@"");

    [self setAssumedServerStatus:CONNECTED];
    [self setLabelForServerStatus:self.assumedServerStatus vehicleStatus:self.vehicle.vehicleStatus];
}

- (void)backendServerDidDisconnect:(NSNotification *)notification
{
    DLog(@"");

    [self setAssumedServerStatus:DISCONNECTED];
    [self setLabelForServerStatus:self.assumedServerStatus vehicleStatus:self.vehicle.vehicleStatus];
}

@end
