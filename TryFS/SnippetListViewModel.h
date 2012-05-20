//
// Created by tim on 20/05/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//

@interface SnippetListViewModel : NSObject

@property(nonatomic, readonly) NSArray *snippets;
@property(nonatomic, readonly) NSString *groupedOn;
@property(nonatomic, readonly) NSArray *sectionOffsets;
@property(nonatomic, readonly) NSArray *sectionTitles;

- (id)initWithSnippets:(NSArray *)snippets groupedOn:(NSString *)groupedOn sectionOffsets:(NSArray *)sectionOffsets sectionTitles:(NSArray *)sectionTitles;
- (id)initWithSnippets:(NSArray *)snippets groupedOn:(NSString *)groupedOn;
- (SnippetListViewModel *)filteredBy:(NSString *)searchString inKeys:(NSSet *)inKeys;

- (id)snippetAtIndexPath:(NSIndexPath *)path;
@end
