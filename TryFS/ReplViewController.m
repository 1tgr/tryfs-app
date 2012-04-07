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
#import "Session.h"
#import "Snippet.h"

@interface ReplViewController ()

@property(nonatomic, retain) CouchChangeTracker *tracker;

@end

@implementation ReplViewController
{
    KeyboardResizeMonitor *_monitor;
    NSMutableArray *_lines;
    Session *_session;
}

@synthesize textField = _textField;
@synthesize textFieldCell = _textFieldCell;
@synthesize tracker = _tracker;
@synthesize snippet = _snippet;
@synthesize session = _session;

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
    [_textFieldCell release];
    [_monitor release];
    [_tracker release];
    [_lines release];
    [_snippet release];
    [_session release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _snippet.title;
    _monitor = [[KeyboardResizeMonitor alloc] initWithView:self.view scrollView:self.tableView];
    _monitor.activeField = _textField;
    [_textField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_monitor registerForKeyboardNotifications];
    [self.tracker start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_monitor cancelKeyboardNotifications];
    [self.tracker stop];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self.tracker stop];
    self.tracker = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)setSession:(Session *)session
{
    NSLog(@"Subscribing to %@", session.sessionId);

    CouchChangeTracker *tracker = [session changeTrackerWithDelegate:self];
    [tracker.filterParams setObject:@"true" forKey:@"include_docs"];

    [self.tracker stop];
    self.tracker = tracker;
    [self.tracker start];
    [_session release];
    _session = [session retain];

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Restart" style:UIBarButtonItemStyleBordered target:self action:@selector(didRestartButton)] autorelease];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _lines.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = (NSUInteger) indexPath.row;
    if (row >= _lines.count)
        return _textFieldCell;
    else
    {
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= _lines.count)
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    else
    {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        return [cell.textLabel.text sizeWithFont:cell.textLabel.font constrainedToSize:tableView.frame.size lineBreakMode:cell.textLabel.lineBreakMode].height;
    }
}

- (void)writeLines:(NSArray *)lines
{
    NSUInteger startIndex = _lines.count;
    [_lines addObjectsFromArray:lines];

    NSUInteger endIndex = _lines.count;
    NSMutableArray *indexPaths = [[[NSMutableArray alloc] initWithCapacity:endIndex - startIndex] autorelease];
    for (NSUInteger row = startIndex; row < endIndex; row++)
        [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:0]];

    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];

    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:_lines.count inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)writeLine:(NSString *)line
{
    [self writeLines:[NSArray arrayWithObject:line]];
}

- (void)tracker:(CouchChangeTracker *)tracker receivedChange:(NSDictionary *)change
{
    NSNumber *seq = [change objectForKey:@"seq"];
    tracker.lastSequenceNumber = seq.unsignedIntegerValue;
    NSLog(@"seq = %d", tracker.lastSequenceNumber);

    NSDictionary *doc = [change objectForKey:@"doc"];
    NSString *message = [doc objectForKey:@"message"];
    [self writeLines:[message componentsSeparatedByString:@"\n"]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.session.sessionId == nil)
        return NO;
    else
    {
        NSString *text = [textField.text stringByAppendingString:@";;"];
        [self.session send:text];
        [self writeLine:text];
        textField.text = @"";
        return YES;
    }
}

- (void)didRestartButton
{
    if (self.session.sessionId != nil)
    {
        UIApplication *app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;

        RESTOperation *op = [self.session reset];
        [op onCompletion:^{
            app.networkActivityIndicatorVisible = NO;
            [self.tracker stop];
            [self.tracker.filterParams setObject:self.session.sessionId forKey:@"sessionId"];
            [self.tracker start];
            [self.session send:@""];
        }];
    }
}

@end
