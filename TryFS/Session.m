//
//  Created by tim on 04/04/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "CouchCocoa.h"
#import "Session.h"

@implementation Session
{
    NSString *_code;
}

@synthesize document = _document;
@synthesize code = _code;

- (id)initWithDatabase:(CouchDatabase *)database
{
    self = [super init];
    if (self != nil)
    {
        _document = [[database untitledDocument] retain];
        _code = @"";
    }

    return self;
}

- (void)dealloc
{
    [_code release];
    [_document release];
    [super dealloc];
}

- (NSString *)sessionId
{
    return _document.documentID;
}

- (RESTOperation *)start
{
    NSDictionary *sessionProps =
            [NSDictionary dictionaryWithObjectsAndKeys:
                @"session", @"type",
                [NSArray arrayWithObject:@"init"], @"initNames",
                [NSArray arrayWithObject:_code], @"initTexts",
                nil];

    return [_document putProperties:sessionProps];
}

- (RESTOperation *)reset
{
    CouchDatabase *database = [[_document.database retain] autorelease];
    [_document release];
    _document = [[database untitledDocument] retain];
    return [self start];
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