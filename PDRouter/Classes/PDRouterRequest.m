//
//  PDRouterRequest.m
//  PDPower
//
//  Created by liang on 2024/3/19.
//

#import "PDRouterRequest.h"

@implementation PDRouterRequest

- (instancetype)initWithURLString:(NSString *)urlString
                       parameters:(NSDictionary<NSString *,id> *)parameters {
    self = [super init];
    if (self) {
        _urlString = [urlString copy];
        _parameters = [parameters copy];
    }
    return self;
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: %p", NSStringFromClass([self class]), self];
    [description appendFormat:@"\n `urlString`: %@", self.urlString];
    [description appendFormat:@"\n `parameters`: %@", self.parameters];
    [description appendString:@"\n>"];
    return description;
}

@end
