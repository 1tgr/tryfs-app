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
#import "Crittercism.h"
#import "BlankViewController.h"

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

    QLabelElement *feedbackElement = [[[QLabelElement alloc] initWithTitle:@"Feedback" Value:nil] autorelease];
    feedbackElement.image = [UIImage imageNamed:@"mail.png"];
    feedbackElement.controllerAction = @"";
    feedbackElement.onSelected = ^{
        [Crittercism showCrittercism:navigationController];
    };

    QLabelElement *couchdbElement = [[[QLabelElement alloc] initWithTitle:@"Powered by CouchDB" Value:nil] autorelease];
    couchdbElement.image = [UIImage imageNamed:@"couchdb.png"];

    QSection *aboutSection = [[[QSection alloc] initWithTitle:@"About Try F#"] autorelease];
    [aboutSection addElement:[AppDelegate linkElementWithTitle:@"timrobinson/try-fsharp" url:[NSURL URLWithString:@"https://github.com/timrobinson/try-fsharp"] image:[UIImage imageNamed:@"github.png"]]];
    [aboutSection addElement:[AppDelegate linkElementWithTitle:@"@tim_g_robinson" url:[NSURL URLWithString:@"http://twitter.com/tim_g_robinson"] image:[UIImage imageNamed:@"twitter.png"]]];
    [aboutSection addElement:feedbackElement];
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
    [Crittercism initWithAppID:@"4f7f54f6b093150e1700003a"
                        andKey:@"3bbskiysvyotxfhkr7omqp4tpwme"
                     andSecret:@"iv8nhmaqdoekq6zrwgnxxco1lc3lt4ty"];

    CouchServer *server = [[[CouchServer alloc] initWithURL:[NSURL URLWithString:@"http://tryfs.net"]] autorelease];
    SnippetViewController *snippetsController = [[[SnippetViewController alloc] initWithNibName:@"SnippetViewController" bundle:nil] autorelease];
    snippetsController.database = [server databaseNamed:@"tryfs"];

    UIColor *tintColour = [UIColor colorWithRed:1 green:0.7 blue:0 alpha:1];
    UINavigationController *menuNavigationController = [[[UINavigationController alloc] init] autorelease];
    menuNavigationController.navigationBar.tintColor = tintColour;

    QRootElement *root = [AppDelegate aboutForm:menuNavigationController snippetsController:snippetsController];
    QuickDialogController *aboutController = [[[QuickDialogController alloc] initWithRoot:root] autorelease];
    [menuNavigationController pushViewController:aboutController animated:NO];
    [menuNavigationController pushViewController:snippetsController animated:NO];

    UIViewController *rootViewController;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        UINavigationController *editNavigationController = [[[UINavigationController alloc] initWithRootViewController:[[[BlankViewController alloc] init] autorelease]] autorelease];
        editNavigationController.navigationBar.tintColor = tintColour;

        UISplitViewController *splitViewController = [[[UISplitViewController alloc] init] autorelease];
        splitViewController.viewControllers = [NSArray arrayWithObjects:menuNavigationController, editNavigationController, nil];
        rootViewController = splitViewController;
    }
    else
        rootViewController = menuNavigationController;

    UIWindow *window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    window.rootViewController = rootViewController;
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