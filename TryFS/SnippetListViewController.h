//
//  SnippetViewController.h
//  TryFS
//
//  Created by Tim Robinson on 03/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



@class CouchDatabase;

@interface SnippetListViewController : UITableViewController

@property(nonatomic, retain) CouchDatabase *database;
@end
