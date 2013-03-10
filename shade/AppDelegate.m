//
//  AppDelegate.m
//  shade
//
//  Created by Troy Stribling on 3/2/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "AppDelegate.h"
#import "DataManager.h"
#import "ViewController.h"
#import "ViewGeneral.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    DataManager* dataManger = [DataManager create];
    dataManger.modelURL = [[NSBundle mainBundle] URLForResource:@"shade" withExtension:@"momd"];
    dataManger.persistantStoreName = @"shade.sqlite";
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application {
    [[ViewGeneral instance] waitForSaveImageQueueToEmpty];
}

@end
