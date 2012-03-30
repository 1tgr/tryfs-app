//
//  EditViewController.m
//  TryFS
//
//  Created by Tim Robinson on 03/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EditViewController.h"
#import "ReplViewController.h"

@interface EditViewController ()

@end

@implementation EditViewController
{
}

@synthesize runButton = _runButton;

- (void)dealloc
{
    [_runButton release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Snippet";
    [self.view becomeFirstResponder];
    self.navigationItem.rightBarButtonItem = self.runButton;
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

- (IBAction)didRunButton
{
    [self.navigationController pushViewController:[[[ReplViewController alloc] initWithNibName:@"ReplViewController" bundle:nil] autorelease] animated:YES];
}

@end
