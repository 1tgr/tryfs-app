//
//  ReplViewController.h
//  TryFS
//
//  Created by Tim Robinson on 03/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CouchChangeTracker.h"

@class CouchDocument;
@class Session;
@class Snippet;

@interface ReplViewController : UITableViewController <UITextFieldDelegate, CouchChangeDelegate>

@property(nonatomic, retain) IBOutlet UITextField *textField;
@property(nonatomic, retain) IBOutlet UITableViewCell *textFieldCell;
@property(nonatomic, retain) Snippet *snippet;
@property(nonatomic, retain) Session *session;

@end
