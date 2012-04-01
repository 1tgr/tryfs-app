//
//  Created by tim on 01/04/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Utils.h"


@implementation Utils

+ (void) moveTextViewForKeyboard:(UIView *)view notification:(NSNotification *)notification up:(BOOL)up
{
    NSDictionary* userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;

    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];

    CGRect newFrame = view.frame;
    CGRect keyboardFrame = [view convertRect:keyboardEndFrame toView:nil];
    //CGRect accessoryFrame = view.inputAccessoryView.frame;
    newFrame.size.height -= (keyboardFrame.size.height - 44) * (up?1:-1);

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    view.frame = newFrame;
    [UIView commitAnimations];
}

@end