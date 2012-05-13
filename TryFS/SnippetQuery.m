//
//  Created by tim on 15/04/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "CouchCocoa.h"
#import "SnippetQuery.h"
#import "Snippet.h"

@interface SnippetQuery ()

- (void)setSnippets:(NSArray *)snippets;

@end

@implementation SnippetQuery

@synthesize snippets = _snippets;

- (void)dealloc
{
    [_snippets release];
    [super dealloc];
}

- (void)setSnippets:(NSArray *)snippets
{
    [_snippets autorelease];
    _snippets = [snippets retain];
}

@end

@interface SnippetDBQuery ()

@property (nonatomic, retain) RESTOperation *op;

@end

@implementation SnippetDBQuery
{
    CouchQuery *_query;
    Snippet *_emptySnippet;
}

@synthesize op = _op;

-(id)initWithDatabase:(CouchDatabase *)database
{
    self = [super init];
    if (self != nil)
    {
        _query = [[[database designDocumentWithName:@"app"] queryViewNamed:@"snippets"] retain];
        _query.descending = YES;

        _emptySnippet = [[Snippet alloc] initWithId:nil
                                                rev:nil
                                             author:nil
                                              title:@"Scratchpad"
                                        description:nil
                                               date:[NSDate date]];

        self.snippets = [NSArray arrayWithObject:_emptySnippet];
    }

    return self;
}

- (void)dealloc
{
    [_query release];
    [_emptySnippet release];
    [_op release];
    [super dealloc];
}

- (CouchDatabase *)database
{
    return _query.database;
}

- (void)refresh
{
    if (self.op != nil)
        return;

    NSString *oldETag = _query.eTag;
    UIApplication *app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;

    RESTOperation *op = [_query start];
    self.op = op;
    [op onCompletion:^{
        app.networkActivityIndicatorVisible = NO;
        self.op = nil;

        if (op.error == nil && ![_query.eTag isEqualToString:oldETag])
        {
            NSLog(@"Reloading snippets: etag was %@, is %@", oldETag, _query.eTag);

            NSMutableArray *snippets = [[[NSMutableArray alloc] init] autorelease];
            [snippets addObject:_emptySnippet];

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

            self.snippets = snippets;
        }
    }];
}

@end

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
    NSMutableArray *snippets = [[[NSMutableArray alloc] initWithCapacity:self.query.snippets.count] autorelease];
    NSString *searchString = self.searchString;
    for (Snippet *s in self.query.snippets)
    {
        if ([s.title rangeOfString:searchString options:NSCaseInsensitiveSearch].length > 0 ||
            [s.author rangeOfString:searchString options:NSCaseInsensitiveSearch].length > 0)
        {
            [snippets addObject:s];
        }
    }

    self.snippets = snippets;
}

- (void)subscribe
{
    [self update];
    [self.query addObserver:self forKeyPath:@"snippets" options:0 context:NULL];
}

- (void)unsubscribe
{
    [self.query removeObserver:self forKeyPath:@"snippets" context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (keyPath == @"snippets" && object == self.query)
        [self update];
}

@end
