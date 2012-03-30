//
//  Created by tim on 30/03/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SnippetInfo.h"


@implementation SnippetInfo
{
}

@synthesize id = _id;
@synthesize rev = _rev;
@synthesize author = _author;
@synthesize title = _title;
@synthesize description = _description;
@synthesize date = _date;

- (id)initWithId:(NSString *)id rev:(NSString *)rev author:(NSString *)author title:(NSString *)title description:(NSString *)description date:(NSDate *)date
{
    self = [super init];
    if (self)
    {
        _id = [id copy];
        _rev = [rev copy];
        _author = [author copy];
        _title = [title copy];
        _description = [description copy];
        _date = [date retain];
    }

    return self;
}

- (void)dealloc
{
    [_id release];
    [_rev release];
    [_author release];
    [_title release];
    [_description release];
    [_date release];
    [super dealloc];
}

@end