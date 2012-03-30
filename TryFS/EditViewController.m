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
    ReplViewController *controller = [[[ReplViewController alloc] initWithNibName:@"ReplViewController" bundle:nil] autorelease];
    controller.title = @"REPL";
    [self.navigationController pushViewController:controller animated:YES];
}

@end
