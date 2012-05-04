//
//  Created by tim on 30/04/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "CouchCocoa.h"
#import "SnippetViewModel.h"
#import "Snippet.h"
#import "Session.h"
#import "EditViewController.h"
#import "ReplViewController.h"


@implementation SnippetViewModel
{
    BOOL _isSplit;
}

@synthesize database = _database;
@synthesize snippet = _snippet;
@synthesize editViewController = _editViewController;
@synthesize replViewController = _replViewController;
@synthesize session = _session;
@synthesize editBarButtonItem = _editBarButtonItem;
@synthesize replBarButtonItem = _replBarButtonItem;

- (id)initWithDatabase:(CouchDatabase *)database snippet:(Snippet *)snippet isSplit:(BOOL)isSplit editViewController:(EditViewController *)editViewController replViewController:(ReplViewController *)replViewController
{
    self = [super init];
    if (self != nil)
    {
        _database = [database retain];
        _snippet = [snippet retain];
        _isSplit = isSplit;
        _editViewController = [editViewController retain];
        _replViewController = [replViewController retain];
    }

    return self;
}

- (void)dealloc
{
    [_database release];
    [_snippet release];
    [_editViewController release];
    [_replViewController release];
    [_session release];
    [_editBarButtonItem release];
    [_replBarButtonItem release];
    [super dealloc];
}

- (BOOL)isSplit
{
    return _isSplit;
}

@end