//
//  NSURL+PDAdd.m
//  PDRouter
//
//  Created by liang on 2018/3/4.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "NSURL+PDAdd.h"

@implementation NSURL (PDAdd)

- (NSDictionary <NSString *, NSString *>*)queryParameters {
    NSURLComponents *components = [NSURLComponents componentsWithString:self.absoluteString];
    NSArray<NSURLQueryItem *> *queryItems = components.queryItems;
    NSMutableDictionary<NSString *, id> *queryDict = [NSMutableDictionary dictionary];
    
    for (NSURLQueryItem *item in queryItems) {
        if (!item.name.length || !item.value) continue;
        [queryDict setObject:item.value forKey:item.name];
    }
    return [queryDict copy];
}

@end
