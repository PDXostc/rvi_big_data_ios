/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * 
 * Copyright (c) 2016 Jaguar Land Rover. *
 * This program is licensed under the terms and conditions of the
 * Mozilla Public License, version 2.0. The full text of the 
 * Mozilla Public License is at https://www.mozilla.org/MPL/2.0/
 * 
 * File:    AllSignalsViewController.m
 * Project: BigDataDemo
 * 
 * Created by Lilli Szafranski on 2/23/16.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#import "AllSignalsViewController.h"
#import "Util.h"
#import "SignalManager.h"
#import "ConfigurationDataManager.h"


@interface AllSignalsViewController () <SignalManagerDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong)          NSArray     *allSignals;
@end

@implementation AllSignalsViewController
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

    [SignalManager setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    DLog(@"");
    [super viewDidAppear:animated];

    [SignalManager getAllSignalsForVehicle:[ConfigurationDataManager getVehicleId]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    DLog(@"");
    [super viewWillDisappear:animated];

    [SignalManager setDelegate:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    DLog(@"");
    [super viewDidDisappear:animated];
}

- (void)signalManagerDidGetAllSignals:(NSArray *)signals forVehicle:(NSString *)vehicleId
{
    self.allSignals = [signals copy];

    [self.tableView reloadData];
}

- (void)signalManagerDidReceiveEventForVehicle:(NSString *)vehicleId signalName:(NSString *)signals attributes:(NSDictionary *)attributes
{

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allSignals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"myCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    cell.textLabel.text = self.allSignals[(NSUInteger)indexPath.row];

    return cell;
}
@end
