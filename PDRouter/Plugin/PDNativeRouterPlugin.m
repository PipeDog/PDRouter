//
//  PDNativeRouterPlugin.m
//  PDRouter
//
//  Created by liang on 2019/5/29.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import "PDNativeRouterPlugin.h"
#import <objc/runtime.h>
#import "PDViewController.h"
#import "NSString+PDAdd.h"

@implementation PDNativeRouterPlugin

#pragma mark - Override Methods
- (void)load {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RouteConfig" ofType:@"plist"];
    NSDictionary *routes = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    [routes enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self registerController:NSClassFromString(obj) forPattern:key];
    }];
}

- (BOOL)openURL:(NSString *)urlString params:(NSDictionary *)params {
    NSString *encodedURLString = [urlString pd_encodeWithURLQueryAllowedCharacterSet];

    Class aClass = NSClassFromString(encodedURLString);
    if (!aClass) { return NO; }
    
    if ([self skipToController:aClass routerParams:params]) {
        [self registerController:aClass forPattern:encodedURLString];
        return YES;
    }
    return NO;
}

#pragma mark - Tool Methods
- (void)registerController:(Class)aClass forPattern:(NSString *)pattern {
    __weak typeof(self) weakSelf = self;
    [self.router inject:pattern eventHandler:^(NSDictionary * _Nullable params) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf skipToController:aClass routerParams:params];
        }
    }];
}

- (BOOL)skipToController:(Class)aClass routerParams:(NSDictionary *)routerParams {
    if (!aClass) { return NO; }
    
    PDViewController *controller = [[aClass alloc] init];
    if (![controller isKindOfClass:[PDViewController class]]) {
        return NO;
    }
    
    controller.routerParams = routerParams;
    NSAssert(self.navigationController, @"Attr `navigationController` can not be nil!");
    
    if ([routerParams[@"mode"] isEqualToString:@"present"]) {
        UIViewController *topViewController = self.navigationController.topViewController;
        if (!topViewController) {
            topViewController = self.navigationController;
        }
        [topViewController presentViewController:controller animated:YES completion:nil];
    } else {
        [self.navigationController pushViewController:controller animated:YES];
    }
    return YES;
}

@end
