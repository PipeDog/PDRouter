//
//  NSString+PDAdd.m
//  PDRouter
//
//  Created by liang on 2020/3/29.
//  Copyright © 2020 PipeDog. All rights reserved.
//

#import "NSString+PDAdd.h"

@implementation NSString (PDAdd)

- (NSString *)pd_encodeWithURLQueryAllowedCharacterSet {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

@end
