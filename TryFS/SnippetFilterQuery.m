//
// Created by tim on 20/05/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "SnippetQuery.h"
#import "SnippetFilterQuery.h"
#import "SnippetQueryProtected.h"
#import "SnippetListViewModel.h"

@implementation SnippetFilterQuery

@synthesize query = _query;
@synthesize searchString = _searchString;

- (void)dealloc
{
    [_query release];
    [_searchString release];
    [super dealloc];
}

- (void)update
{
    NSSet *keys = [NSSet setWithObjects:@"title", @"author", nil];
    self.viewModel = [self.query.viewModel filteredBy:self.searchString inKeys:keys];
}

- (void)subscribe
{
    [self update];
    [self.query addObserver:self forKeyPath:@"viewModel" options:0 context:NULL];
}

- (void)unsubscribe
{
    [self.query removeObserver:self forKeyPath:@"viewModel" context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (keyPath == @"viewModel" && object == self.query)
        [self update];
}

@end
