//
//  ReplViewController.m
//  TryFS
//
//  Created by Tim Robinson on 03/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CouchCocoa.h"
#import "ReplViewController.h"
#import "KeyboardResizeMonitor.h"

@implementation ReplViewController
{
    KeyboardResizeMonitor *_monitor;
    CouchChangeTracker *_tracker;
    NSMutableArray *_lines;
}

@synthesize textField = _textField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil)
        _lines = [[NSMutableArray alloc] init];

    return self;
}

- (void)dealloc
{
    [_textField release];
    [_monitor release];
    [_tracker release];
    [_lines release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"REPL";
    _monitor = [[KeyboardResizeMonitor alloc] initWithView:self.view scrollView:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_monitor registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_monitor cancelKeyboardNotifications];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [_tracker stop];
    [_tracker release];
    _tracker = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)subscribeToSession:(CouchDocument *)sessionDoc
{
    NSLog(@"Subscribing to %@", sessionDoc.documentID);
    self.title = sessionDoc.documentID;

    [_tracker stop];
    [_tracker release];
    _tracker = [[CouchChangeTracker alloc] initWithDatabase:sessionDoc.database delegate:self];
    _tracker.lastSequenceNumber = sessionDoc.database.lastSequenceNumber;
    _tracker.filter = @"app/session";
    [_tracker.filterParams setObject:sessionDoc.documentID forKey:@"sessionId"];
    [_tracker.filterParams setObject:@"true" forKey:@"include_docs"];
    [_tracker start];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _lines.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = (NSUInteger) indexPath.row;
    NSString *cellId = [[NSNumber numberWithInt:row] stringValue];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];
        cell.textLabel.textColor = self.textField.textColor;
        cell.textLabel.font = self.textField.font;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.textLabel.numberOfLines = 0;
    }

    cell.textLabel.text = [_lines objectAtIndex:row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *text = cell.textLabel.text;
    UIFont *font = cell.textLabel.font;

    CGSize labelSize;
    labelSize.width = cell.frame.size.width;
    labelSize.height = tableView.frame.size.height;

    CGSize size = [text sizeWithFont:font constrainedToSize:labelSize lineBreakMode:UILineBreakModeWordWrap];
    return size.height;
}

- (void)tracker:(CouchChangeTracker *)tracker receivedChange:(NSDictionary *)change
{
    NSDictionary *doc = [change objectForKey:@"doc"];
    NSString *message = [doc objectForKey:@"message"];
    NSUInteger startIndex = _lines.count;
    [_lines addObjectsFromArray:[message componentsSeparatedByString:@"\n"]];

    NSUInteger endIndex = _lines.count;
    NSMutableArray *indexPaths = [[[NSMutableArray alloc] initWithCapacity:endIndex - startIndex] autorelease];
    for (NSUInteger i = startIndex; i < endIndex; i++)
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];

    UITableView *view = self.tableView;
    [view beginUpdates];
    [view insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    [view endUpdates];
}

@end
