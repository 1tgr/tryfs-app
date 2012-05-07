//
//  SnippetViewController.h
//  TryFS
//
//  Created by Tim Robinson on 03/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


@class SnippetDBQuery;

@interface SnippetListViewController : UITableViewController <UISearchDisplayDelegate>

@property(nonatomic, retain) SnippetDBQuery *query;

@end
