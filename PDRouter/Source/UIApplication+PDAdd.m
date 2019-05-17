//
//  UIApplication+PDAdd.m
//  PDRouter
//
//  Created by liang on 2019/5/17.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import "UIApplication+PDAdd.h"

@implementation UIApplication (PDAdd)

- (void)callPhone:(NSString *)phone completion:(void (^)(BOOL))completion {
    NSString *tel = [NSString stringWithFormat:@"tel://%@", phone];
    [self openURL:tel completion:completion];
}

- (void)openSystemPreferencesWithCompletion:(void (^)(BOOL))completion {
    NSString *urlString;
    
    if ([[UIDevice currentDevice].systemVersion integerValue] >= 8) {
        urlString = UIApplicationOpenSettingsURLString;
    } else {
        urlString = @"prefs://";
    }
    [self openURL:urlString completion:completion];
}

- (void)openURL:(NSString *)urlString completion:(void (^)(BOOL))completion {
    NSURL *url = [NSURL URLWithString:(urlString ?: @"")];
    
    if (![self canOpenURL:url]) {
        if (completion) completion(NO);
        return;
    }
    
    if (@available(iOS 10, *)) {
        [self openURL:url options:@{} completionHandler:completion];
    } else {
        [self openURL:url];
        if (completion) completion(YES);
    }
}

@end
