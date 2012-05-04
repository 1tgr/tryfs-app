//
//  Created by tim on 01/04/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "KeyboardResizeMonitor.h"

@implementation ScrollViewResizeAdapter
{
    UIScrollView *_view;
}

- (id)initWithView:(UIScrollView *)view
{
    self = [super init];
    if (self != nil)
        _view = [view retain];

    return self;
}

- (void)dealloc
{
    [_view release];
    [super dealloc];
}

- (void)resizeViewForKeyboardWithHeight:(CGFloat)height
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, height, 0.0);
    _view.contentInset = contentInsets;
    _view.scrollIndicatorInsets = contentInsets;
}

- (void)setContentOffset:(CGPoint)scrollPoint
{
    [_view setContentOffset:scrollPoint animated:YES];
}

- (void)resetViewSize
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _view.contentInset = contentInsets;
    _view.scrollIndicatorInsets = contentInsets;
}

@end

@implementation KeyboardResizeMonitor
{
    UIView *_view;
    NSObject <KeyboardResizeAdapter> *_adapter;
    UIView *_activeField;
}

@synthesize activeField = _activeField;

- (id)initWithView:(UIView *)view adapter:(NSObject <KeyboardResizeAdapter> *)adapter
{
    self = [super init];
    if (self)
    {
        _view = [view retain];
        _adapter = [adapter retain];
    }

    return self;
}

- (id)initWithView:(UIView *)view scrollView:(UIScrollView *)scrollView
{
    return [self initWithView:view adapter:[[[ScrollViewResizeAdapter alloc] initWithView:scrollView] autorelease]];
}

- (void)dealloc
{
    [_view release];
    [_adapter release];
    [_activeField release];
    [super dealloc];
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];

}

- (void)cancelKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGRect kbRect = [_view convertRect:[[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue] toView:nil];
    CGSize kbSize = kbRect.size;
    [_adapter resizeViewForKeyboardWithHeight:kbRect.size.height];

    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = _view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, _activeField.frame.origin) && [_adapter respondsToSelector:@selector(setContentOffset:)])
    {
        CGPoint scrollPoint = CGPointMake(0.0, _activeField.frame.origin.y-kbSize.height);
        [_adapter setContentOffset:scrollPoint];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    [_adapter resetViewSize];
}

@end