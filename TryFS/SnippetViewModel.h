//
//  Created by tim on 30/04/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//

@class CouchDatabase;
@class Snippet;
@class Session;
@class EditViewController;
@class ReplViewController;

@interface SnippetViewModel : NSObject

@property(nonatomic, readonly) CouchDatabase *database;
@property(nonatomic, readonly) Snippet *snippet;
@property(nonatomic, readonly) EditViewController *editViewController;
@property(nonatomic, readonly) ReplViewController *replViewController;
@property(nonatomic, retain) Session *session;
@property(nonatomic, retain) UIBarButtonItem *editBarButtonItem;
@property(nonatomic, retain) UIBarButtonItem *replBarButtonItem;

- (id)initWithDatabase:(CouchDatabase *)database snippet:(Snippet *)snippet isSplit:(BOOL)isSplit editViewController:(EditViewController *)editViewController replViewController:(ReplViewController *)replViewController;
- (BOOL)isSplit;

@end