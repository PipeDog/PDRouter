//
//  AppDelegate.m
//  PDRouter
//
//  Created by liang on 2018/3/3.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "AppDelegate.h"
#import "PDRouter.h"

@interface AppDelegate () <PDRouterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RouterPlugins" ofType:@"plist"];
//
//    NSArray *(^collectPluginNames)(void) = ^{
//        if (@available(iOS 11.0, *)) {
//            NSURL *URL = [NSURL fileURLWithPath:plistPath];
//            return [NSArray arrayWithContentsOfURL:URL error:nil];
//        } else {
//            // Fallback on earlier versions
//            return [NSArray arrayWithContentsOfFile:plistPath];
//        }
//    };
//
//    NSArray *pluginNames = collectPluginNames();
    
//    [[PDRouter globalRouter] collectPluginsWithPluginNames:pluginNames];
    [PDRouter globalRouter].delegate = self;
    return YES;
}

- (void)didFinishOpenURL:(NSString *)urlString params:(NSDictionary *)params {
    NSLog(@"%s, urlString = %@, params = %@", __func__, urlString, params);
}

- (void)didFailOpenURL:(NSString *)urlString params:(NSDictionary *)params {
    NSLog(@"%s, urlString = %@, params = %@", __func__, urlString, params);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
