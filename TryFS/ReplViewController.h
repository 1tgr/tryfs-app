//
//  ReplViewController.h
//  TryFS
//
//  Created by Tim Robinson on 03/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import "CouchUITableSource.h"

@class CouchDocument;

@interface ReplViewController : UIViewController <CouchUITableDelegate>

@property(nonatomic, retain) IBOutlet UITextField *textField;

-(void)subscribeToSession:(CouchDocument *)sessionDoc;

@end
