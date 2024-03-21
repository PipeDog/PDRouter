# PDRouter

__PDRouter__ 是一个用于 __iOS__ 的轻量级路由框架，支持 URL 路由、拦截器、自定义页面参数映射等功能。

### 特性
- 支持通过 URL 打开页面
- 支持自定义拦截器，进行路由拦截和处理
- 支持自动和手动接收路由参数
- 支持自定义路由参数到页面属性的映射

### 安装

通过 CocoaPods 安装

```ruby
pod 'PDRouter'
```

## 使用

### 1. 导出页面

使用 `PD_EXPORT_PAGE` 宏在您的视图控制器中导出页面：

```objc
PD_EXPORT_PAGE("pipedog://open/page/intro", PDIntroViewController)

@interface PDIntroViewController : UIViewController
@end
```

### 2. 打开页面

使用 `PDRouter` 的 `openURL:` 方法来打开一个页面：

```objc
[[PDRouter globalRouter] openURL:@"pipedog://open/page/intro"];
```

### 3. 接收参数

您的视图控制器可以通过实现 `PDRouterAutoParamReceiver` 或 `PDRouterManualParamReceiver` 协议来接收路由参数：

```objc
@interface PDIntroViewController : UIViewController <PDRouterAutoParamReceiver>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
@end

@implementation PDIntroViewController

- (NSDictionary<PDRouterParameterKey, PDRouterTargetProperty> *)routerCustomPropertyMapper {
    return @{@"n": @"name",
             @"p": @"page",
             @"h": @"height"};
}

@end
```

### 4. 拦截器

您可以通过实现 `PDRouterInterceptor` 协议并使用 `addInterceptor:` 方法来添加自定义拦截器：

```objc
@interface MyCustomInterceptor : NSObject <PDRouterInterceptor>
@end

@implementation MyCustomInterceptor

- (BOOL)intercept:(id<PDRouterInterceptorChain>)chain {
    // 自定义拦截逻辑
    return [chain proceed:chain.request];
}

@end

// 添加拦截器
[[PDRouter globalRouter] addInterceptor:[[MyCustomInterceptor alloc] init]];
```

## 许可证

__PDRouter__ 使用 __MIT__ 许可证，详见 __LICENSE__ 文件。
