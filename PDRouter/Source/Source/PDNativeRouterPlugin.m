//
//  PDNativeRouterPlugin.m
//  PDRouter
//
//  Created by 雷亮 on 2019/5/29.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import "PDNativeRouterPlugin.h"
#import <objc/runtime.h>
#import "PDPage.h"

static inline BOOL isKindOfClass(Class parent, Class child) {
    for (Class cls = child; cls; cls = class_getSuperclass(cls)) {
        if (cls == parent) {
            return YES;
        }
    }
    return NO;
}

@implementation PDNativeRouterPlugin

- (void)onload {
    [self reigsterPage:NSClassFromString(@"PDPage") forPattern:@"ViewControllerPresent"];
    [self reigsterPage:NSClassFromString(@"PDPage") forPattern:@"pdog://openpage"];

    // Read routes from plist
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RouteConfig" ofType:@"plist"];
    NSDictionary *routes = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    [routes enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self reigsterPage:NSClassFromString(obj) forPattern:key];
    }];
}

- (BOOL)openURL:(NSString *)encodedURLString params:(NSDictionary *)params {
    
    Class aClass = NSClassFromString(encodedURLString);
    if (!aClass) { return NO; }
    if (!isKindOfClass([PDPage class], aClass)) { return NO; }
    
    PDPage *page = [[aClass alloc] init];
    page.routerParams = params;
    NSAssert(self.navigationController != nil, @"Property navigationController can not be nil.");
    
    if ([params[@"present"] integerValue] == 1) {
        [self.navigationController presentViewController:page animated:YES completion:nil];
    } else {
        [self.navigationController pushViewController:page animated:YES];
    }
    
    [self reigsterPage:aClass forPattern:encodedURLString];
    return YES;
}

- (void)reigsterPage:(Class)aClass forPattern:(NSString *)pattern {
    if (!isKindOfClass([PDPage class], aClass)) {
        NSAssert(NO, @"Param aClass must be subclass of [PDPage class].");
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.router registerEventHandler:^(NSDictionary * _Nullable routerParams) {
        PDPage *page = [[aClass alloc] init];
        page.routerParams = routerParams;
        NSAssert(weakSelf.navigationController != nil, @"Property navigationController can not be nil.");
        
        if ([routerParams[@"present"] integerValue] == 1) {
            [weakSelf.navigationController presentViewController:page animated:YES completion:nil];
        } else {
            [weakSelf.navigationController pushViewController:page animated:YES];
        }
    } forPattern:pattern];
}

@end
