//
//  Created by tim on 18/04/2012.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "BlankViewController.h"

@implementation BlankViewController

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        self.view = [[[UIView alloc] init] autorelease];
        self.view.backgroundColor = [UIColor whiteColor];
    }

    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

@end