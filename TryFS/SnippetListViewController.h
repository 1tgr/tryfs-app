//
//  SnippetViewController.h
//  TryFS
//
//  Created by Tim Robinson on 03/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


@class SnippetQuery;

@interface SnippetListViewController : UITableViewController <UISearchDisplayDelegate>

@property(nonatomic, retain) SnippetQuery *query;

@end
