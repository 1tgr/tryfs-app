//
//  Created by tim on 04/04/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "CouchCocoa.h"
#import "Session.h"

@implementation Session

@synthesize document = _document;

- (id)initWithDatabase:(CouchDatabase *)database
{
    self = [super init];
    if (self != nil)
        _document = [database untitledDocument];

    return self;
}

- (NSString *)sessionId
{
    return _document.documentID;
}

- (RESTOperation *)startWithCode:(NSString *)code
{
    NSDictionary *sessionProps =
            [NSDictionary dictionaryWithObjectsAndKeys:
                @"session", @"type",
                [NSArray arrayWithObject:@"init"], @"initNames",
                [NSArray arrayWithObject:code], @"initTexts",
                nil];

    return [_document putProperties:sessionProps];
}

- (RESTOperation *)send:(NSString *)message
{
    NSDictionary *messageProps =
            [NSDictionary dictionaryWithObjectsAndKeys:
                @"in", @"messageType",
                message, @"message",
                self.sessionId, @"sessionId",
                nil];

    CouchDocument *messageDoc = [_document.database untitledDocument];
    return [messageDoc putProperties:messageProps];
}

- (CouchChangeTracker *)changeTrackerWithDelegate:(NSObject <CouchChangeDelegate> *)delegate
{
    CouchChangeTracker *tracker = [[[CouchChangeTracker alloc] initWithDatabase:_document.database delegate:delegate] autorelease];
    tracker.lastSequenceNumber = _document.database.lastSequenceNumber;
    tracker.filter = @"app/session";
    [tracker.filterParams setObject:self.sessionId forKey:@"sessionId"];
    return tracker;
}

@end