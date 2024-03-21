//
//  PDClassPropertyInfo.h
//  PDModelKVMapper
//
//  Created by liang on 2020/11/24.
//
//  The fllow code from `YYModel`
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Type encoding's type.
 */
typedef NS_OPTIONS(NSUInteger, PDEncodingType) {
    PDEncodingTypeMask       = 0xFF, ///< mask of type value
    PDEncodingTypeUnknown    = 0, ///< unknown
    PDEncodingTypeVoid       = 1, ///< void
    PDEncodingTypeBool       = 2, ///< bool
    PDEncodingTypeInt8       = 3, ///< char / BOOL
    PDEncodingTypeUInt8      = 4, ///< unsigned char
    PDEncodingTypeInt16      = 5, ///< short
    PDEncodingTypeUInt16     = 6, ///< unsigned short
    PDEncodingTypeInt32      = 7, ///< int
    PDEncodingTypeUInt32     = 8, ///< unsigned int
    PDEncodingTypeInt64      = 9, ///< long long
    PDEncodingTypeUInt64     = 10, ///< unsigned long long
    PDEncodingTypeFloat      = 11, ///< float
    PDEncodingTypeDouble     = 12, ///< double
    PDEncodingTypeLongDouble = 13, ///< long double
    PDEncodingTypeObject     = 14, ///< id
    PDEncodingTypeClass      = 15, ///< Class
    PDEncodingTypeSEL        = 16, ///< SEL
    PDEncodingTypeBlock      = 17, ///< block
    PDEncodingTypePointer    = 18, ///< void*
    PDEncodingTypeStruct     = 19, ///< struct
    PDEncodingTypeUnion      = 20, ///< union
    PDEncodingTypeCString    = 21, ///< char*
    PDEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    PDEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    PDEncodingTypeQualifierConst  = 1 << 8,  ///< const
    PDEncodingTypeQualifierIn     = 1 << 9,  ///< in
    PDEncodingTypeQualifierInout  = 1 << 10, ///< inout
    PDEncodingTypeQualifierOut    = 1 << 11, ///< out
    PDEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    PDEncodingTypeQualifierByref  = 1 << 13, ///< byref
    PDEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    PDEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    PDEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    PDEncodingTypePropertyCopy         = 1 << 17, ///< copy
    PDEncodingTypePropertyRetain       = 1 << 18, ///< retain
    PDEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    PDEncodingTypePropertyWeak         = 1 << 20, ///< weak
    PDEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    PDEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    PDEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};

/**
 Get the type from a Type-Encoding string.
 
 @discussion See also:
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
 https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
 
 @param typeEncoding  A Type-Encoding string.
 @return The encoding type.
 */
PDEncodingType PDEncodingGetType(const char *typeEncoding);

@interface PDClassPropertyInfo : NSObject

@property (nonatomic, assign, readonly) objc_property_t property; ///< property's opaque struct
@property (nonatomic, strong, readonly) NSString *name;           ///< property's name
@property (nonatomic, assign, readonly) PDEncodingType type;      ///< property's type
@property (nonatomic, strong, readonly) NSString *typeEncoding;   ///< property's encoding value
@property (nonatomic, strong, readonly) NSString *ivarName;       ///< property's ivar name
@property (nullable, nonatomic, assign, readonly) Class cls;      ///< may be nil
@property (nullable, nonatomic, strong, readonly) NSArray<NSString *> *protocols; ///< may nil
@property (nonatomic, assign, readonly) SEL getter;               ///< getter (nonnull)
@property (nonatomic, assign, readonly) SEL setter;               ///< setter (nonnull)

/**
 Creates and returns a property info object.
 
 @param property property opaque struct
 @return A new object, or nil if an error occurs.
 */
- (instancetype)initWithProperty:(objc_property_t)property;

/**
 Creates and returns a property info object (maybe from cache).
 
 @param className class name
 @param propertyName property name
 @return A new object, or nil if an error occurs.
 */
+ (instancetype)propertyInfoWithClass:(NSString *)className property:(NSString *)propertyName;

@end

NS_ASSUME_NONNULL_END
