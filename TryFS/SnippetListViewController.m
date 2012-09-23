//
//  SnippetViewController.m
//  TryFS
//
//  Created by Tim Robinson on 03/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CouchCocoa.h"
#import "SnippetListViewController.h"
#import "EditViewController.h"
#import "Snippet.h"
#import "MGSplitViewController.h"
#import "ReplViewController.h"
#import "SnippetViewModel.h"
#import "EditReplSplitViewController.h"
#import "SnippetFilterQuery.h"
#import "SnippetDBQuery.h"
#import "SnippetListViewModel.h"

@interface SnippetListViewController ()

@property(nonatomic, retain) SnippetFilterQuery *searchQuery;

@end

@implementation SnippetListViewController

@synthesize tableView = _tableView;
@synthesize tabBar = _tabBar;
@synthesize recentTabBarItem = _recentTabBarItem;
@synthesize authorTabBarItem = _authorTabBarItem;
@synthesize query = _query;
@synthesize searchQuery = _searchQuery;

- (void)dealloc
{
    [_tableView release];
    [_tabBar release];
    [_authorTabBarItem release];
    [_recentTabBarItem release];
    [_query release];
    [_searchQuery release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Snippets";
    self.recentTabBarItem.tag = SnippetQuerySortModeRecent;
    self.authorTabBarItem.tag = SnippetQuerySortModeAuthor;
    self.tabBar.selectedItem = self.recentTabBarItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    for (NSIndexPath *indexPath in self.tableView.indexPathsForSelectedRows)
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.query refreshWithActivityOn:[UIApplication sharedApplication]];
    [self.query addObserver:self forKeyPath:@"viewModel" options:0 context:NULL];
    [self.searchQuery subscribe];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.query removeObserver:self forKeyPath:@"viewModel"];
    [self.searchQuery unsubscribe];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (keyPath == @"viewModel" && object == self.query)
    {
        [self.tableView reloadData];
        [self.tableView flashScrollIndicators];
    }
}

- (SnippetListViewModel *)viewModelForTableView:(UITableView *)tableView
{
    if (tableView == self.tableView)
        return self.query.viewModel;
    else
        return self.searchQuery.viewModel;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    SnippetListViewModel *model = [self viewModelForTableView:tableView];
    return model.sectionTitles.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    SnippetListViewModel *model = [self viewModelForTableView:tableView];
    return [model.sectionTitles objectAtIndex:(NSUInteger) section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    SnippetListViewModel *model = [self viewModelForTableView:tableView];
    if (model.groupedOn == nil)
        return nil;
    else
    {
        NSMutableSet *set = [[[NSMutableSet alloc] init] autorelease];
        for (NSString *title in model.sectionTitles)
        {
            if (title.length > 0)
            {
                NSString *prefix = [title substringToIndex:1].uppercaseString;
                [set addObject:prefix];
            }
        }

        return [set sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:nil ascending:YES]]];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)sectionIndexTitle atIndex:(NSInteger)index
{
    SnippetListViewModel *model = [self viewModelForTableView:tableView];
    NSInteger i = 0;
    for (NSString *title in model.sectionTitles)
    {
        if (title.length > 0)
        {
            NSString *prefix = [title substringToIndex:1].uppercaseString;
            if ([prefix isEqualToString:sectionIndexTitle])
                return i;
        }

        i++;
    }

    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SnippetListViewModel *model = [self viewModelForTableView:tableView];
    NSNumber *offsetA = [model.sectionOffsets objectAtIndex:(NSUInteger) section];
    NSNumber *offsetB = [model.sectionOffsets objectAtIndex:(NSUInteger) (section + 1)];
    return offsetB.unsignedIntegerValue - offsetA.unsignedIntegerValue;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SnippetListViewModel *model = [self viewModelForTableView:tableView];
    Snippet *s = [model snippetAtIndexPath:indexPath];
    NSString *reuseId = [NSString stringWithFormat:@"%@-%@", s.id, model.groupedOn];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (cell == nil)
    {
        UITableViewCellStyle style = model.groupedOn == @"author"
                ? UITableViewCellStyleDefault
                : UITableViewCellStyleSubtitle;

        cell = [[[UITableViewCell alloc] initWithStyle:style reuseIdentifier:reuseId] autorelease];
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = s.title;
    cell.detailTextLabel.text = s.author;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SnippetListViewModel *model = [self viewModelForTableView:tableView];
    Snippet *s = [model snippetAtIndexPath:indexPath];
    BOOL isSplit = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
    EditViewController *editController = [[[EditViewController alloc] initWithNibName:@"EditViewController" bundle:nil] autorelease];
    ReplViewController *replController = [[[ReplViewController alloc] initWithNibName:@"ReplViewController" bundle:nil] autorelease];
    SnippetViewModel *viewModel = [[[SnippetViewModel alloc] initWithDatabase:self.query.database snippet:s isSplit:isSplit editViewController:editController replViewController:replController] autorelease];

    editController.viewModel = viewModel;
    replController.viewModel = viewModel;

    UIViewController *controller;
    if (isSplit)
    {
        EditReplSplitViewController *splitViewController = [[[EditReplSplitViewController alloc] init] autorelease];
        splitViewController.viewControllers = [NSArray arrayWithObjects:replController, editController, nil];
        splitViewController.viewModel = viewModel;
        controller = splitViewController;
    }
    else
        controller = editController;

    [self.navigationController pushViewController:controller animated:YES];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    SnippetFilterQuery *query = [[[SnippetFilterQuery alloc] init] autorelease];
    query.query = self.query;
    query.searchString = searchString;

    [self.searchQuery unsubscribe];
    self.searchQuery = query;
    [self.searchQuery subscribe];
    return YES;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    [self.searchQuery unsubscribe];
    self.searchQuery = nil;
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    SnippetQuerySortMode mode = (SnippetQuerySortMode) item.tag;
    if (mode != self.query.sortMode)
    {
        self.query.sortMode = mode;
        [self.query refreshWithActivityOn:[UIApplication sharedApplication]];
    }
}

@end
