//
//  Created by tim on 30/04/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "EditReplSplitViewController.h"
#import "SnippetViewModel.h"
#import "Snippet.h"

@implementation EditReplSplitViewController

@synthesize viewModel = _viewModel;

- (void)dealloc
{
    [_viewModel release];
    [super dealloc];
}

- (void)updateNavigationItem:(BOOL)animated
{
    SnippetViewModel *viewModel = self.viewModel;
    NSMutableArray *items = [[[NSMutableArray alloc] initWithCapacity:2] autorelease];
    if (viewModel.editBarButtonItem != nil)
        [items addObject:viewModel.editBarButtonItem];
    if (viewModel.replBarButtonItem != nil)
        [items addObject:viewModel.replBarButtonItem];

    [self.navigationItem setRightBarButtonItems:items animated:animated];
    self.title = viewModel.snippet.title;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.viewModel addObserver:self forKeyPath:@"editBarButtonItem" options:0 context:NULL];
    [self.viewModel addObserver:self forKeyPath:@"replBarButtonItem" options:0 context:NULL];
    [self updateNavigationItem:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.viewModel removeObserver:self forKeyPath:@"editBarButtonItem"];
    [self.viewModel removeObserver:self forKeyPath:@"replBarButtonItem"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.viewModel)
        [self updateNavigationItem:YES];
}

@end