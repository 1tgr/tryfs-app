//
// Created by tim on 20/05/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "CouchCocoa.h"
#import "SnippetDBQuery.h"
#import "SnippetQueryProtected.h"
#import "Snippet.h"
#import "SnippetListViewModel.h"

@interface SnippetDBQuery ()

@property (nonatomic, retain) CouchQuery *query;
@property (nonatomic, retain) RESTOperation *op;

@end

@implementation SnippetDBQuery
{
    CouchDatabase *_database;
    Snippet *_emptySnippet;
    NSArray *_queries;
    NSMutableArray *_viewModels;
}

@synthesize database = _database;
@synthesize sortMode = _sortMode;
@synthesize query = _query;
@synthesize op = _op;

-(id)initWithDatabase:(CouchDatabase *)database
{
    self = [super init];
    if (self != nil)
    {
        _database = [database retain];
        _emptySnippet = [[Snippet alloc] initWithId:nil
                                                rev:nil
                                             author:@""
                                              title:@"Scratchpad"
                                        description:@""
                                               date:[NSDate date]];

        CouchDesignDocument *ddoc = [_database designDocumentWithName:@"app"];
        CouchQuery *recentQuery = [ddoc queryViewNamed:@"snippets"];
        recentQuery.descending = YES;

        CouchQuery *authorQuery = [ddoc queryViewNamed:@"snippets-by-author"];
        _queries = [[NSArray arrayWithObjects:recentQuery, authorQuery, nil] retain];

        SnippetListViewModel *emptyModel = [[[SnippetListViewModel alloc] initWithSnippets:[NSArray arrayWithObject:_emptySnippet] groupedOn:nil] autorelease];
        _viewModels = [[NSMutableArray arrayWithObjects:emptyModel, emptyModel, nil] retain];
        self.sortMode = SnippetQuerySortModeRecent;
    }

    return self;
}

- (void)dealloc
{
    [_database release];
    [_query release];
    [_queries release];
    [_viewModels release];
    [_emptySnippet release];
    [_op release];
    [super dealloc];
}

- (void)setSortMode:(SnippetQuerySortMode)mode
{
    self.query = [_queries objectAtIndex:mode];
    self.viewModel = [_viewModels objectAtIndex:mode];
    _sortMode = mode;
}

- (SnippetListViewModel *)viewModelForSnippets:(NSArray *)snippets
{
    NSString *groupedOn = self.sortMode == SnippetQuerySortModeAuthor ? @"author" : nil;
    return [[[SnippetListViewModel alloc] initWithSnippets:snippets groupedOn:groupedOn] autorelease];
}

- (void)refreshWithActivityOn:(UIApplication *)app
{
    if (self.op != nil)
        return;

    CouchQuery *query = self.query;
    NSString *oldETag = query.eTag;
    SnippetQuerySortMode mode = self.sortMode;
    app.networkActivityIndicatorVisible = YES;

    RESTOperation *op = [query start];
    self.op = op;
    [op onCompletion:^{
        app.networkActivityIndicatorVisible = NO;
        self.op = nil;

        NSMutableArray *snippets = [[[NSMutableArray alloc] init] autorelease];
        [snippets addObject:_emptySnippet];

        if (op.error != nil)
        {
            self.viewModel = [self viewModelForSnippets:snippets];
            [[[[UIAlertView alloc] initWithTitle:op.error.localizedDescription message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
        }
        else if (![query.eTag isEqualToString:oldETag])
        {
            NSLog(@"Reloading snippets: etag was %@, is %@", oldETag, query.eTag);

            for (CouchQueryRow *row in op.resultObject)
            {
                NSDictionary *v = row.value;
                NSString *userId = [v objectForKey:@"userId"];
                if ([userId isEqualToString:@"fssnip"])
                {
                    NSString *description = [v objectForKey:@"description"];
                    Snippet *s = [[[Snippet alloc] initWithId:row.documentID
                                                          rev:[v objectForKey:@"_rev"]
                                                       author:[v objectForKey:@"author"]
                                                        title:[v objectForKey:@"title"]
                                                  description:[description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                                         date:[v objectForKey:@"date"]] autorelease];

                    [snippets addObject:s];
                }
            }

            SnippetListViewModel *model = [self viewModelForSnippets:snippets];
            [_viewModels replaceObjectAtIndex:mode withObject:model];
            self.viewModel = model;
        }
    }];
}

@end
