//
//  Created by tim on 01/04/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


@protocol KeyboardResizeAdapter

- (void)resizeViewForKeyboardWithHeight:(CGFloat)height;
- (void)resetViewSize;

@optional
- (void)setContentOffset:(CGPoint)scrollPoint;

@end

@interface ScrollViewResizeAdapter : NSObject <KeyboardResizeAdapter>

- (id)initWithView:(UIScrollView*)view;

@end

@interface KeyboardResizeMonitor : NSObject

@property(nonatomic, retain) UIView *activeField;

- (id)initWithView:(UIView *)view adapter:(NSObject <KeyboardResizeAdapter> *)adapter;
- (id)initWithView:(UIView *)view scrollView:(UIScrollView *)scrollView;
- (void)registerForKeyboardNotifications;
- (void)cancelKeyboardNotifications;

@end