//
//  UIApplication+PDAdd.h
//  PDRouter
//
//  Created by liang on 2019/5/17.
//  Copyright © 2019 PipeDog. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (PDAdd)

// Call phone.
- (void)callPhone:(NSString *)phone completion:(void (^ __nullable)(BOOL success))completion;

// Open system preferences.
- (void)openSystemPreferencesWithCompletion:(void (^ __nullable)(BOOL success))completion;

// Open the custom url, adapt to different system versions.
- (void)openURL:(NSString *)urlString completion:(void (^ __nullable)(BOOL success))completion;

@end

NS_ASSUME_NONNULL_END
