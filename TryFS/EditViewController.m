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
#import "SnippetDetailViewController.h"
#import "KeyboardResizeMonitor.h"

@interface EditViewController ()

@property(nonatomic, retain) CouchDocument *sessionDoc;

@end

@implementation EditViewController
{
    KeyboardResizeMonitor *_monitor;
    SnippetInfo *_snippet;
}

@synthesize database = _database;
@synthesize snippet = _snippet;
@synthesize sessionDoc = _sessionDoc;

- (void)dealloc
{
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

    /*UIBarButtonItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    UIBarButtonItem *editButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(didEditButton)] autorelease];
    UIBarButtonItem *runButton = [[[UIBarButtonItem alloc] initWithTitle:@"Run" style:UIBarButtonItemStyleBordered target:self action:@selector(didRunButton)] autorelease];*/
    UIBarButtonItem *continueButton = [[[UIBarButtonItem alloc] initWithTitle:@"Continue" style:UIBarButtonItemStyleBordered target:self action:@selector(didContinueButton)] autorelease];
    /*self.toolbarItems = [NSArray arrayWithObjects:editButton, space, runButton, continueButton, nil];*/
    self.navigationItem.rightBarButtonItem = continueButton;

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

- (void)showReplWithReset:(BOOL)reset
{
    ReplViewController *controller = [[[ReplViewController alloc] initWithNibName:@"ReplViewController" bundle:nil] autorelease];

    if (reset || self.sessionDoc == nil)
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

                [controller subscribeToSession:self.sessionDoc];
            }
            else
            {
                self.sessionDoc = nil;
                [[[[UIAlertView alloc] initWithTitle:op.error.localizedDescription message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
            }
        }];
    }
    else
        [controller subscribeToSession:self.sessionDoc];

    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)didEditButton
{
    SnippetDetailViewController *controller = [[[SnippetDetailViewController alloc] initWithNibName:@"SnippetDetailViewController" bundle:nil] autorelease];
    controller.snippet = _snippet;

    UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (IBAction)didRunButton
{
    [self showReplWithReset:YES];
}

- (IBAction)didContinueButton
{
    [self showReplWithReset:NO];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    //self.textView.inputAccessoryView = self.navigationController.toolbar;
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    //self.textView.inputAccessoryView = nil;
}

@end
