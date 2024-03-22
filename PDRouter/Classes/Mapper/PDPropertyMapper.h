//
//  PDPropertyMapper.h
//  PDRouter
//
//  Created by liang on 2024/3/22.
//

#import <Foundation/Foundation.h>
#import "PDObjectPropertyMapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (PDPropertyMapper)

/**
 为当前对象设置属性值
 
 此方法通过调用 `PDObjectPropertyMapper` 的 `mapKeyValuePairs:toObject:` 方法来将键值对映射到当前对象的属性上
 
 @param keyValuePairs 键值对字典，键为对象的属性名称，值为对应的属性值
 */
- (void)setPropertyValues:(NSDictionary<NSString *, id> *)keyValuePairs;

/**
 为当前对象设置属性值
 
 此方法通过调用 `PDObjectPropertyMapper` 的 `mapKeyValuePairs:toObject:mapperBlock:` 方法来将键值对映射到当前对象的属性上
 如果提供了 block，则使用 block 返回的自定义属性映射表进行映射；
 如果没有提供 block，但当前对象遵循 PDObjectPropertyMappingProtocol 协议，则使用协议方法返回的映射表进行映射；
 如果都没有，则直接使用键值对中的键作为对象的属性名称进行映射
 
 @param keyValuePairs 键值对字典，键为对象的属性名称，值为对应的属性值
 @param block 一个返回自定义属性映射表的 block，映射表的键为数据源中的键名称，值为对象中对应的属性名称
 */
- (void)setPropertyValues:(NSDictionary<NSString *, id> *)keyValuePairs
              mapperBlock:(nullable PDObjectPropertyMapperBlock)block;

@end

NS_ASSUME_NONNULL_END
