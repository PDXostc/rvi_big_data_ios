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


@interface SearchResultsController : UIViewController <UISearchControllerDelegate>

@end

@implementation SearchResultsController

- (void)willPresentSearchController:(UISearchController *)searchController
{
    DLog(@"");
}

- (void)didPresentSearchController:(UISearchController *)searchController
{
    DLog(@"");
}

- (void)willDismissSearchController:(UISearchController *)searchController
{
    DLog(@"");
}

- (void)didDismissSearchController:(UISearchController *)searchController
{
    DLog(@"");
}

- (void)presentSearchController:(UISearchController *)searchController
{
    DLog(@"");
}


@end

@interface AllSignalsViewController () <SignalManagerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchResultsUpdating>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong)          NSArray     *allSignals;
@property (nonatomic, strong)          NSArray     *searchResults;
@property (nonatomic, strong)          UISearchController *searchController;
@end

@implementation AllSignalsViewController
{

}

- (void)viewDidLoad
{
    DLog(@"");
    [super viewDidLoad];


    // Create the search results controller and store a reference to it.
    SearchResultsController* resultsController = [[SearchResultsController alloc] init];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:resultsController];

    // Use the current view controller to update the search results.
    self.searchController.searchResultsUpdater = self;

    // Install the search bar as the table header.
    self.tableView.tableHeaderView = self.searchController.searchBar;

    // It is usually good to set the presentation context.
    self.definesPresentationContext = YES;

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
    if (self.searchController.active)//self.searchResults.count)
        return [self.searchResults count];
    else
        return [self.allSignals count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myCell"];

    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"myCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if (self.searchController.active)//self.searchResults.count)
        cell.textLabel.text = self.searchResults[(NSUInteger)indexPath.row];
    else
        cell.textLabel.text = self.allSignals[(NSUInteger)indexPath.row];

    return cell;
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
    DLog(@"Search text: %@", searchController.searchBar.text);

    [self filterContentForSearchText:searchController.searchBar.text];

    [self.tableView reloadData];
}

@end
