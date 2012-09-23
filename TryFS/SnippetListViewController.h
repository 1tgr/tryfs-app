//
//  SnippetViewController.h
//  TryFS
//
//  Created by Tim Robinson on 03/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


@class SnippetDBQuery;

@interface SnippetListViewController : UIViewController <UISearchDisplayDelegate, UITabBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, retain) IBOutlet UITableView *tableView;
@property(nonatomic, retain) IBOutlet UITabBar *tabBar;
@property(nonatomic, retain) IBOutlet UITabBarItem *recentTabBarItem;
@property(nonatomic, retain) IBOutlet UITabBarItem *authorTabBarItem;
@property(nonatomic, retain) SnippetDBQuery *query;

@end
