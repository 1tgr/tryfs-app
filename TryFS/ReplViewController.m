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
#import "SnippetViewModel.h"

@interface ReplViewController ()

@property(nonatomic, retain) CouchChangeTracker *tracker;

@end

@implementation ReplViewController
{
    KeyboardResizeMonitor *_monitor;
    NSMutableArray *_lines;
}

@synthesize viewModel = _viewModel;
@synthesize textField = _textField;
@synthesize textFieldCell = _textFieldCell;
@synthesize tracker = _tracker;

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
    [_viewModel release];
    [super dealloc];
}

- (void)updateNavigationItem:(BOOL)animated
{
    SnippetViewModel *viewModel = self.viewModel;
    if (!viewModel.isSplit)
    {
        [self.navigationItem setRightBarButtonItem:viewModel.replBarButtonItem animated:animated];
        self.title = viewModel.snippet.title;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!self.viewModel.isSplit)
    {
        _monitor = [[KeyboardResizeMonitor alloc] initWithView:self.view scrollView:self.tableView];
        _monitor.activeField = _textField;
    }

    [_textField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_monitor registerForKeyboardNotifications];
    [self.tracker start];
    [self updateNavigationItem:animated];
    [self.viewModel addObserver:self forKeyPath:@"session" options:0 context:NULL];
    [self.viewModel addObserver:self forKeyPath:@"replBarButtonItem" options:0 context:NULL];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_monitor cancelKeyboardNotifications];
    [self.viewModel removeObserver:self forKeyPath:@"session"];
    [self.viewModel removeObserver:self forKeyPath:@"replBarButtonItem"];
    [self.tracker stop];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.viewModel)
    {
        if (keyPath == @"session")
        {
            Session *session = self.viewModel.session;
            NSLog(@"Subscribing to %@", session.sessionId);

            CouchChangeTracker *tracker = [session changeTrackerWithDelegate:self];
            [tracker.filterParams setObject:@"true" forKey:@"include_docs"];

            [self.tracker stop];
            self.tracker = tracker;
            [self.tracker start];

            UIBarButtonItem *restartButton = [[[UIBarButtonItem alloc] initWithTitle:@"Restart" style:UIBarButtonItemStyleBordered target:self action:@selector(didRestartButton)] autorelease];
            self.viewModel.replBarButtonItem = restartButton;
        }
        else if (keyPath == @"replBarButtonItem")
            [self updateNavigationItem:YES];
    }
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
        UILabel *label;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId] autorelease];

            CGRect frame = cell.frame;
            frame.origin = CGPointMake(8, 2);
            frame.size.width -= frame.origin.x * 2;
            frame.size.height -= frame.origin.y;

            label = [[[UILabel alloc] initWithFrame:frame] autorelease];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            label.backgroundColor = [UIColor clearColor];
            label.font = self.textField.font;
            label.lineBreakMode = UILineBreakModeWordWrap;
            label.numberOfLines = 0;
            label.textColor = self.textField.textColor;

            [cell.contentView addSubview:label];
        }
        else
            label = [cell.contentView.subviews objectAtIndex:0];

        label.text = [_lines objectAtIndex:row];
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
        UILabel *label = [cell.contentView.subviews objectAtIndex:0];
        CGSize tableSize = tableView.frame.size;
        CGSize cellSize = cell.frame.size;
        CGSize labelSize = label.frame.size;
        CGSize size = tableSize;
        size.width -= cellSize.width - labelSize.width;

        CGFloat rowHeight = [label.text sizeWithFont:label.font constrainedToSize:size lineBreakMode:label.lineBreakMode].height;
        rowHeight += cellSize.height - labelSize.height;
        return rowHeight;
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
    if (self.viewModel.session.sessionId == nil)
        return NO;
    else
    {
        NSString *text = [textField.text stringByAppendingString:@";;"];
        [self.viewModel.session send:text];
        [self writeLine:text];
        textField.text = @"";
        return YES;
    }
}

- (void)didRestartButton
{
    if (self.viewModel.session.sessionId != nil)
    {
        UIApplication *app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;

        RESTOperation *op = [self.viewModel.session reset];
        [op onCompletion:^{
            app.networkActivityIndicatorVisible = NO;
            [self.tracker stop];
            [self.tracker.filterParams setObject:self.viewModel.session.sessionId forKey:@"sessionId"];
            [self.tracker start];
            [self.viewModel.session send:@""];
        }];
    }
}

@end
