//
//  Created by tim on 15/04/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>

@class CouchDatabase;

@interface SnippetQuery : NSObject

@property(nonatomic, readonly) NSArray *snippets;

@end

@interface SnippetDBQuery : SnippetQuery

@property(nonatomic, readonly) CouchDatabase *database;

- (id)initWithDatabase:(CouchDatabase *)database;
- (void)refresh;

@end

@interface SnippetFilterQuery : SnippetQuery

@property(nonatomic, retain) SnippetQuery *query;
@property(nonatomic, retain) NSString *searchString;
- (void)subscribe;
- (void)unsubscribe;

@end