//
//  PDWebRouterPlugin.m
//  PDRouter
//
//  Created by liang on 2019/5/29.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import "PDWebRouterPlugin.h"
#import "PDWebController.h"
#import "NSString+PDAdd.h"

@implementation PDWebRouterPlugin

#pragma mark - Override Methods
- (void)load {
    // Do nothing...
    NSLog(@"name = %@", self.name);
}

- (BOOL)openURL:(NSString *)urlString params:(NSDictionary *)params {
    NSString *encodedURLString = [urlString pd_encodeWithURLQueryAllowedCharacterSet];
    
    if ([self isValidURL:encodedURLString]) {
        [self skipToWebController:encodedURLString params:params];
        return YES;
    }
    return NO;
}

#pragma mark - Tool Methods
- (BOOL)isValidURL:(NSString *)URLString {
    if ([URLString hasPrefix:@"http://"] ||
        [URLString hasPrefix:@"https://"]) {
        return YES;
    }
    return NO;
}

- (void)skipToWebController:(NSString *)URLString params:(NSDictionary *)params {
    NSAssert(self.navigationController, @"Attr `navigationController` can not be nil!");

    PDWebController *controller = [[PDWebController alloc] init];
    if ([params[@"mode"] isEqualToString:@"present"]) {
        UIViewController *topViewController = self.navigationController.topViewController;
        if (!topViewController) {
            topViewController = self.navigationController;
        }
        [topViewController presentViewController:controller animated:YES completion:nil];
    } else {
        [self.navigationController pushViewController:controller animated:YES];
    }
    
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    [controller loadRequest:request];
}

@end
