//
//  Created by tim on 06/04/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "InsetLabel.h"


@implementation InsetLabel
{
    UIEdgeInsets _inset;
}

- (UIEdgeInsets)inset
{
    return _inset;
}

- (void)setInset:(UIEdgeInsets)inset
{
    _inset = inset;
    [self setNeedsDisplay];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, _inset) limitedToNumberOfLines:numberOfLines];
}

- (void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, _inset)];
}

@end