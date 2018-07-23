//
//  PDRouterAgent+PDAdd.m
//  PDRouter
//
//  Created by liang on 2018/7/23.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDRouterAgent+PDAdd.h"
#import "PDRouter.h"
#import "PDTestViewController.h"
#import "ViewController.h"

@implementation PDRouterAgent (PDAdd)

- (void)registerEvents {
    UINavigationController *navigationController = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    PDRouter *router = [PDRouter defaultRouter];

    // Single register.
    [router on:@"/push" eventHandler:^(NSDictionary *routerParams) {
        PDTestViewController *page = [[PDTestViewController alloc] init];
        page.routerParams = routerParams;
        [navigationController pushViewController:page animated:YES];
    }];

    [router on:@"/present" eventHandler:^(NSDictionary *routerParams) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *page = [storyboard instantiateViewControllerWithIdentifier:@"vc"];
        
        page.title = @"present";
        [navigationController presentViewController:page animated:YES completion:nil];
    }];

    // Group register.
    [router onGroup:@"/group" eventHandler:^(PDRouterGroup *group) {
        
        [group on:@"/first" eventHandler:^(NSDictionary *routerParams) {
            PDTestViewController *page = [[PDTestViewController alloc] init];
            page.routerParams = routerParams;
            [navigationController pushViewController:page animated:YES];
        }];
        
        [group on:@"/second" eventHandler:^(NSDictionary *routerParams) {
            PDTestViewController *page = [[PDTestViewController alloc] init];
            page.routerParams = routerParams;
            [navigationController pushViewController:page animated:YES];
        }];
        
        [group on:@"/third" eventHandler:^(NSDictionary *routerParams) {
            PDTestViewController *page = [[PDTestViewController alloc] init];
            page.routerParams = routerParams;
            [navigationController pushViewController:page animated:YES];
        }];
    }];
}

@end
