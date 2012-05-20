//
// Created by tim on 20/05/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "SnippetListViewModel.h"

@implementation SnippetListViewModel

@synthesize snippets = _snippets;
@synthesize groupedOn = _groupedOn;
@synthesize sectionOffsets = _sectionOffsets;
@synthesize sectionTitles = _sectionTitles;

- (id)initWithSnippets:(NSArray *)snippets groupedOn:(NSString *)groupedOn sectionOffsets:(NSArray *)sectionOffsets sectionTitles:(NSArray *)sectionTitles
{
    self = [super init];
    if (self != nil)
    {
        _snippets = [snippets retain];
        _groupedOn = [groupedOn retain];
        _sectionOffsets = [sectionOffsets retain];
        _sectionTitles = [sectionTitles retain];
    }

    return self;
}

- (id)initWithSnippets:(NSArray *)snippets groupedOn:(NSString *)groupedOn
{
    NSMutableArray *sectionOffsets, *sectionTitles;
    if (groupedOn == nil)
    {
        sectionOffsets = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:snippets.count], nil];
        sectionTitles = [NSMutableArray arrayWithObjects:@"", nil];
    }
    else
    {
        sectionOffsets = [[[NSMutableArray alloc] init] autorelease];
        sectionTitles = [[[NSMutableArray alloc] init] autorelease];

        NSUInteger i = 0;
        NSString *lastKey = nil;

        for (NSObject *snippet in snippets)
        {
            NSString *key = [snippet valueForKey:groupedOn];
            if (![key isEqualToString:lastKey])
            {
                lastKey = key;
                [sectionOffsets addObject:[NSNumber numberWithUnsignedInt:i]];
                [sectionTitles addObject:key];
            }

            i++;
        }

        [sectionOffsets addObject:[NSNumber numberWithUnsignedInt:i]];
    }

    return [self initWithSnippets:snippets groupedOn:groupedOn sectionOffsets:sectionOffsets sectionTitles:sectionTitles];
}

- (SnippetListViewModel *)filteredBy:(NSString *)searchString inKeys:(NSSet *)inKeys
{
    NSMutableArray *snippets = [[[NSMutableArray alloc] initWithCapacity:self.snippets.count] autorelease];
    for (NSObject *s in self.snippets)
    {
        for (NSString *key in inKeys)
        {
            NSString *value = [s valueForKey:key];
            if ([value rangeOfString:searchString options:NSCaseInsensitiveSearch].length > 0)
            {
                [snippets addObject:s];
                break;
            }
        }
    }

    return [[[SnippetListViewModel alloc] initWithSnippets:snippets groupedOn:self.groupedOn] autorelease];
}

- (void)dealloc
{
    [_snippets release];
    [_groupedOn release];
    [_sectionOffsets release];
    [_sectionTitles release];
    [super dealloc];
}

- (id)snippetAtIndexPath:(NSIndexPath *)path
{
    NSNumber *sectionOffset = [self.sectionOffsets objectAtIndex:(NSUInteger) path.section];
    NSUInteger index = sectionOffset.unsignedIntegerValue + path.row;
    return [self.snippets objectAtIndex:index];
}

@end