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
#import "SnippetQuery.h"

@interface SnippetListViewController ()

@property(nonatomic, retain) SnippetFilterQuery *searchQuery;

@end

@implementation SnippetListViewController

@synthesize tableView = _tableView;
@synthesize query = _query;
@synthesize searchQuery = _searchQuery;

- (void)dealloc
{
    [_query release];
    [_searchQuery release];
    [_tableView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Snippets";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    for (NSIndexPath *indexPath in self.tableView .indexPathsForSelectedRows)
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.query refresh];
    [self.query addObserver:self forKeyPath:@"snippets" options:0 context:NULL];
    [self.searchQuery subscribe];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.query removeObserver:self forKeyPath:@"snippets"];
    [self.searchQuery unsubscribe];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (keyPath == @"snippets" && object == self.query)
    {
        [self.tableView reloadData];
        [self.tableView flashScrollIndicators];
    }
}

- (SnippetQuery *)snippetQueryForTableView:(UITableView *)tableView
{
    if (tableView == self.tableView)
        return self.query;
    else
        return self.searchQuery;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self snippetQueryForTableView:tableView].snippets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Snippet *s = [[self snippetQueryForTableView:tableView].snippets objectAtIndex:(NSUInteger) indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:s.id];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:s.id] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    cell.textLabel.text = s.title;
    cell.detailTextLabel.text = s.author;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SnippetQuery *query = [self snippetQueryForTableView:tableView];
    Snippet *snippet = [query.snippets objectAtIndex:(NSUInteger) indexPath.row];
    BOOL isSplit = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
    EditViewController *editController = [[[EditViewController alloc] initWithNibName:@"EditViewController" bundle:nil] autorelease];
    ReplViewController *replController = [[[ReplViewController alloc] initWithNibName:@"ReplViewController" bundle:nil] autorelease];
    SnippetViewModel *viewModel = [[[SnippetViewModel alloc] initWithDatabase:self.query.database snippet:snippet isSplit:isSplit editViewController:editController replViewController:replController] autorelease];

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

@end
