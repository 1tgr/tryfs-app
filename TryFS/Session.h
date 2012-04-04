//
//  Created by tim on 04/04/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


@class CouchDocument;
@class CouchDatabase;
@class RESTOperation;
@class CouchChangeTracker;
@protocol CouchChangeDelegate;

@interface Session : NSObject

@property(strong, readonly) CouchDocument *document;

- (id)initWithDatabase:(CouchDatabase *)database;
- (NSString *)sessionId;
- (RESTOperation *)startWithCode:(NSString *)code;
- (RESTOperation *)send:(NSString *)message;
- (CouchChangeTracker *)changeTrackerWithDelegate:(NSObject <CouchChangeDelegate> *)delegate;

@end