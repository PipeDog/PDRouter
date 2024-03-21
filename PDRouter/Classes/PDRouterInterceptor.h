//
//  PDRouterInterceptor.h
//  PDPower
//
//  Created by liang on 2024/3/19.
//

#import <Foundation/Foundation.h>
#import "PDRouterRequest.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `PDRouterInterceptorChain` 协议定义了拦截器链的行为
 */
@protocol PDRouterInterceptorChain <NSObject>

/**
 当前处理的路由请求
 */
@property (nonatomic, strong, readonly) PDRouterRequest *request;

/**
 导航控制器，用于页面跳转
 */
@property (nonatomic, strong, readonly) UINavigationController *navigator;

/**
 继续处理下一个拦截器

 @param request 要处理的路由请求
 @return 如果处理成功返回 YES，否则返回 NO
 */
- (BOOL)proceed:(PDRouterRequest *)request;

@end

/**
 `PDRouterInterceptor` 协议定义了拦截器的行为
 */
@protocol PDRouterInterceptor <NSObject>

/**
 拦截路由请求的处理

 @param chain 拦截器链
 @return 如果拦截成功并终止后续处理返回 YES，否则返回 NO 以继续处理
 */
- (BOOL)intercept:(id<PDRouterInterceptorChain>)chain;

@end

NS_ASSUME_NONNULL_END
