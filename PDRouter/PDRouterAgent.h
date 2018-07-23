//
//  PDRouterAgent.h
//  PDRouter
//
//  Created by liang on 2018/7/23.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDRouterAgent : NSObject

@property (class, strong, readonly) PDRouterAgent *defaultAgent;

- (void)setNavigationController:(UINavigationController *)navigationController;

- (void)registerPage:(Class)pageClass;
- (void)openPage:(Class)pageClass params:(NSDictionary *)params;

#define PDRouterRegister(pageClass) [[PDRouterAgent defaultAgent] registerPage:[pageClass class]]
#define PDRouterOpen(pageClass, args) [[PDRouterAgent defaultAgent] openPage:pageClass params:args]

@end
