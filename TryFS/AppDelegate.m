//
//  AppDelegate.m
//  TryFS
//
//  Created by Tim Robinson on 03/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CouchCocoa.h"
#import "AppDelegate.h"
#import "SnippetListViewController.h"
#import "QuickDialog.h"
#import "Crittercism.h"
#import "SnippetQuery.h"

@interface SmallLabelElement : QLabelElement

@end

@implementation SmallLabelElement
{
    UIFont *_font;
}

- (QLabelElement *)initWithTitle:(NSString *)string Value:(id)value
{
    self = [super initWithTitle:string Value:value];
    if (self != nil)
        _font = [[UIFont systemFontOfSize:[UIFont smallSystemFontSize]] retain];

    return self;
}

- (void)dealloc
{
    [_font release];
    [super dealloc];
}

- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller
{
    UITableViewCell *cell = [super getCellForTableView:tableView controller:controller];
    cell.textLabel.font = _font;
    return cell;
}

- (CGFloat)getRowHeightForTableView:(QuickDialogTableView *)tableView {
    return _font.lineHeight * 2;
}

@end

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

+ (QRootElement *)aboutForm:(UINavigationController *)navigationController snippetsController:(SnippetListViewController *)snippetsController
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

    QLabelElement *couchdbElement = [[[SmallLabelElement alloc] initWithTitle:@"Powered by CouchDB" Value:nil] autorelease];
    couchdbElement.image = [UIImage imageNamed:@"couchdb.png"];

    QSection *aboutSection = [[[QSection alloc] initWithTitle:@"About Try F#"] autorelease];
    [aboutSection addElement:[AppDelegate linkElementWithTitle:@"timrobinson/try-fsharp" url:[NSURL URLWithString:@"https://github.com/timrobinson/try-fsharp"] image:[UIImage imageNamed:@"github.png"]]];
    [aboutSection addElement:[AppDelegate linkElementWithTitle:@"@1tgr" url:[NSURL URLWithString:@"http://twitter.com/tim_g_robinson"] image:[UIImage imageNamed:@"twitter.png"]]];
    [aboutSection addElement:feedbackElement];
    [aboutSection addElement:couchdbElement];

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
        [aboutSection addElement:[[[SmallLabelElement alloc] initWithTitle:@"Uses MGSplitViewController by Matt Gemmell" Value:nil] autorelease]];

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
    SnippetQuery *query = [[[SnippetQuery alloc] initWithDatabase:[server databaseNamed:@"tryfs"]] autorelease];
    [query refresh];

    SnippetListViewController *snippetsController = [[[SnippetListViewController alloc] initWithNibName:@"SnippetListViewController" bundle:nil] autorelease];
    snippetsController.query = query;

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
