//
//  PDRouter.m
//  PDPower
//
//  Created by liang on 2024/3/19.
//

#import "PDRouter.h"
#import "PDPageNavigationInterceptor.h"

/**
 `PDRealRouterInterceptorChain` 类是 `PDRouterInterceptorChain` 协议的具体实现，负责管理拦截器链的执行
 */
@interface PDRealRouterInterceptorChain : NSObject <PDRouterInterceptorChain>

@property (nonatomic, strong) NSArray<id<PDRouterInterceptor>> *interceptors;
@property (nonatomic, strong) PDRouterRequest *request;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UINavigationController *navigator;

@end

@implementation PDRealRouterInterceptorChain

- (instancetype)initWithIndex:(NSInteger)index 
                      request:(PDRouterRequest *)request
                 interceptors:(NSArray<id<PDRouterInterceptor>> *)interceptors
                    navigator:(UINavigationController *)navigator {
    self = [super init];
    if (self) {
        _interceptors = [interceptors copy];
        _request = request;
        _index = index;
        _navigator = navigator;
    }
    return self;
}

- (BOOL)proceed:(PDRouterRequest *)request {
    if (self.index >= self.interceptors.count) {
        return NO;
    }
    
    id<PDRouterInterceptorChain> next = [[PDRealRouterInterceptorChain alloc] initWithIndex:self.index + 1 
                                                                                    request:request
                                                                               interceptors:self.interceptors
                                                                                  navigator:self.navigator];
    id<PDRouterInterceptor> interceptor = self.interceptors[self.index];
    return [interceptor intercept:next];
}

@end

@interface PDRouter ()

@property (nonatomic, strong) NSMutableArray<id<PDRouterInterceptor>> *interceptors;

@end

@implementation PDRouter

+ (PDRouter *)globalRouter {
    static PDRouter *__globalRouter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!__globalRouter) {
            __globalRouter = [[self alloc] init];
        }
    });
    return __globalRouter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _interceptors = [NSMutableArray array];  
    }
    return self;
}

- (void)addInterceptor:(id<PDRouterInterceptor>)interceptor {
    [self.interceptors addObject:interceptor];
}

- (BOOL)openURL:(NSString *)urlString {
    return [self openURL:urlString parameters:nil];
}

- (BOOL)openURL:(NSString *)urlString parameters:(NSDictionary<NSString *,id> *)parameters {
    NSMutableArray *interceptors = [NSMutableArray array];
    [interceptors addObjectsFromArray:self.interceptors];
    [interceptors addObject:[[PDPageNavigationInterceptor alloc] init]];
    
    PDRouterRequest *request = [[PDRouterRequest alloc] initWithURLString:urlString parameters:parameters];
    PDRealRouterInterceptorChain *chain = [[PDRealRouterInterceptorChain alloc] initWithIndex:0 
                                                                                      request:request
                                                                                 interceptors:interceptors
                                                                                    navigator:self.navigator];
    return [chain proceed:request];
}

@end
