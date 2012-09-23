//
// Created by tim on 20/05/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "SnippetQuery.h"

@interface SnippetFilterQuery : SnippetQuery

@property(nonatomic, retain) SnippetQuery *query;
@property(nonatomic, retain) NSString *searchString;
- (void)subscribe;
- (void)unsubscribe;

@end