//
//  PDRouter+PDAdd.m
//  PDRouter
//
//  Created by liang on 2019/5/17.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import "PDRouter+PDAdd.h"

@implementation PDRouter (PDAdd)

- (void)registerEvents {
    [self registerEventHandler:^(NSDictionary * _Nullable routerParams) {
        NSLog(@"log => %@", routerParams);
    } forPattern:@"log"];
    
    [self registerClass:NSClassFromString(@"PDPage") forPattern:@"ViewControllerPresent"];
    [self registerClass:NSClassFromString(@"PDPage") forPattern:@"pdog://openpage"];
    
    // Read routes from plist
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RouteConfig" ofType:@"plist"];
    NSDictionary *routes = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    [routes enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self registerClass:NSClassFromString(obj) forPattern:key];
    }];
}

@end
