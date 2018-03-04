//
//  PDRouterHelper.h
//  PDRouter
//
//  Created by liang on 2018/3/4.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDRouter.h"

@interface PDRouterHelper : NSObject <PDRouterProtocol>

@property (class, nonatomic, strong, readonly) PDRouterHelper *defaultHelper;

@end
