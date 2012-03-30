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

@implementation EditViewController
{
    SnippetInfo *_snippet;
}

@synthesize actionButton = _actionButton;
@synthesize runButton = _runButton;
@synthesize snippet = _snippet;

- (void)dealloc
{
    [_actionButton release];
    [_runButton release];
    [_snippet release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = _snippet.title;
    [self.view becomeFirstResponder];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.runButton, self.actionButton, nil];
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
    case 0:
        [self showReplWithReset:YES];
        break;

    case 1:
        [self showReplWithReset:NO];
        break;
    }
}

- (IBAction)didActionButton
{
    UIActionSheet *sheet = [[[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"Run", @"Continue", nil] autorelease];
    [sheet showFromBarButtonItem:_runButton animated:YES];
}

- (IBAction)didRunButton
{
    [self showReplWithReset:YES];
}

@end
