//
// Created by tim on 20/05/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "SnippetQuery.h"

@class CouchDatabase;

typedef enum
{
    SnippetQuerySortModeRecent = 0,
    SnippetQuerySortModeAuthor
} SnippetQuerySortMode;

@interface SnippetDBQuery : SnippetQuery

@property(nonatomic, readonly) CouchDatabase *database;
@property(nonatomic, assign) SnippetQuerySortMode sortMode;
- (id)initWithDatabase:(CouchDatabase *)database;
- (void)refreshWithActivityOn:(UIApplication *)app;

@end
