//
//  PDPropertyMapper.m
//  PDRouter
//
//  Created by liang on 2024/3/22.
//

#import "PDPropertyMapper.h"

@implementation NSObject (PDPropertyMapper)

- (void)setPropertyValues:(NSDictionary<NSString *,id> *)keyValuePairs {
    [self setPropertyValues:keyValuePairs mapperBlock:nil];
}

- (void)setPropertyValues:(NSDictionary<NSString *,id> *)keyValuePairs
              mapperBlock:(PDObjectPropertyMapperBlock)block {
    [[PDObjectPropertyMapper defaultMapper] mapKeyValuePairs:keyValuePairs
                                                    toObject:self
                                                 mapperBlock:block];
}

@end
