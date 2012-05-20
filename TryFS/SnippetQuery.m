//
//  Created by tim on 15/04/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "SnippetQuery.h"

@interface SnippetQuery ()

- (void)setViewModel:(SnippetListViewModel *)model;

@end

@implementation SnippetQuery

@synthesize viewModel = _viewModel;

- (void)dealloc
{
    [_viewModel release];
    [super dealloc];
}

- (void)setViewModel:(SnippetListViewModel *)model
{
    [_viewModel autorelease];
    _viewModel = [model retain];
}

@end
