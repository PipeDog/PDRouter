//
//  PDRouterPageRegistry.h
//  PDPower
//
//  Created by liang on 2024/3/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 结构体定义了页面路径和对应的视图控制器类名
 */
typedef struct {
    const char *pagePath;   // 页面路径
    const char *className;  // 视图控制器的类名
} PDPageRouteInfo;

/* 定义导出页面的宏 */
#define __PD_EXPORT_PAGE_EXT(pagePath, className)       \
__attribute__((used, section("__DATA , pd_exp_page")))  \
static const PDPageRouteInfo __pd_exp_page_##className##__ = {pagePath, #className};


/**
 * PDRouterPageRegistry 类负责管理和查询所有导出的页面信息
 */
@interface PDRouterPageRegistry : NSObject

/**
 * 获取全局的页面注册管理器单例
 */
@property (class, strong, readonly) PDRouterPageRegistry *defaultRegistry;

/**
 * 根据页面路径获取对应的视图控制器类
 *
 * @param path 页面路径
 * @return 对应的视图控制器类，如果未找到则返回 nil
 */
- (nullable Class)classForPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
