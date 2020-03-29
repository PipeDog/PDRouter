//
//  NSString+PDAdd.h
//  PDRouter
//
//  Created by liang on 2020/3/29.
//  Copyright © 2020 PipeDog. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (PDAdd)

- (NSString *)pd_encodeWithURLQueryAllowedCharacterSet;

@end

NS_ASSUME_NONNULL_END
