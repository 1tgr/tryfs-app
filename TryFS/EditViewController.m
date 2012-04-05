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
#import "Session.h"

@interface EditViewController ()

@property(nonatomic, retain) Session *session;

@end

@implementation EditViewController
{
    KeyboardResizeMonitor *_monitor;
    SnippetInfo *_snippet;
    ReplViewController *_replViewController;
}

@synthesize database = _database;
@synthesize snippet = _snippet;
@synthesize session = _session;

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
    [_session release];
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
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (IBAction)didContinueButton
{
    if (self.session == nil)
        self.session = [[[Session alloc] initWithDatabase:_database] autorelease];

    self.session.code = self.textView.text;

    if (self.session.sessionId == nil)
    {
        UIApplication *app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;

        RESTOperation *op = [self.session start];
        [op onCompletion:^{
            app.networkActivityIndicatorVisible = NO;
            if (op.error == nil)
            {
                [self.session send:@""];
                self.navigationItem.rightBarButtonItem.title = @"Continue";
                _replViewController.session = self.session;
            }
            else
            {
                self.session = nil;
                [[[[UIAlertView alloc] initWithTitle:op.error.localizedDescription message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
            }
        }];
    }

    [self.navigationController pushViewController:_replViewController animated:YES];
}

@end
