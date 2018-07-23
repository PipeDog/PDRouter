//
//  PDRouterGroup.h
//  PDRouter
//
//  Created by liang on 2018/7/23.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^PDRouterEventHandler)(NSDictionary *routerParams);

@interface PDRouterGroup : NSObject

@property (nonatomic, copy, readonly) NSDictionary<NSString *, PDRouterEventHandler> *listeners;

- (void)on:(NSString *)relativePath eventHandler:(PDRouterEventHandler)eventHandler;

@end
