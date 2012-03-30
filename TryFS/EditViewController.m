//
//  EditViewController.m
//  TryFS
//
//  Created by Tim Robinson on 03/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EditViewController.h"
#import "ReplViewController.h"
#import "SnippetInfo.h"
#import "SnippetDetailViewController.h"

@implementation EditViewController
{
    SnippetInfo *_snippet;
}

@synthesize snippet = _snippet;

- (void)dealloc
{
    [_snippet release];
    [super dealloc];
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

    UITextView *textView = (UITextView *) self.view;
    textView.inputAccessoryView = self.navigationController.toolbar;
    [self.view becomeFirstResponder];
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
    [self.navigationController pushViewController:[[[ReplViewController alloc] initWithNibName:@"ReplViewController" bundle:nil] autorelease] animated:YES];
}

- (IBAction)didEditButton
{
    SnippetDetailViewController *controller = [[[SnippetDetailViewController alloc] initWithNibName:@"SnippetDetailViewController" bundle:nil] autorelease];
    controller.snippet = _snippet;
    [self presentViewController:controller animated:YES completion:nil];
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
