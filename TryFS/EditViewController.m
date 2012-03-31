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

@interface EditViewController ()

@property(nonatomic, retain) CouchDocument *sessionDoc;

@end

@implementation EditViewController
{
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
    self.navigationController.toolbarHidden = NO;

    UIBarButtonItem *space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
    UIBarButtonItem *editButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(didEditButton)] autorelease];
    UIBarButtonItem *runButton = [[[UIBarButtonItem alloc] initWithTitle:@"Run" style:UIBarButtonItemStyleBordered target:self action:@selector(didRunButton)] autorelease];
    UIBarButtonItem *continueButton = [[[UIBarButtonItem alloc] initWithTitle:@"Continue" style:UIBarButtonItemStyleBordered target:self action:@selector(didContinueButton)] autorelease];
    self.toolbarItems = [NSArray arrayWithObjects:editButton, space, runButton, continueButton, nil];

    self.textView.inputAccessoryView = self.navigationController.toolbar;
    [self.textView becomeFirstResponder];

    if (_snippet.id != nil)
    {
        CouchDocument *doc = [_database documentWithID:_snippet.id];
        UIApplication *app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;

        RESTOperation *op = doc.GET;
        [op onCompletion:^{
            app.networkActivityIndicatorVisible = NO;
            self.textView.text = [doc propertyForKey:@"code"];
        }];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
        NSDictionary *props =
            [NSMutableDictionary dictionaryWithObjectsAndKeys:
                @"session", @"type",
                [NSArray arrayWithObject:@"init"], @"initNames",
                [NSArray arrayWithObject:code], @"initTexts",
                nil];

        self.sessionDoc = [_database untitledDocument];

        UIApplication *app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;

        RESTOperation *op = [self.sessionDoc putProperties:props];
        [op onCompletion:^{
            app.networkActivityIndicatorVisible = NO;
            if (op.error == nil)
                [controller subscribeToSession:self.sessionDoc];
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

@end
