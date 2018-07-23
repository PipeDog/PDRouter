//
//  PDRouterGroup.m
//  PDRouter
//
//  Created by liang on 2018/7/23.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDRouterGroup.h"

@interface PDRouterGroup () {
    NSMutableDictionary<NSString *, PDRouterEventHandler> *_listeners;
}

@end

@implementation PDRouterGroup

- (instancetype)init {
    self = [super init];
    if (self) {
        _listeners = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)on:(NSString *)relativePath eventHandler:(void (^)(NSDictionary *routerParams))eventHandler {
    NSAssert(relativePath != nil, @"Param relativePath can not be nil!");
    [_listeners setValue:[eventHandler copy] forKey:relativePath];
}

#pragma mark - Getter Methods
- (NSDictionary<NSString *,PDRouterEventHandler> *)listeners {
    return [_listeners copy];
}

@end
