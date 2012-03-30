//
//  SnippetDetailViewController.h
//  TryFS
//
//  Created by Tim Robinson on 03/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@class SnippetInfo;

@interface SnippetDetailViewController : UIViewController

@property(nonatomic, retain) SnippetInfo *snippet;
@property(nonatomic, retain) IBOutlet UIBarButtonItem *doneButton;

-(IBAction)didDoneButton;

@end
