//
//  EditViewController.m
//  TryFS
//
//  Created by Tim Robinson on 03/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CouchCocoa.h"
#import "EditViewController.h"
#import "ReplViewController.h"
#import "SnippetInfo.h"
#import "KeyboardResizeMonitor.h"
#import "Session.h"
#import "InsetLabel.h"

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

static UIColor *times(UIColor *colour, CGFloat f)
{
    CGFloat red, green, blue, alpha;
    [colour getRed:&red green:&green blue:&blue alpha:&alpha];
    red *= f;
    green *= f;
    blue *= f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _snippet.title;
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Run" style:UIBarButtonItemStyleBordered target:self action:@selector(didContinueButton)] autorelease];

    UITextView *textView = self.textView;
    InsetLabel *label = [[[InsetLabel alloc] init] autorelease];
    label.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    label.inset = UIEdgeInsetsMake(8, 8, 8, 8);
    label.lineBreakMode = UILineBreakModeWordWrap;
    label.numberOfLines = 0;
    label.text = _snippet.description;
    label.textColor = textView.textColor;

    UIColor *colour = textView.backgroundColor;
    label.backgroundColor = [UIColor clearColor];

    CALayer *layer = label.layer;
    layer.backgroundColor = times(colour, 0.75).CGColor;
    layer.shadowColor = times(colour, 0.5).CGColor;
    layer.masksToBounds = NO;
    layer.cornerRadius = 8;
    [textView addSubview:label];

    UIEdgeInsets margin = UIEdgeInsetsMake(4, 4, 4, 4);
    CGRect frame = { { 0, 0 }, textView.frame.size };
    frame = UIEdgeInsetsInsetRect(frame, margin);

    CGFloat width = frame.size.width;
    label.frame = frame;
    [label sizeToFit];
    frame = label.frame;
    frame.size.width = width;
    frame.origin.y = margin.top - frame.size.height;
    label.frame = frame;

    UIEdgeInsets inset = textView.contentInset;
    inset.top += frame.size.height;
    textView.contentInset = inset;

    _monitor = [[KeyboardResizeMonitor alloc] initWithView:self.view scrollView:textView];

    if (_snippet.id != nil)
    {
        CouchDocument *doc = [_database documentWithID:_snippet.id];
        UIApplication *app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;

        RESTOperation *op = doc.GET;
        [op onCompletion:^{
            app.networkActivityIndicatorVisible = NO;
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
