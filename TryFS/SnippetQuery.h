//
//  Created by tim on 15/04/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@class CouchDatabase;

@interface SnippetQuery : NSObject

@property(readonly, retain) NSArray *snippets;
@property(readonly, retain) CouchDatabase *database;

- (id)initWithDatabase:(CouchDatabase *)database;
- (void)refresh;

@end