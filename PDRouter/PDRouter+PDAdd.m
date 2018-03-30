//
//  PDRouter+PDAdd.m
//  PDRouter
//
//  Created by liang on 2018/3/4.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDRouter+PDAdd.h"
#import "ViewController.h"
#import "AppDelegate.h"

@implementation PDRouter (PDAdd)

- (void)registerEvents {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UINavigationController *navigationController = (UINavigationController *)appDelegate.window.rootViewController;
    
    [self on:@"/push" completionHandler:^(id  _Nullable sender, NSDictionary * _Nullable parameters) {
        NSLog(@"event = push, parameters = %@", parameters);
        ViewController *vc = [self createVC];
        vc.title = @"push";
        [navigationController pushViewController:vc animated:YES];
    }];
    
    [self on:@"/pushother" completionHandler:^(id  _Nullable sender, NSDictionary * _Nullable parameters) {
        NSLog(@"event = pushother, parameters = %@", parameters);
        ViewController *vc = [self createVC];
        vc.title = @"pushother";
        [navigationController pushViewController:vc animated:YES];
    }];
    
    [self on:@"/present" completionHandler:^(id  _Nullable sender, NSDictionary * _Nullable parameters) {
        NSLog(@"event = present, parameters = %@", parameters);
        ViewController *vc = [self createVC];
        vc.title = @"present";
        [navigationController presentViewController:vc animated:YES completion:nil];
    }];    
}

- (void)unregisterEvents {
    [self offAll];
}

- (ViewController *)createVC {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"vc"];
    return vc;
}

@end
