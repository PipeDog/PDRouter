//
//  PDRouterParamReceiver.h
//  PDRouter
//
//  Created by liang on 2024/3/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 `PDRouterParameterKey` 表示路由传递参数的键名
 
 用于在路由参数字典中标识参数的键。例如，如果路由参数字典为 @{@"username": @"JohnDoe"}，
 则 `PDRouterParameterKey` 对应的是 @"username"
 */
typedef NSString * PDRouterParameterKey;

/**
 `PDRouterTargetProperty` 表示路由目标页面的属性名称
 
 用于标识目标视图控制器中应接收路由参数的属性。例如，如果目标视图控制器有一个名为
 `username` 的属性，且需要接收路由参数，则 `PDRouterTargetProperty` 对应的是 @"username"
 */
typedef NSString * PDRouterTargetProperty;

/**
 `PDRouterAutoParamReceiver` 协议允许视图控制器自动接收并将路由参数映射到其属性中

 实现此协议的视图控制器可以自动将路由参数赋值给其对应的属性。例如：

 @code
 PD_EXPORT_PAGE("pipedog://open/page/intro", PDIntroViewController)

 @interface PDIntroViewController : UIViewController <PDRouterAutoParamReceiver>
 @property (nonatomic, copy) NSString *name;
 @property (nonatomic, assign) NSInteger age;
 @end
 @endcode

 使用注册的 `pagepath` 进行页面跳转时，会自动将 `parameters` 中的值赋给目标页面的属性：

 @code
 [[PDRouter globalRouter] openURL:@"pipedog://open/page/intro" parameters:@{@"name": @"Tom", @"age": @20}];
 @endcode

 此时，`PDIntroViewController` 的 `name` 属性将被设置为 "Tom"，`age` 属性将被设置为 20

 如果路由参数的键名和对象的属性名不一致，可以通过实现 `routerCustomPropertyMapper` 方法来自定义映射：

 @code
 - (NSDictionary<PDRouterParameterKey, PDRouterTargetProperty> *)routerCustomPropertyMapper {
     return @{@"n": @"name",
              @"p": @"page",
              @"h": @"height"};
 }
 @endcode

 这样，在路由参数中使用键 "n"、"p"、"h" 时，它们将分别映射到视图控制器的 "name"、"page"、"height" 属性
 */
@protocol PDRouterAutoParamReceiver <NSObject>

@optional

/**
 获取自定义属性映射表

 该方法用于映射传入的参数字典中的键到接收对象的属性名。这允许开发者在路由参数的键名和对象的属性名不一致时进行自定义映射

 @return 一个字典，其中键是传入参数字典中的键名，值是接收对象中对应的属性名

 示例用法:
 @code
 - (NSDictionary<PDRouterParameterKey, PDRouterTargetProperty> *)routerCustomPropertyMapper {
     return @{@"n": @"name",
              @"p": @"page",
              @"h": @"height"};
 }
 @endcode
 */
- (NSDictionary<PDRouterParameterKey, PDRouterTargetProperty> *)routerCustomPropertyMapper;

@end


/**
 `PDRouterManualParamReceiver` 协议允许视图控制器手动接收路由参数

 实现此协议的视图控制器需要通过实现 `onRouterParameters:` 方法来手动处理路由参数
 */
@protocol PDRouterManualParamReceiver <NSObject>

/**
 接收并处理从路由传递过来的参数

 @param parameters 从路由传递过来的参数字典
 */
- (void)onRouterParameters:(nullable NSDictionary<NSString *, id> *)parameters;

@end

NS_ASSUME_NONNULL_END
