//
//  EditViewController.h
//  TryFS
//
//  Created by Tim Robinson on 03/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@class SnippetViewModel;

@interface EditViewController : UIViewController <UITextViewDelegate>

@property(nonatomic, retain) SnippetViewModel *viewModel;

@end
