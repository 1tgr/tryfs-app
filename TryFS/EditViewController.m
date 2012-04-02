//
//  EditViewController.m
//  TryFS
//
//  Created by Tim Robinson on 03/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CouchCocoa.h"
#import "EditViewController.h"
#import "ReplViewController.h"
#import "SnippetInfo.h"
#import "KeyboardResizeMonitor.h"

@interface EditViewController ()

@property(nonatomic, retain) CouchDocument *sessionDoc;

@end

@implementation EditViewController
{
    KeyboardResizeMonitor *_monitor;
    SnippetInfo *_snippet;
    ReplViewController *_replViewController;
}

@synthesize database = _database;
@synthesize snippet = _snippet;
@synthesize sessionDoc = _sessionDoc;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
        _replViewController = [[ReplViewController alloc] initWithNibName:@"ReplViewController" bundle:nil];

    return self;
}

- (void)dealloc
{
    [_replViewController release];
    [_database release];
    [_snippet release];
    [_sessionDoc release];
    [_monitor release];
    [super dealloc];
}

- (UITextView *)textView
{
    return (UITextView *) self.view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _snippet.title;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Run" style:UIBarButtonItemStyleBordered target:self action:@selector(didContinueButton)] autorelease];

    _monitor = [[KeyboardResizeMonitor alloc] initWithView:self.view scrollView:self.textView];

    if (_snippet.id != nil)
    {
        CouchDocument *doc = [_database documentWithID:_snippet.id];
        UIApplication *app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;

        RESTOperation *op = doc.GET;
        [op onCompletion:^{
            app.networkActivityIndicatorVisible = NO;

            UITextView *textView = self.textView;
            textView.text = [doc propertyForKey:@"code"];
            textView.selectedTextRange = [textView textRangeFromPosition:textView.beginningOfDocument toPosition:textView.beginningOfDocument];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [_monitor registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_monitor cancelKeyboardNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)didContinueButton
{
    if (self.sessionDoc == nil)
    {
        NSString *code = self.textView.text;
        NSDictionary *sessionProps =
            [NSDictionary dictionaryWithObjectsAndKeys:
                @"session", @"type",
                [NSArray arrayWithObject:@"init"], @"initNames",
                [NSArray arrayWithObject:code], @"initTexts",
                nil];

        self.sessionDoc = [_database untitledDocument];

        UIApplication *app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;

        RESTOperation *op = [self.sessionDoc putProperties:sessionProps];
        [op onCompletion:^{
            app.networkActivityIndicatorVisible = NO;
            if (op.error == nil)
            {
                NSDictionary *messageProps =
                    [NSDictionary dictionaryWithObjectsAndKeys:
                        @"in", @"messageType",
                        @"", @"message",
                        self.sessionDoc.documentID, @"sessionId",
                        nil];

                CouchDocument *messageDoc = [_database untitledDocument];
                [messageDoc putProperties:messageProps];

                self.navigationItem.rightBarButtonItem.title = @"Continue";
                [_replViewController subscribeToSession:self.sessionDoc];
            }
            else
            {
                self.sessionDoc = nil;
                [[[[UIAlertView alloc] initWithTitle:op.error.localizedDescription message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
            }
        }];
    }

    [self.navigationController pushViewController:_replViewController animated:YES];
}

@end
