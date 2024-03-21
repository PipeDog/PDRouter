//
//  PDClassPropertyInfo.m
//  PDModelKVMapper
//
//  Created by liang on 2020/11/24.
//

#import "PDClassPropertyInfo.h"

PDEncodingType PDEncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) return PDEncodingTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return PDEncodingTypeUnknown;
    
    PDEncodingType qualifier = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r': {
                qualifier |= PDEncodingTypeQualifierConst;
                type++;
            } break;
            case 'n': {
                qualifier |= PDEncodingTypeQualifierIn;
                type++;
            } break;
            case 'N': {
                qualifier |= PDEncodingTypeQualifierInout;
                type++;
            } break;
            case 'o': {
                qualifier |= PDEncodingTypeQualifierOut;
                type++;
            } break;
            case 'O': {
                qualifier |= PDEncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R': {
                qualifier |= PDEncodingTypeQualifierByref;
                type++;
            } break;
            case 'V': {
                qualifier |= PDEncodingTypeQualifierOneway;
                type++;
            } break;
            default: { prefix = false; } break;
        }
    }

    len = strlen(type);
    if (len == 0) return PDEncodingTypeUnknown | qualifier;

    switch (*type) {
        case 'v': return PDEncodingTypeVoid | qualifier;
        case 'B': return PDEncodingTypeBool | qualifier;
        case 'c': return PDEncodingTypeInt8 | qualifier;
        case 'C': return PDEncodingTypeUInt8 | qualifier;
        case 's': return PDEncodingTypeInt16 | qualifier;
        case 'S': return PDEncodingTypeUInt16 | qualifier;
        case 'i': return PDEncodingTypeInt32 | qualifier;
        case 'I': return PDEncodingTypeUInt32 | qualifier;
        case 'l': return PDEncodingTypeInt32 | qualifier;
        case 'L': return PDEncodingTypeUInt32 | qualifier;
        case 'q': return PDEncodingTypeInt64 | qualifier;
        case 'Q': return PDEncodingTypeUInt64 | qualifier;
        case 'f': return PDEncodingTypeFloat | qualifier;
        case 'd': return PDEncodingTypeDouble | qualifier;
        case 'D': return PDEncodingTypeLongDouble | qualifier;
        case '#': return PDEncodingTypeClass | qualifier;
        case ':': return PDEncodingTypeSEL | qualifier;
        case '*': return PDEncodingTypeCString | qualifier;
        case '^': return PDEncodingTypePointer | qualifier;
        case '[': return PDEncodingTypeCArray | qualifier;
        case '(': return PDEncodingTypeUnion | qualifier;
        case '{': return PDEncodingTypeStruct | qualifier;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return PDEncodingTypeBlock | qualifier;
            else
                return PDEncodingTypeObject | qualifier;
        }
        default: return PDEncodingTypeUnknown | qualifier;
    }
}

@implementation PDClassPropertyInfo

- (instancetype)initWithProperty:(objc_property_t)property {
    if (!property) return nil;
    self = [super init];
    _property = property;
    const char *name = property_getName(property);
    if (name) {
        _name = [NSString stringWithUTF8String:name];
    }
    
    PDEncodingType type = 0;
    unsigned int attrCount;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
    for (unsigned int i = 0; i < attrCount; i++) {
        switch (attrs[i].name[0]) {
            case 'T': { // Type encoding
                if (attrs[i].value) {
                    _typeEncoding = [NSString stringWithUTF8String:attrs[i].value];
                    type = PDEncodingGetType(attrs[i].value);
                    
                    if ((type & PDEncodingTypeMask) == PDEncodingTypeObject && _typeEncoding.length) {
                        NSScanner *scanner = [NSScanner scannerWithString:_typeEncoding];
                        if (![scanner scanString:@"@\"" intoString:NULL]) continue;
                        
                        NSString *clsName = nil;
                        if ([scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
                            if (clsName.length) _cls = objc_getClass(clsName.UTF8String);
                        }
                        
                        NSMutableArray *protocols = nil;
                        while ([scanner scanString:@"<" intoString:NULL]) {
                            NSString* protocol = nil;
                            if ([scanner scanUpToString:@">" intoString: &protocol]) {
                                if (protocol.length) {
                                    if (!protocols) protocols = [NSMutableArray new];
                                    [protocols addObject:protocol];
                                }
                            }
                            [scanner scanString:@">" intoString:NULL];
                        }
                        _protocols = protocols;
                    }
                }
            } break;
            case 'V': { // Instance variable
                if (attrs[i].value) {
                    _ivarName = [NSString stringWithUTF8String:attrs[i].value];
                }
            } break;
            case 'R': {
                type |= PDEncodingTypePropertyReadonly;
            } break;
            case 'C': {
                type |= PDEncodingTypePropertyCopy;
            } break;
            case '&': {
                type |= PDEncodingTypePropertyRetain;
            } break;
            case 'N': {
                type |= PDEncodingTypePropertyNonatomic;
            } break;
            case 'D': {
                type |= PDEncodingTypePropertyDynamic;
            } break;
            case 'W': {
                type |= PDEncodingTypePropertyWeak;
            } break;
            case 'G': {
                type |= PDEncodingTypePropertyCustomGetter;
                if (attrs[i].value) {
                    _getter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            } break;
            case 'S': {
                type |= PDEncodingTypePropertyCustomSetter;
                if (attrs[i].value) {
                    _setter = NSSelectorFromString([NSString stringWithUTF8String:attrs[i].value]);
                }
            } // break; commented for code coverage in next line
            default: break;
        }
    }
    if (attrs) {
        free(attrs);
        attrs = NULL;
    }
    
    _type = type;
    if (_name.length) {
        if (!_getter) {
            _getter = NSSelectorFromString(_name);
        }
        if (!_setter) {
            _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]]);
        }
    }
    return self;
}

+ (instancetype)propertyInfoWithClass:(NSString *)className property:(NSString *)propertyName {
    if (!className.length || !propertyName.length) {
        return nil;
    }
    
    static dispatch_semaphore_t lock;
    static NSMutableDictionary<NSString *, PDClassPropertyInfo *> *propertyCache;
    
#define Lock() dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(lock)
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lock = dispatch_semaphore_create(1);
        propertyCache = [NSMutableDictionary dictionary];
    });
    
    
    NSString *cacheKey = [NSString stringWithFormat:@"_%@_$_%@_", className, propertyName];
    Lock();
    PDClassPropertyInfo *propertyInfo = propertyCache[cacheKey];
    Unlock();
    if (propertyInfo) { return propertyInfo; }
    
    objc_property_t property = class_getProperty(NSClassFromString(className), [propertyName UTF8String]);
    propertyInfo = [[PDClassPropertyInfo alloc] initWithProperty:property];
    
    Lock();
    propertyCache[cacheKey] = propertyInfo;
    Unlock();
    return propertyInfo;
    
#undef Lock
#undef Unlock
}

@end
