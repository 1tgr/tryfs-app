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

@interface SnippetListViewController ()

@end

@implementation SnippetListViewController
{
    Snippet *_emptySnippet;
    NSArray *_snippets;
}

@synthesize database = _database;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _emptySnippet = [[Snippet alloc] initWithId:nil
                                                    rev:nil
                                                 author:nil
                                                  title:@"Scratchpad"
                                            description:nil
                                                   date:[NSDate date]];

        _snippets = [[NSArray arrayWithObject:_emptySnippet] retain];
    }

    return self;
}

- (void)dealloc
{
    [_emptySnippet release];
    [_snippets release];
    [_database release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Snippets";
}

- (void)viewDidAppear:(BOOL)animated
{
    CouchQuery *query = [[_database designDocumentWithName:@"app"] queryViewNamed:@"snippets"];
    query.descending = YES;
    
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    
    RESTOperation *op = [query start];
    [op onCompletion:^{
        app.networkActivityIndicatorVisible = NO;
        
        if (op.error == nil)
        {
            NSMutableArray *snippets = [[[NSMutableArray alloc] init] autorelease];
            [snippets addObject:_emptySnippet];
            
            for (CouchQueryRow *row in query.rows)
            {
                NSDictionary *v = row.value;
                NSString *userId = [v objectForKey:@"userId"];
                if ([userId isEqualToString:@"fssnip"])
                {
                    NSString *description = [v objectForKey:@"description"];
                    Snippet *s = [[[Snippet alloc] initWithId:row.documentID
                                                          rev:[v objectForKey:@"_rev"]
                                                       author:[v objectForKey:@"author"]
                                                        title:[v objectForKey:@"title"]
                                                  description:[description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                                         date:[v objectForKey:@"date"]] autorelease];
                    
                    [snippets addObject:s];
                }
            }
            
            _snippets = [snippets retain];
            [self.tableView reloadData];
        }
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _snippets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Snippet *s = [_snippets objectAtIndex:(NSUInteger) indexPath.row];
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
    Snippet *snippet = [_snippets objectAtIndex:(NSUInteger) indexPath.row];
    BOOL isSplit = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
    EditViewController *editController = [[[EditViewController alloc] initWithNibName:@"EditViewController" bundle:nil] autorelease];
    ReplViewController *replController = [[[ReplViewController alloc] initWithNibName:@"ReplViewController" bundle:nil] autorelease];
    SnippetViewModel *viewModel = [[[SnippetViewModel alloc] initWithDatabase:_database snippet:snippet isSplit:isSplit editViewController:editController replViewController:replController] autorelease];

    editController.viewModel = viewModel;
    replController.viewModel = viewModel;

    UIViewController *controller;
    if (isSplit)
    {
        EditReplSplitViewController *splitViewController = [[[EditReplSplitViewController alloc] init] autorelease];
        splitViewController.masterBeforeDetail = NO;
        splitViewController.showsMasterInPortrait = YES;
        splitViewController.vertical = NO;
        splitViewController.viewControllers = [NSArray arrayWithObjects:replController, editController, nil];
        splitViewController.viewModel = viewModel;
        controller = splitViewController;
    }
    else
        controller = editController;

    [self.navigationController pushViewController:controller animated:YES];
}

@end
