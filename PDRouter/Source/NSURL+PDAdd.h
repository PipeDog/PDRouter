//
//  NSURL+PDAdd.h
//  PDRouter
//
//  Created by liang on 2018/3/4.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (PDAdd)

@property (nonatomic, copy, readonly) NSDictionary<NSString *, NSString *> *queryParameters;

@end

NS_ASSUME_NONNULL_END
