//
//  EditViewController.h
//  TryFS
//
//  Created by Tim Robinson on 03/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@class SnippetInfo;

@interface EditViewController : UIViewController <UIActionSheetDelegate>

@property(nonatomic, retain) SnippetInfo *snippet;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *actionButton;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *runButton;

-(IBAction)didActionButton;
-(IBAction)didRunButton;

@end
