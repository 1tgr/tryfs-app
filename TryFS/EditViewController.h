//
//  EditViewController.h
//  TryFS
//
//  Created by Tim Robinson on 03/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@class SnippetInfo;

@interface EditViewController : UIViewController

@property(nonatomic, retain) SnippetInfo *snippet;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *runButton;

-(IBAction)didRunButton;

@end
