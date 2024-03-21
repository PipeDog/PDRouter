//
//  PDObjectPropertyMapper.h
//  PDObjectPropertyMapper
//
//  Created by liang on 2020/11/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * PDObjectParameterKey;    ///< 参数中的键名称
typedef NSString * PDObjectPropertyName;    ///< 对象属性名称

/// 自定义属性映射表的类型定义
typedef NSDictionary<PDObjectParameterKey, PDObjectPropertyName> * PDObjectCustomPropertyMapper;

/**
 自定义属性映射的 Block 类型

 @return 返回自定义属性映射表，键为数据源中的键名，值为对象中对应的属性名
 */
typedef PDObjectCustomPropertyMapper _Nullable (^PDObjectPropertyMapperBlock)(void);

/**
 KV 映射协议，提供自定义属性映射表的方法
 */
@protocol PDObjectPropertyMappingProtocol <NSObject>

/**
 获取自定义属性映射表

 @return 返回自定义属性映射表，键为数据源中的键名称，值为对象中对应的属性名称
 
 示例代码：
 @code
 + (NSDictionary<PDObjectParameterKey, PDObjectPropertyName> *)objectCustomPropertyMapper {
     return @{@"id": @"identifier",
              @"desc": @"description",
              @"name": @"userName"};
 }
 @endcode
 
 在这个示例中，数据源中的 "id" 键将映射到对象的 "identifier" 属性，"desc" 键将映射到 "description" 属性，
 "name" 键将映射到 "userName" 属性
 */
+ (NSDictionary<PDObjectParameterKey, PDObjectPropertyName> *)objectCustomPropertyMapper;

@end

/**
 键值对映射器，负责将键值对映射到对象的属性上
 */
@interface PDObjectPropertyMapper : NSObject

/**
 获取全局单例对象

 @return 返回 PDObjectPropertyMapper 的全局单例对象
 */
@property (class, strong, readonly) PDObjectPropertyMapper *defaultMapper;

/**
 映射键值对到指定的对象

 @param keyValuePairs 键值对字典，键为对象的属性名称，值为对应的属性值
 @param object 需要赋值的对象
 
 此方法将数据源中的键值对直接映射到对象的属性上。如果对象遵循 PDObjectPropertyMappingProtocol 协议，
 则会使用自定义的属性映射规则，否则将使用键值对中的键直接作为对象的属性名称进行映射。
 */
- (void)mapKeyValuePairs:(NSDictionary<NSString *, id> *)keyValuePairs toObject:(id)object;

/**
 映射键值对到指定的对象，可通过 block 自定义属性映射规则

 @param keyValuePairs 键值对字典，键为对象的属性名称，值为对应的属性值
 @param object 需要赋值的对象
 @param block 一个返回自定义属性映射表的 block，映射表的键为数据源中的键名称，值为对象中对应的属性名称
 
 如果提供了 block，则使用 block 返回的自定义属性映射表进行映射；
 如果没有提供 block，但对象遵循 PDObjectPropertyMappingProtocol 协议，则使用协议方法返回的映射表进行映射；
 如果都没有，则直接使用键值对中的键作为对象的属性名称进行映射
 */
- (void)mapKeyValuePairs:(NSDictionary<NSString *, id> *)keyValuePairs
                toObject:(id)object
            mapperBlock:(nullable PDObjectPropertyMapperBlock)block;

@end

/**
 为指定对象设置属性值
 
 @param object 需要设置属性的对象
 @param keyValuePairs 键值对字典，键为对象的属性名称，值为对应的属性值
 @param mapperBlock 一个返回自定义属性映射表的 block，映射表的键为数据源中的键名称，值为对象中对应的属性名称
 */
FOUNDATION_EXPORT void PDObjectSetPropertyValues(id object,
                                                 NSDictionary<NSString *, id> *keyValuePairs,
                                                 PDObjectPropertyMapperBlock _Nullable mapperBlock);

NS_ASSUME_NONNULL_END
