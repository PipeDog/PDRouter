//
//  PDPageNavigationInterceptor.m
//  PDPower
//
//  Created by liang on 2024/3/20.
//

#import "PDPageNavigationInterceptor.h"
#import "PDRouterPageRegistry.h"
#import "PDRouterParamReceiver.h"
#import "PDObjectPropertyMapper.h"

@implementation PDPageNavigationInterceptor

- (BOOL)intercept:(id<PDRouterInterceptorChain>)chain {
    // 通过 URL 获取对应的视图控制器类
    Class clazz = [[PDRouterPageRegistry defaultRegistry] classForPath:chain.request.urlString];
    if (!clazz) { return NO; }
    
    // 创建视图控制器实例
    UIViewController *page = [[clazz alloc] init];
    if (!page) { return NO; }

    // 如果视图控制器遵循了 `PDRouterManualParamReceiver` 协议，手动接收参数
    if ([page conformsToProtocol:@protocol(PDRouterManualParamReceiver)]) {
        [(id<PDRouterManualParamReceiver>)page onRouterParameters:chain.request.parameters];
    }

    // 如果视图控制器遵循了 `PDRouterAutoParamReceiver` 协议，自动解析参数并赋值
    else if ([page conformsToProtocol:@protocol(PDRouterAutoParamReceiver)]) {
        [[PDObjectPropertyMapper defaultMapper] mapKeyValuePairs:chain.request.parameters
                                                        toObject:page
                                                     mapperBlock:^PDObjectCustomPropertyMapper _Nullable{
            if (![page respondsToSelector:@selector(routerCustomPropertyMapper)]) {
                return nil;
            }
            
            return [(id<PDRouterAutoParamReceiver>) page routerCustomPropertyMapper];
        }];
    }

    // 不接收参数
    else {
        // Do nothing...
    }
    
    // 进行页面跳转
    [chain.navigator pushViewController:page animated:YES];
    return YES;
}

@end
