//
//  ReplViewController.m
//  TryFS
//
//  Created by Tim Robinson on 03/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CouchCocoa.h"
#import "ReplViewController.h"

@implementation ReplViewController
{
    CouchUITableSource *_source;
}

@synthesize textField = _textField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _source = [[CouchUITableSource alloc] init];
        _source.labelProperty = @"message";
    }

    return self;
}

- (void)dealloc
{
    [_textField release];
    [_source release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"REPL";

    UITableView *view = (UITableView *) self.view;
    _source.tableView = view;
    view.dataSource = _source;

    [self.textField becomeFirstResponder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    UITableView *view = (UITableView *) self.view;
    _source.tableView = nil;
    view.dataSource = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)subscribeToSession:(CouchDocument *)sessionDoc
{
    NSLog(@"Subscribing to %@", sessionDoc.documentID);
    self.title = sessionDoc.documentID;

    CouchQuery *query = [[sessionDoc.database designDocumentWithName:@"app"] queryViewNamed:@"session"];
    query.keys = [NSArray arrayWithObject:sessionDoc.documentID];
    CouchLiveQuery *liveQuery = query.asLiveQuery;

    RESTOperation *op = [liveQuery start];
    [op onCompletion:^{
        _source.query = liveQuery;
    }];
}

- (void)couchTableSource:(CouchUITableSource *)source willUseCell:(UITableViewCell *)cell forRow:(CouchQueryRow *)row
{
    cell.textLabel.textColor = self.textField.textColor;
    cell.textLabel.font = self.textField.font;
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.numberOfLines = 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [_source tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *text = cell.textLabel.text;
    UIFont *font = cell.textLabel.font;

    CGSize labelSize;
    labelSize.width = cell.frame.size.width;
    labelSize.height = tableView.frame.size.height;

    CGSize size = [text sizeWithFont:font constrainedToSize:labelSize lineBreakMode:UILineBreakModeWordWrap];
    return size.height + font.lineHeight;
}

@end
