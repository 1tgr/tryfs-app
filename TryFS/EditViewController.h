//
//  EditViewController.h
//  TryFS
//
//  Created by Tim Robinson on 03/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@class SnippetInfo;
@class CouchDatabase;

@interface EditViewController : UIViewController

@property(nonatomic, retain) CouchDatabase *database;
@property(nonatomic, retain) SnippetInfo *snippet;

@end
