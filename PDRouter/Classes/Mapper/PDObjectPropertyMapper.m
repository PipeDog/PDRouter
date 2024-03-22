//
//  PDObjectPropertyMapper.m
//  PDObjectPropertyMapper
//
//  Created by liang on 2020/11/24.
//

#import "PDObjectPropertyMapper.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "PDClassPropertyInfo.h"

/// Get the 'NSBlock' class.
static inline Class PDNSBlockClass(void) {
    static Class cls;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void (^block)(void) = ^{};
        cls = ((NSObject *)block).class;
        while (class_getSuperclass(cls) != [NSObject class]) {
            cls = class_getSuperclass(cls);
        }
    });
    return cls; // current is "NSBlock"
}

static inline void PDObjectSetNumberToProperty(__unsafe_unretained id model,
                                              __unsafe_unretained NSNumber *num,
                                              __unsafe_unretained PDClassPropertyInfo *propertyInfo) {
    switch (propertyInfo.type & PDEncodingTypeMask) {
        case PDEncodingTypeBool: {
            ((void (*)(id, SEL, bool))(void *) objc_msgSend)((id)model, propertyInfo.setter, num.boolValue);
        } break;
        case PDEncodingTypeInt8: {
            ((void (*)(id, SEL, int8_t))(void *) objc_msgSend)((id)model, propertyInfo.setter, (int8_t)num.charValue);
        } break;
        case PDEncodingTypeUInt8: {
            ((void (*)(id, SEL, uint8_t))(void *) objc_msgSend)((id)model, propertyInfo.setter, (uint8_t)num.unsignedCharValue);
        } break;
        case PDEncodingTypeInt16: {
            ((void (*)(id, SEL, int16_t))(void *) objc_msgSend)((id)model, propertyInfo.setter, (int16_t)num.shortValue);
        } break;
        case PDEncodingTypeUInt16: {
            ((void (*)(id, SEL, uint16_t))(void *) objc_msgSend)((id)model, propertyInfo.setter, (uint16_t)num.unsignedShortValue);
        } break;
        case PDEncodingTypeInt32: {
            ((void (*)(id, SEL, int32_t))(void *) objc_msgSend)((id)model, propertyInfo.setter, (int32_t)num.intValue);
        } break;
        case PDEncodingTypeUInt32: {
            ((void (*)(id, SEL, uint32_t))(void *) objc_msgSend)((id)model, propertyInfo.setter, (uint32_t)num.unsignedIntValue);
        } break;
        case PDEncodingTypeInt64: {
            if ([num isKindOfClass:[NSDecimalNumber class]]) {
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)model, propertyInfo.setter, (int64_t)num.stringValue.longLongValue);
            } else {
                ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)model, propertyInfo.setter, (uint64_t)num.longLongValue);
            }
        } break;
        case PDEncodingTypeUInt64: {
            if ([num isKindOfClass:[NSDecimalNumber class]]) {
                ((void (*)(id, SEL, int64_t))(void *) objc_msgSend)((id)model, propertyInfo.setter, (int64_t)num.stringValue.longLongValue);
            } else {
                ((void (*)(id, SEL, uint64_t))(void *) objc_msgSend)((id)model, propertyInfo.setter, (uint64_t)num.unsignedLongLongValue);
            }
        } break;
        case PDEncodingTypeFloat: {
            float f = num.floatValue;
            if (isnan(f) || isinf(f)) f = 0;
            ((void (*)(id, SEL, float))(void *) objc_msgSend)((id)model, propertyInfo.setter, f);
        } break;
        case PDEncodingTypeDouble: {
            double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, double))(void *) objc_msgSend)((id)model, propertyInfo.setter, d);
        } break;
        case PDEncodingTypeLongDouble: {
            long double d = num.doubleValue;
            if (isnan(d) || isinf(d)) d = 0;
            ((void (*)(id, SEL, long double))(void *) objc_msgSend)((id)model, propertyInfo.setter, (long double)d);
        } // break; commented for code coverage in next line
        default: break;
    }
}

@implementation PDObjectPropertyMapper

+ (PDObjectPropertyMapper *)defaultMapper {
    static PDObjectPropertyMapper *__defaultMapper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __defaultMapper = [[self alloc] init];
    });
    return __defaultMapper;
}

- (void)mapKeyValuePairs:(NSDictionary<NSString *,id> *)keyValuePairs toObject:(id)object {
    [self mapKeyValuePairs:keyValuePairs toObject:object mapperBlock:nil];
}

- (void)mapKeyValuePairs:(NSDictionary<NSString *,id> *)keyValuePairs 
                toObject:(id)object
             mapperBlock:(PDObjectPropertyMapperBlock)block {
    if (!keyValuePairs.count || !object) { return; }
    
    NSDictionary<PDObjectParameterKey, PDObjectPropertyName> *propertyMapper;
    if (block) {
        propertyMapper = block();
    } else if ([[object class] conformsToProtocol:@protocol(PDObjectPropertyMappingProtocol)]) {
        propertyMapper = [[object class] objectCustomPropertyMapper];
    } else {
        // Do nothing...
    }

    [keyValuePairs enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        PDObjectPropertyName propertyName = propertyMapper[key] ?: key;
        [self setValue:obj forProperty:propertyName toObject:object];
    }];
}

#pragma mark - Tool Methods
- (void)setValue:(id)value forProperty:(PDObjectPropertyName)propertyName toObject:(id)object {
    NSString *className = NSStringFromClass([object class]);
    PDClassPropertyInfo *propertyInfo = [PDClassPropertyInfo propertyInfoWithClass:className property:propertyName];
    if (!propertyInfo) {
        NSLog(@"Failed to match property `%@` in class `%@`!", propertyName, className);
        return;
    }
    
#define PDDataTypeMatchFailedAsset()                                                                \
    NSString *info = [NSString stringWithFormat:@"Data type match failed, type = %zd, value = %@",  \
                      (propertyInfo.type & PDEncodingTypeMask), value];                             \
    NSAssert(NO, info)

    switch (propertyInfo.type & PDEncodingTypeMask) {
        case PDEncodingTypeBool:
        case PDEncodingTypeInt8:
        case PDEncodingTypeUInt8:
        case PDEncodingTypeInt16:
        case PDEncodingTypeUInt16:
        case PDEncodingTypeInt32:
        case PDEncodingTypeUInt32:
        case PDEncodingTypeInt64:
        case PDEncodingTypeUInt64:
        case PDEncodingTypeFloat:
        case PDEncodingTypeDouble:
        case PDEncodingTypeLongDouble: {
            PDObjectSetNumberToProperty(object, (NSNumber *)value, propertyInfo);
        } break;
        
        case PDEncodingTypeObject: {
            ((void (*)(id, SEL, id))(void *) objc_msgSend)((id)object, propertyInfo.setter, value);
        } break;
        
        case PDEncodingTypeClass: {
            Class cls = nil;
            if ([value isKindOfClass:[NSString class]]) {
                cls = NSClassFromString(value);
                if (cls) {
                    ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)object, propertyInfo.setter, (Class)cls);
                }
            } else {
                cls = object_getClass(value);
                if (cls) {
                    if (class_isMetaClass(cls)) {
                        ((void (*)(id, SEL, Class))(void *) objc_msgSend)((id)object, propertyInfo.setter, (Class)value);
                    }
                }
            }
        } break;

        case PDEncodingTypeSEL: {
            if ([value isKindOfClass:[NSString class]]) {
                SEL sel = NSSelectorFromString(value);
                if (sel) ((void (*)(id, SEL, SEL))(void *) objc_msgSend)((id)object, propertyInfo.setter, (SEL)sel);
            } else {
                PDDataTypeMatchFailedAsset();
            }
        } break;
            
        case PDEncodingTypeBlock: {
            if ([value isKindOfClass:PDNSBlockClass()]) {
                ((void (*)(id, SEL, void (^)(void)))(void *) objc_msgSend)((id)object, propertyInfo.setter, (void (^)(void))value);
            } else {
                PDDataTypeMatchFailedAsset();
            }
        } break;
            
        case PDEncodingTypeStruct: {
            if ([value isKindOfClass:[NSValue class]]) {
                const char *valueType = ((NSValue *)value).objCType;
                const char *metaType = propertyInfo.typeEncoding.UTF8String;
                if (valueType && metaType && strcmp(valueType, metaType) == 0) {
                    [object setValue:value forKey:propertyInfo.name];
                }
            } else {
                PDDataTypeMatchFailedAsset();
            }
        } break;
            
        case PDEncodingTypeCString: {
            if ([value isKindOfClass:[NSString class]]) {
                NSString *string = (NSString *)value;
                ((void (*)(id, SEL, const char *))(void *) objc_msgSend)((id)object, propertyInfo.setter, [string UTF8String]);
            } else {
                PDDataTypeMatchFailedAsset();
            }
        } break;
            
        default: {
            @try {
                [object setValue:value forKey:propertyName];
            } @catch (NSException *exception) {
                NSLog(@"Exception details:\nName: %@\nReason: %@\nUserInfo: %@\nCall Stack: %@",
                      exception.name,
                      exception.reason,
                      exception.userInfo,
                      exception.callStackSymbols);
            }
        } break;
    }
}

@end
