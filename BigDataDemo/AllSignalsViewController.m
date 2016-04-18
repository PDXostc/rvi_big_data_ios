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
#import "Signal.h"
#import "ServerPacket.h"
#import "AllSignalsViewController+CellDrawing.h"
#import "VehicleManager.h"

#define key(vehicleId, signalName) [NSString stringWithFormat:@"%@:%@", vehicleId, signalName]
#define MAX_CACHED 7

@implementation SelectedCellData
- (instancetype)initWithSignalName:(NSString *)signalName vehicleId:(NSString *)vehicleId;
{
    self = [super init];
    if (self)
    {
        self.signalName   = [signalName copy];
        self.vehicleId    = [vehicleId copy];
        self.cachedValues = [NSMutableArray array];
    }

    return self;
}

+ (instancetype)dataWithSignalName:(NSString *)signalName vehicleId:(NSString *)vehicleId;
{
    return [[self alloc] initWithSignalName:signalName vehicleId:vehicleId];
}

- (NSInteger)heightForDescriptorData
{
    NSInteger heightForDescriptorData = 0;

    switch (self.signal.signalType) {

        case SIGNAL_TYPE_UNKNOWN:
            break;

        case SIGNAL_TYPE_CONVERTED_RANGE:

            heightForDescriptorData += LINE_HEIGHT * 2;
        case SIGNAL_TYPE_RANGE:

            heightForDescriptorData += LINE_HEIGHT * 2;
            break;

        case SIGNAL_TYPE_RANGE_ENUMERATION:

            heightForDescriptorData += LINE_HEIGHT * 2;

        case SIGNAL_TYPE_ENUMERATION:

            heightForDescriptorData += LINE_HEIGHT + (self.signal.allValuePairs.count * LINE_HEIGHT);
            break;
    }

    return heightForDescriptorData + VERTICAL_PADDING;
}

- (NSInteger)heightForCachedValues
{
    if (!self.cachedValues.count) return 0;

    return LINE_HEIGHT + (self.cachedValues.count * LINE_HEIGHT) + VERTICAL_PADDING;
}

- (NSInteger)heightForCurrentValue
{
    if (!self.currentValue) return 0;

    return LINE_HEIGHT + LINE_HEIGHT + VERTICAL_PADDING;
}

- (NSInteger)heightForCell
{
    if (self.signal == nil)
        return 80;

    return EXTENDED_DATA_START + [self heightForDescriptorData] + [self heightForCachedValues] + [self heightForCurrentValue];
}

- (void)updateCurrentValue:(NSNumber *)newValue
{
    if (self.currentValue)
        [self.cachedValues addObject:self.currentValue];

    if (self.cachedValues.count > MAX_CACHED)
        [self.cachedValues removeObjectAtIndex:0];

    self.currentValue = newValue;
}
@end

@interface AllSignalsViewController () <SignalManagerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating>
@property (nonatomic, strong) IBOutlet UITableView         *tableView;
@property (nonatomic, strong)          NSArray             *allSignals;
@property (nonatomic, strong)          NSArray             *searchResults;
@property (nonatomic, strong)          UISearchController  *searchController;
@property (nonatomic, copy)            NSString            *savedSearchText;
@property (nonatomic, strong)          UIRefreshControl    *refreshControl;
@property (nonatomic, strong)          SelectedCellData    *selectedCellData;
@property (nonatomic, strong)          NSMutableDictionary *cachedSignalData;
@property (nonatomic)                  NSInteger            selectedRow;
@end

@implementation AllSignalsViewController
{

}

- (void)viewDidLoad
{
    DLog(@"");
    [super viewDidLoad];

    // Create the search results controller and store a reference to it.
    //SearchResultsController* resultsController = [[SearchResultsController alloc] init];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];//resultsController];

    // Use the current view controller to update the search results.
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;

    // Install the search bar as the table header.
    self.tableView.tableHeaderView = self.searchController.searchBar;

    // It is usually good to set the presentation context.
    self.definesPresentationContext = NO;

    self.selectedRow = -1;

    self.cachedSignalData = [NSMutableDictionary dictionary];

    // Initialize the refresh control.
    self.refreshControl                 = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor       = [UIColor whiteColor];

    [self.refreshControl addTarget:self
                            action:@selector(getAllSignals)
                  forControlEvents:UIControlEventValueChanged];

    [self.tableView addSubview:self.refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    DLog(@"");
    [super viewWillAppear:animated];

    [SignalManager setDelegate:self];

    if (self.savedSearchText && [self.savedSearchText isEqualToString:@""])
    {
        [self.searchController setActive:YES];
        [self.searchController.searchBar setText:self.savedSearchText];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    DLog(@"");
    [super viewDidAppear:animated];

    [self getAllSignals];

    for (NSString *key in self.cachedSignalData.allKeys)
    {
        NSArray *keyParts = [key componentsSeparatedByString:@":"];
        if (keyParts.count == 2) [SignalManager subscribeToSignal:keyParts[1] forVehicle:keyParts[0]];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    DLog(@"");
    [super viewWillDisappear:animated];

    for (NSString *key in self.cachedSignalData.allKeys)
    {
        NSArray *keyParts = [key componentsSeparatedByString:@":"];
        if (keyParts.count == 2 && ![[VehicleManager vehicle] isSignalDefault:keyParts[1]]) [SignalManager unsubscribeFromSignal:keyParts[1] forVehicle:keyParts[0]];
    }

    [SignalManager setDelegate:nil];

    [self setSavedSearchText:self.searchController.searchBar.text];
    [self.searchController setActive:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    DLog(@"");
    [super viewDidDisappear:animated];
}

- (void)getAllSignals
{
    [SignalManager getAllSignalsForVehicle:[ConfigurationDataManager getVehicleId]];
}

- (void)signalManagerDidGetAllSignals:(NSArray *)signals forVehicle:(NSString *)vehicleId
{
    self.allSignals = [signals copy];

    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (void)signalManagerDidReceiveErrorWhenRetrievingSignalDescriptorForVehicle:(NSString *)vehicleId signalName:(NSString *)signalName errorMessage:(NSString *)errorMessage
{
    DLog(@"");
    SelectedCellData *selectedCellData = self.cachedSignalData[key(vehicleId, signalName)];

    if (!selectedCellData) return; /* Weird... should always be here, but adding this anyway. */

    selectedCellData.errorMessage = [errorMessage copy];

    /* And readjust the height of the selected cell; happens automatically if this is called for the selected cell. */
    [self.tableView beginUpdates];
    [self.tableView endUpdates];

    if (self.selectedRow != -1)
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.selectedRow inSection:0]]
                              withRowAnimation:UITableViewRowAnimationNone];
}

- (void)signalManagerDidReceiveSignalDescriptorForVehicle:(NSString *)vehicleId signal:(Signal *)signal signalName:(NSString *)signalName
{
    DLog(@"");
    SelectedCellData *selectedCellData = self.cachedSignalData[key(vehicleId, signalName)];

    if (!selectedCellData) return; /* Weird... should always be here, but adding this anyway. */

    selectedCellData.signal = signal;

    /* And readjust the height of the selected cell; happens automatically if this is called for the selected cell. */
    [self.tableView beginUpdates];
    [self.tableView endUpdates];

    if (self.selectedRow != -1)
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.selectedRow inSection:0]]
                              withRowAnimation:UITableViewRowAnimationNone];
}

- (void)signalManagerDidReceiveEventForVehicle:(NSString *)vehicleId signalName:(NSString *)signalName attributes:(NSDictionary *)attributes
{
    DLog(@"");
    SelectedCellData *selectedCellData = self.cachedSignalData[key(vehicleId, signalName)];

    if (!selectedCellData) return; /* Weird... should always be here, but adding this anyway. */

    [selectedCellData updateCurrentValue:attributes[@"value"]];
    [selectedCellData.signal setCurrentValue:attributes[@"value"]];

    /* And readjust the height of the selected cell; happens automatically if this is called for the selected cell. */
    [self.tableView beginUpdates];
    [self.tableView endUpdates];

    if (self.selectedRow != -1)
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.selectedRow inSection:0]]
                              withRowAnimation:UITableViewRowAnimationNone];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.selectedRow && self.selectedCellData)
        return [self.selectedCellData heightForCell];

    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 44;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return self.searchController.searchBar;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active)
        return [self.searchResults count];
    else
        return [self.allSignals count];
}

#define TAG_CELL_TITLE_LABEL 100

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"");

    NSString *reuseIdentifier = [indexPath row] == self.selectedRow ? @"ExpandedCell" : @"RegularCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    UILabel *titleLabel = [cell viewWithTag:TAG_CELL_TITLE_LABEL];

    if (self.searchController.active)
        titleLabel.text = self.searchResults[(NSUInteger)indexPath.row];
    else
        titleLabel.text = self.allSignals[(NSUInteger)indexPath.row];

    if (indexPath.row == self.selectedRow)
    {
        return [self drawCell:cell forSelectedCellData:self.selectedCellData];
    }

    return cell;
}

- (void)handleDidSelectTableViewCellAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *vehicleId  = [ConfigurationDataManager getVehicleId];
    NSString *signalName = self.searchController.active ?
                                     self.searchResults[(NSUInteger)indexPath.row] :
                                     self.allSignals[(NSUInteger)indexPath.row];

    /* If we've selected this cell before, and already have the signal descriptor data... */
    if (self.cachedSignalData[key(vehicleId, signalName)] && ((SelectedCellData *)self.cachedSignalData[key(vehicleId, signalName)]).signal)
    {
        self.selectedCellData = self.cachedSignalData[key(vehicleId, signalName)];
        return;
    }

    self.selectedCellData = [SelectedCellData dataWithSignalName:signalName
                                                       vehicleId:vehicleId];

    self.cachedSignalData[key(vehicleId, signalName)] = self.selectedCellData;

    [SignalManager getDescriptorsForSignalNames:@[signalName] vehicleId:vehicleId];
    [SignalManager subscribeToSignal:signalName forVehicle:vehicleId];
}

- (void)handleDidDeselectTableViewCellAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self setSelectedCellData:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"Row: %d", [indexPath row]);

    if (self.selectedRow >= 0 && self.selectedRow == [indexPath row])
    {
        self.selectedRow = -1;
        [self handleDidDeselectTableViewCellAtIndexPath:indexPath];
    }
    else
    {
        self.selectedRow = [indexPath row];
        [self handleDidSelectTableViewCellAtIndexPath:indexPath];
    }

    [self.searchController.searchBar resignFirstResponder];

    [tableView beginUpdates];
    [tableView endUpdates];

    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"Row: %d", [indexPath row]);

    self.selectedRow = -1;

    [tableView beginUpdates];
    [tableView endUpdates];
}

- (void)filterContentForSearchText:(NSString*)searchText
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    self.searchResults = [self.allSignals filteredArrayUsingPredicate:resultPredicate];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    DLog(@"");

    /* If there's a row selected, deselect it. */
    if (self.selectedRow >= 0) {
        self.selectedRow = -1;

        [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:0] animated:YES];
        [self setSelectedCellData:nil];
    }

    [self filterContentForSearchText:searchController.searchBar.text];
    [self.tableView reloadData];
}

@end
