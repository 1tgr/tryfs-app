//
//  Created by tim on 01/04/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "KeyboardResizeMonitor.h"

static int nextIndex = 1;

@implementation KeyboardResizeMonitor
{
    int _index;
    UIView *_view;
    UIScrollView *_scrollView;
    UIView *_activeField;
}

@synthesize activeField = _activeField;

- (id)initWithView:(UIView *)view scrollView:(UIScrollView *)scrollView
{
    self = [super init];
    if (self)
    {
        _view = [view retain];
        _scrollView = [scrollView retain];
        _index = nextIndex++;
    }

    return self;
}

- (void)dealloc
{
    [_view release];
    [_scrollView release];
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
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;

    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = _view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, _activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, _activeField.frame.origin.y-kbSize.height);
        [_scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _scrollView.contentInset = contentInsets;
    _scrollView.scrollIndicatorInsets = contentInsets;
}

@end