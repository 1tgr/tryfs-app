//
//  SnippetDetailViewController.m
//  TryFS
//
//  Created by Tim Robinson on 03/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SnippetDetailViewController.h"
#import "SnippetInfo.h"

@implementation SnippetDetailViewController

@synthesize snippet = _snippet;
@synthesize doneButton = _doneButton;

- (void)dealloc
{
    [_snippet release];
    [_doneButton release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = _doneButton;
    self.title = _snippet.title;

    UITextView *textView = (UITextView *) self.view;
    textView.text = [_snippet.description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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

- (IBAction)didDoneButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
