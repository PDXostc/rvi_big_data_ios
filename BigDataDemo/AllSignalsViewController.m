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


@interface AllSignalsViewController () <SignalManagerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating>
@property (nonatomic, strong) IBOutlet UITableView        *tableView;
@property (nonatomic, strong)          NSArray            *allSignals;
@property (nonatomic, strong)          NSArray            *searchResults;
@property (nonatomic, strong)          UISearchController *searchController;
@property (nonatomic, copy)            NSString           *savedSearchText;
@property (nonatomic)                  NSInteger          selectedRow;
@property (nonatomic, strong)          UIRefreshControl   *refreshControl;
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
    //self.tableView.tableHeaderView = self.searchController.searchBar;



    // It is usually good to set the presentation context.
    self.definesPresentationContext = NO;

    self.selectedRow = -1;

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
}

- (void)viewWillDisappear:(BOOL)animated
{
    DLog(@"");
    [super viewWillDisappear:animated];

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

- (void)signalManagerDidReceiveEventForVehicle:(NSString *)vehicleId signalName:(NSString *)signals attributes:(NSDictionary *)attributes
{

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.selectedRow)
        return 150;

    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.searchController.searchBar;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active)//self.searchResults.count)
        return [self.searchResults count];
    else
        return [self.allSignals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = [indexPath row] == self.selectedRow ? @"ExpandedCell" : @"RegularCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    UILabel *titleLabel = [cell viewWithTag:100];

    if (self.searchController.active)//self.searchResults.count)
        titleLabel.text = self.searchResults[(NSUInteger)indexPath.row];
    else
        titleLabel.text = self.allSignals[(NSUInteger)indexPath.row];







    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"Row: %d", [indexPath row]);

    if (self.selectedRow >= 0 && self.selectedRow == [indexPath row])
    {
        self.selectedRow = -1;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else
    {
        self.selectedRow = [indexPath row];
    }

    [tableView beginUpdates];
    [tableView endUpdates];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"Row: %d", [indexPath row]);

    self.selectedRow = -1;

    [tableView beginUpdates];
    [tableView endUpdates];
}

- (void)filterContentForSearchText:(NSString*)searchText// scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchText];
    self.searchResults = [self.allSignals filteredArrayUsingPredicate:resultPredicate];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];

    return YES;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    //DLog(@"Search text: %@", searchController.searchBar.text);
    DLog(@"");

    if (self.selectedRow >= 0)
        [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:0]];

    [self filterContentForSearchText:searchController.searchBar.text];
    [self.tableView reloadData];
}

@end
