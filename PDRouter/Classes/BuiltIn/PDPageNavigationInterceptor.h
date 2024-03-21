//
//  PDPageNavigationInterceptor.h
//  PDPower
//
//  Created by liang on 2024/3/20.
//

#import <UIKit/UIKit.h>
#import "PDRouterInterceptor.h"

NS_ASSUME_NONNULL_BEGIN

/**
 `PDPageNavigationInterceptor` 类实现了 `PDRouterInterceptor` 协议，用于处理页面导航的拦截逻辑
 */
@interface PDPageNavigationInterceptor : NSObject <PDRouterInterceptor>

@end

NS_ASSUME_NONNULL_END
