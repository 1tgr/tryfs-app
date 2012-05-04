//
//  Created by tim on 30/04/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "MGSplitViewController.h"
#import "KeyboardResizeMonitor.h"

@class SnippetViewModel;

@interface EditReplSplitViewController : MGSplitViewController <KeyboardResizeAdapter, MGSplitViewControllerDelegate>

@property(nonatomic, retain) SnippetViewModel *viewModel;

@end