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
#import "KeyboardResizeMonitor.h"
#import "Session.h"
#import "SnippetViewModel.h"
#import "InsetLabel.h"
#import "Snippet.h"
#import "ReplViewController.h"

@implementation EditViewController
{
    KeyboardResizeMonitor *_monitor;
    InsetLabel *_descriptionLabel;
}

@synthesize viewModel = _viewModel;

- (void)dealloc
{
    [_monitor release];
    [_descriptionLabel release];
    [_viewModel release];
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
    if (_descriptionLabel == nil)
        return;

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

- (void)updateNavigationItem:(BOOL)animated
{
    SnippetViewModel *viewModel = self.viewModel;
    if (!viewModel.isSplit)
    {
        [self.navigationItem setRightBarButtonItem:viewModel.editBarButtonItem animated:animated];
        self.title = viewModel.snippet.title;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    Snippet *snippet = self.viewModel.snippet;
    UITextView *textView = self.textView;
    if (!self.viewModel.isSplit)
    {
        self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
        _monitor = [[KeyboardResizeMonitor alloc] initWithView:self.view scrollView:textView];
    }

    if (snippet.description != nil && snippet.description.length > 0)
    {
        InsetLabel *label = [[[InsetLabel alloc] init] autorelease];
        label.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        label.inset = UIEdgeInsetsMake(8, 8, 8, 8);
        label.lineBreakMode = UILineBreakModeWordWrap;
        label.numberOfLines = 0;
        label.text = snippet.description;
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
    }

    UIBarButtonItem *runButton = [[[UIBarButtonItem alloc] initWithTitle:@"Run" style:UIBarButtonItemStyleBordered target:self action:@selector(didContinueButton)] autorelease];
    if (snippet.id == nil)
    {
        NSError *error = nil;
        NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDirectory appropriateForURL:nil create:NO error:&error];
        if (error == nil)
        {
            NSString *filename = [snippet.title stringByAppendingPathExtension:@"fsx"];
            NSURL *fileURL = [directoryURL URLByAppendingPathComponent:filename];
            NSString *code = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:&error];

            if (error == nil)
            {
                textView.text = code;
                textView.selectedTextRange = [textView textRangeFromPosition:textView.beginningOfDocument toPosition:textView.beginningOfDocument];
            }
        }

        self.viewModel.editBarButtonItem = runButton;
    }
    else
    {
        CouchDocument *doc = [self.viewModel.database documentWithID:snippet.id];
        UIApplication *app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;

        RESTOperation *op = doc.GET;
        [op onCompletion:^{
            app.networkActivityIndicatorVisible = NO;
            textView.text = [doc propertyForKey:@"code"];
            textView.selectedTextRange = [textView textRangeFromPosition:textView.beginningOfDocument toPosition:textView.beginningOfDocument];
            self.viewModel.editBarButtonItem = runButton;
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [_monitor registerForKeyboardNotifications];
    [self resizeViews];
    [self updateNavigationItem:animated];
    [self.viewModel addObserver:self forKeyPath:@"editBarButtonItem" options:0 context:NULL];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [_monitor cancelKeyboardNotifications];
    [self.viewModel removeObserver:self forKeyPath:@"editBarButtonItem"];

    Snippet *snippet = self.viewModel.snippet;
    if (snippet.id == nil)
    {
        NSError *error = nil;
        NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDirectory appropriateForURL:nil create:YES error:&error];
        if (error == nil)
        {
            NSString *filename = [snippet.title stringByAppendingPathExtension:@"fsx"];
            NSURL *fileURL = [directoryURL URLByAppendingPathComponent:filename];
            [self.textView.text writeToURL:fileURL atomically:NO encoding:NSUTF8StringEncoding error:&error];
        }

        if (error != nil)
            [[[[UIAlertView alloc] initWithTitle:nil message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
    }
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.viewModel && keyPath == @"editBarButtonItem")
        [self updateNavigationItem:YES];
}

- (IBAction)didContinueButton
{
    SnippetViewModel *viewModel = self.viewModel;
    Session *session = viewModel.session;
    if (session == nil)
        session = [[[Session alloc] initWithDatabase:viewModel.database] autorelease];

    session.code = self.textView.text;

    if (session.sessionId == nil)
    {
        UIApplication *app = [UIApplication sharedApplication];
        app.networkActivityIndicatorVisible = YES;

        RESTOperation *op = [session start];
        [op onCompletion:^{
            app.networkActivityIndicatorVisible = NO;
            if (op.error == nil)
            {
                viewModel.session = session;
                [session send:@""];
                viewModel.editBarButtonItem.title = @"Continue";
            }
            else
            {
                viewModel.session = nil;
                [[[[UIAlertView alloc] initWithTitle:op.error.localizedDescription message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
            }
        }];
    }

    if (!viewModel.isSplit)
        [self.navigationController pushViewController:viewModel.replViewController animated:YES];
}

@end
