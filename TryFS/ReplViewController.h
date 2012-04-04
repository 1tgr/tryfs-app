//
//  ReplViewController.h
//  TryFS
//
//  Created by Tim Robinson on 03/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CouchChangeTracker.h"

@class CouchDocument;

@interface ReplViewController : UITableViewController <CouchChangeDelegate>

@property(nonatomic, retain) IBOutlet UITextField *textField;
@property(nonatomic, retain) IBOutlet UITableViewCell *textFieldCell;

-(void)subscribeToSession:(CouchDocument *)sessionDoc;

@end
