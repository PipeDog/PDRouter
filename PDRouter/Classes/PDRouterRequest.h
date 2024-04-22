//
//  PDRouterRequest.h
//  PDRouter
//
//  Created by liang on 2024/4/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class PDRouterRequest;

/**
 * `PDRouterRequestBuilder` 类提供了构建 `PDRouterRequest` 对象的方法
 * 它遵循构建者模式，允许链式调用来设置不同的属性，最后通过 build 方法来生成一个不可变的 `PDRouterRequest` 对象
 */
@interface PDRouterRequestBuilder : NSObject

/**
 路由请求的 URL 字符串
 */
@property (nonatomic, copy) NSString *urlString;

/**
 路由请求的参数字典，可以为空
 */
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *parameters;

/**
 路由请求的扩展参数字典，可以为空
 */
@property (nonatomic, copy, nullable) NSDictionary<NSString *, id> *payload;

/**
 使用下标语法设置扩展参数
 
 @code
 builder[@"key"] = @"value";
 @endcode
 */
- (void)setObject:(nullable id)obj forKeyedSubscript:(NSString *)key;

/**
 使用下标语法获取扩展参数
 
 @code
 id value = builder[@"key"];
 @endcode
 */
- (nullable id)objectForKeyedSubscript:(NSString *)key;

/**
 * 构建并返回一个 `PDRouterRequest` 对象，其中包含了之前设置的属性值
 * @return 返回一个新的、不可变的 `PDRouterRequest` 实例
 */
- (PDRouterRequest *)build;

@end

/**
 * `PDRouterRequest` 类封装了路由请求所需的信息，包括 URL 字符串、参数字典和扩展参数字典
 * 该对象是不可变的，可通过与之关联的 `PDRouterRequestBuilder` 来构建新实例
 */
@interface PDRouterRequest : NSObject

/**
 获取路由请求的 URL 字符串
 */
@property (nonatomic, copy, readonly) NSString *urlString;

/**
 获取路由请求的参数字典
 */
@property (nonatomic, copy, readonly, nullable) NSDictionary<NSString *, id> *parameters;

/**
 获取路由请求的扩展参数
 */
@property (nonatomic, copy, readonly, nullable) NSDictionary<NSString *, id> *payload;

/**
 * 创建并返回一个 `PDRouterRequestBuilder` 对象，该对象复制了当前 `PDRouterRequest` 的属性值
 * @return 返回一个新的 PDRouterRequestBuilder 实例，用于创建一个新的 `PDRouterRequest` 对象
 */
- (PDRouterRequestBuilder *)newBuilder;

@end

NS_ASSUME_NONNULL_END
