//
//  AppDelegate.m
//  TryFS
//
//  Created by Tim Robinson on 03/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CouchCocoa.h"
#import "AppDelegate.h"
#import "SnippetViewController.h"
#import "QuickDialog.h"

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

+ (QLabelElement *)linkElementWithTitle:(NSString *)title url:(NSURL *)url image:(UIImage *)image
{
    QLabelElement *label = [[[QLabelElement alloc] initWithTitle:title Value:nil] autorelease];
    label.image = image;
    label.controllerAction = @"";
    label.onSelected = ^{
        [[UIApplication sharedApplication] openURL:url];
    };

    return label;
}

+ (QRootElement *)aboutForm:(UINavigationController *)navigationController snippetsController:(SnippetViewController *)snippetsController
{
    QLabelElement *snippetsElement = [[[QLabelElement alloc] initWithTitle:@"Snippets" Value:nil] autorelease];
    snippetsElement.controllerAction = @"";
    snippetsElement.onSelected = ^{
        [navigationController pushViewController:snippetsController animated:YES];
    };

    QSection *section = [[[QSection alloc] initWithTitle:nil] autorelease];
    [section addElement:snippetsElement];

    QLabelElement *couchdbElement = [[[QLabelElement alloc] initWithTitle:@"Powered by CouchDB" Value:nil] autorelease];
    couchdbElement.image = [UIImage imageNamed:@"couchdb.png"];

    QSection *aboutSection = [[[QSection alloc] initWithTitle:@"About Try F#"] autorelease];
    [aboutSection addElement:[AppDelegate linkElementWithTitle:@"timrobinson/try-fsharp" url:[NSURL URLWithString:@"https://github.com/timrobinson/try-fsharp"] image:[UIImage imageNamed:@"github.png"]]];
    [aboutSection addElement:[AppDelegate linkElementWithTitle:@"@tim_g_robinson" url:[NSURL URLWithString:@"http://twitter.com/tim_g_robinson"] image:[UIImage imageNamed:@"twitter.png"]]];
    [aboutSection addElement:[AppDelegate linkElementWithTitle:@"tim@partario.com" url:[NSURL URLWithString:@"mailto:?to=tim@partario.com&subject=Try%20F#"] image:[UIImage imageNamed:@"mail.png"]]];
    [aboutSection addElement:couchdbElement];

    QRootElement *root = [[[QRootElement alloc] init] autorelease];
    root.title = @"Try F#";
    root.grouped = YES;
    [root addSection:section];
    [root addSection:aboutSection];
    return root;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    CouchServer *server = [[[CouchServer alloc] initWithURL:[NSURL URLWithString:@"http://tryfs.net"]] autorelease];
    SnippetViewController *snippetsController = [[[SnippetViewController alloc] initWithNibName:@"SnippetViewController" bundle:nil] autorelease];
    snippetsController.database = [server databaseNamed:@"tryfs"];

    UINavigationController *navigationController = [[[UINavigationController alloc] init] autorelease];
    navigationController.navigationBar.tintColor = [UIColor colorWithRed:1 green:0.7 blue:0 alpha:1];

    QRootElement *root = [AppDelegate aboutForm:navigationController snippetsController:snippetsController];
    QuickDialogController *aboutController = [[[QuickDialogController alloc] initWithRoot:root] autorelease];
    [navigationController pushViewController:aboutController animated:NO];
    [navigationController pushViewController:snippetsController animated:NO];

    UIWindow *window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    window.rootViewController = navigationController;
    [window makeKeyAndVisible];
    self.window = window;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.

}

@end