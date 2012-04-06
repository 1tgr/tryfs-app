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
    InsetLabel *_descriptionLabel;
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
    [_descriptionLabel release];
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

- (void)resizeViews
{
    UITextView *textView = self.textView;
    UIEdgeInsets margin = UIEdgeInsetsMake(4, 4, 8, 4);
    CGRect frame = { { 0, 0 }, textView.frame.size };
    frame = UIEdgeInsetsInsetRect(frame, margin);

    UIEdgeInsets padding = _descriptionLabel.inset;
    frame.size.width -= padding.left + padding.right;
    frame.size.height -= padding.top + padding.bottom;
    frame.size.height = [_descriptionLabel.text sizeWithFont:_descriptionLabel.font constrainedToSize:frame.size lineBreakMode:_descriptionLabel.lineBreakMode].height;
    frame.size.width += padding.left + padding.right;
    frame.size.height += padding.top + padding.bottom;
    frame.origin.y = -(frame.size.height + margin.bottom);
    _descriptionLabel.frame = frame;

    UIEdgeInsets inset = textView.contentInset;
    inset.top = margin.top - frame.origin.y;
    textView.contentInset = inset;
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
    layer.shadowOpacity = 1;
    layer.shadowOffset = CGSizeMake(0, 1);
    layer.masksToBounds = NO;
    layer.cornerRadius = 8;
    [textView addSubview:label];

    _descriptionLabel = [label retain];
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
    [self resizeViews];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_monitor cancelKeyboardNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self resizeViews];
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
