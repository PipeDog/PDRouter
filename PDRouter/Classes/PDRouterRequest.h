//
//  PDRouterRequest.h
//  PDPower
//
//  Created by liang on 2024/3/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 `PDRouterRequest` 是一个封装路由请求的 URL 字符串和参数字典的不可变对象
 */
@interface PDRouterRequest : NSObject

/**
 路由请求的 URL 字符串
 */
@property (nonatomic, copy, readonly) NSString *urlString;

/**
 路由请求的参数字典
 */
@property (nonatomic, strong, readonly, nullable) NSDictionary<NSString *, id> *parameters;

/**
 使用指定的 URL 字符串和参数字典初始化 `PDRouterRequest` 实例

 @param urlString 路由请求的 URL 字符串
 @param parameters 路由请求的参数字典，可以为 nil

 @return 初始化后的 `PDRouterRequest` 实例
 */
- (instancetype)initWithURLString:(NSString *)urlString
                       parameters:(nullable NSDictionary<NSString *, id> *)parameters;

@end

NS_ASSUME_NONNULL_END
