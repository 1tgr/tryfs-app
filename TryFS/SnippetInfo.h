//
//  Created by tim on 30/03/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface SnippetInfo : NSObject

@property(retain, readonly) NSString *id;
@property(retain, readonly) NSString *rev;
@property(retain, readonly) NSString *title;
@property(retain, readonly) NSDate *date;
@property(retain, readonly) NSString *author;
@property(retain, readonly) NSString *description;

- (id)initWithId:(NSString *)id rev:(NSString *)rev author:(NSString *)author title:(NSString *)title description:(NSString *)description date:(NSDate *)date;


@end