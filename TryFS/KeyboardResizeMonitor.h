//
//  Created by tim on 01/04/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


@interface KeyboardResizeMonitor : NSObject

@property(nonatomic, retain) UIView *activeField;


- (id)initWithView:(UIView *)view scrollView:(UIScrollView *)scrollView;


- (void)registerForKeyboardNotifications;
- (void)cancelKeyboardNotifications;

@end