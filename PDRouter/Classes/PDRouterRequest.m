//
//  PDRouterRequest.m
//  PDRouter
//
//  Created by liang on 2024/4/22.
//

#import "PDRouterRequest.h"

@interface PDRouterRequest ()

- (instancetype)initWithURLString:(NSString *)urlString
                       parameters:(NSDictionary<NSString *,id> *)parameters
                          payload:(NSDictionary<NSString *,id> *)payload;

@end

@implementation PDRouterRequestBuilder

- (instancetype)initWithRequest:(PDRouterRequest *)request {
    self = [super init];
    if (self) {
        _urlString = [request.urlString copy];
        _parameters = [request.parameters copy];
        _payload = [request.payload copy];
    }
    return self;
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key {
    NSMutableDictionary *map = self.payload ? [self.payload mutableCopy] : [NSMutableDictionary dictionary];
    map[key] = obj;
    self.payload = map;
}

- (id)objectForKeyedSubscript:(NSString *)key {
    return self.payload[key];
}

- (PDRouterRequest *)build {
    return [[PDRouterRequest alloc] initWithURLString:self.urlString
                                           parameters:self.parameters
                                              payload:self.payload];
}

@end

@implementation PDRouterRequest

@synthesize urlString = _urlString;
@synthesize parameters = _parameters;
@synthesize payload = _payload;

- (instancetype)initWithURLString:(NSString *)urlString
                       parameters:(NSDictionary<NSString *,id> *)parameters
                          payload:(NSDictionary<NSString *,id> *)payload {
    self = [super init];
    if (self) {
        _urlString = [urlString copy];
        _parameters = [parameters copy];
        _payload = [payload copy];
    }
    return self;
}

- (PDRouterRequestBuilder *)newBuilder {
    return [[PDRouterRequestBuilder alloc] initWithRequest:self];
}

- (NSString *)description {
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: %p", NSStringFromClass([self class]), self];
    [description appendFormat:@"\n urlString: %@", self.urlString];
    [description appendFormat:@"\n parameters: %@", self.parameters];
    [description appendFormat:@"\n payload: %@", self.payload];
    [description appendString:@"\n>"];
    return description;
}

@end
