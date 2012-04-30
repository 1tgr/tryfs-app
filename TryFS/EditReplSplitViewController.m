//
//  Created by tim on 30/04/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "EditReplSplitViewController.h"
#import "SnippetViewModel.h"
#import "Snippet.h"

@interface MGSplitViewController (MGPrivateMethods)

- (CGSize)splitViewSizeForOrientation:(UIInterfaceOrientation)theOrientation;

@end

@implementation EditReplSplitViewController
{
    KeyboardResizeMonitor *_monitor;
    CGFloat _keyboardHeight;
}

@synthesize viewModel = _viewModel;

- (id)init
{
    self = [super init];
    if (self != nil)
        self.delegate = self;

    return self;
}

- (void)dealloc
{
    [_viewModel release];
    [_monitor release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _monitor = [[KeyboardResizeMonitor alloc] initWithView:self.view adapter:self];
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
    [_monitor registerForKeyboardNotifications];
    [self.viewModel addObserver:self forKeyPath:@"editBarButtonItem" options:0 context:NULL];
    [self.viewModel addObserver:self forKeyPath:@"replBarButtonItem" options:0 context:NULL];
    [self updateNavigationItem:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_monitor cancelKeyboardNotifications];
    [self.viewModel removeObserver:self forKeyPath:@"editBarButtonItem"];
    [self.viewModel removeObserver:self forKeyPath:@"replBarButtonItem"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.viewModel)
        [self updateNavigationItem:YES];
}

- (CGSize)splitViewSizeForOrientation:(UIInterfaceOrientation)theOrientation
{
    CGSize size = [super splitViewSizeForOrientation:theOrientation];
    CGFloat navigationBarHeight = 44;
    size.height -= _keyboardHeight + navigationBarHeight;
    return size;
}

- (void)resizeViewForKeyboardWithHeight:(CGFloat)height
{
    _keyboardHeight = height;
    [self setSplitPosition:self.splitPosition - height animated:YES];
}

- (void)resetViewSize
{
    CGFloat height = _keyboardHeight;
    _keyboardHeight = 0;
    [self setSplitPosition:self.splitPosition + height animated:YES];
}

- (float)splitViewController:(MGSplitViewController *)svc constrainSplitPosition:(float)proposedPosition splitViewSize:(CGSize)viewSize
{
    float minPos = 200;
    float maxPos = (self.vertical ? viewSize.width : viewSize.height) - (200 + self.splitWidth);
    return MAX(minPos, MIN(maxPos, proposedPosition));
}

@end