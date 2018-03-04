//
//  PDRouterProtocol.h
//  PDRouter
//
//  Created by liang on 2018/3/4.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PDRouterProtocol <NSObject>

- (BOOL)openURL:(NSURL *)url; // Handle the url of the unregistered event.

@end
