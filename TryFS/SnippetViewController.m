//
//  SnippetViewController.m
//  TryFS
//
//  Created by Tim Robinson on 03/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CouchCocoa/CouchCocoa.h>
#import "SnippetViewController.h"
#import "EditViewController.h"
#import "SnippetInfo.h"

@interface SnippetViewController ()

@end

@implementation SnippetViewController
{
    NSArray *_snippets;
}

- (void)dealloc
{
    [_snippets release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Snippets";

    CouchServer *server = [[[CouchServer alloc] initWithURL:[NSURL URLWithString:@"http://ec2.partario.com:5984"]] autorelease];
    CouchQuery *query = [[[server databaseNamed:@"tryfs"] designDocumentWithName:@"app"] queryViewNamed:@"snippets"];
    query.descending = YES;

    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;

    RESTOperation *op = [query start];
    [op onCompletion:^{
        app.networkActivityIndicatorVisible = NO;

        NSMutableArray *snippets = [[[NSMutableArray alloc] init] autorelease];
        for (CouchQueryRow *row in query.rows)
        {
            NSDictionary *v = row.value;
            NSString *userId = [v objectForKey:@"userId"];
            if ([userId isEqualToString:@"fssnip"])
            {
                SnippetInfo *s = [[[SnippetInfo alloc] initWithId:row.documentID
                                                          rev:[v objectForKey:@"_rev"]
                                                       author:[v objectForKey:@"author"]
                                                        title:[v objectForKey:@"title"]
                                                  description:[v objectForKey:@"description"]
                                                         date:[v objectForKey:@"date"]] autorelease];

                [snippets addObject:s];
            }
        }

        _snippets = [snippets retain];
        [self.tableView reloadData];
    }];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    SnippetInfo *s = [_snippets objectAtIndex:(NSUInteger) indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:s.id];
    if (cell == nil)
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:s.id] autorelease];

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
    [self.navigationController pushViewController:[[[EditViewController alloc] init] autorelease] animated:YES];
}

@end
