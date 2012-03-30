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
@synthesize descriptionView = _descriptionView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil)
        self.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;

    return self;
}

- (void)dealloc
{
    [_snippet release];
    [_descriptionView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.descriptionView.text = _snippet.description;
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
