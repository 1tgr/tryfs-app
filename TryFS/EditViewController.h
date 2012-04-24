//
//  EditViewController.h
//  TryFS
//
//  Created by Tim Robinson on 03/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@class Snippet;
@class CouchDatabase;

@interface EditViewController : UIViewController <UITextViewDelegate, UISplitViewControllerDelegate>

@property(nonatomic, retain) CouchDatabase *database;
@property(nonatomic, retain) Snippet *snippet;

@end
