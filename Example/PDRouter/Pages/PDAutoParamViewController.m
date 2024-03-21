//
//  PDAutoParamViewController.m
//  PDRouter_Example
//
//  Created by liang on 2024/3/21.
//  Copyright © 2024 liang. All rights reserved.
//

#import "PDAutoParamViewController.h"
#import "PDRouter.h"

PD_EXPORT_PAGE("dog://open/page/autoparam", PDAutoParamViewController)

@interface PDAutoParamViewController () <PDRouterAutoParamReceiver>

// 路由参数与属性同名，直接赋值
@property (nonatomic, copy) NSDictionary *map;
@property (nonatomic, copy) NSArray *array;

// 路由参数与属性不同名，通过映射进行赋值
@property (nonatomic, copy) NSString *stringValue;
@property (nonatomic, assign) NSInteger intValue;
@property (nonatomic, assign) CGFloat floatValue;

@end

@implementation PDAutoParamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Auto Param";
    
    NSLog(@"PDAutoParamViewController#viewDidLoad -> \n`map`: %@,\n`array`: %@,\n`stringValue`: %@,\n`intValue`: %zd,\n,`floatValue`: %lf\n.", self.map, self.array, self.stringValue, self.intValue, self.floatValue);
}

#pragma mark - PDRouterAutoParamReceiver
- (NSDictionary<PDRouterParameterKey,PDRouterTargetProperty> *)routerCustomPropertyMapper {
    return @{
        @"s": @"stringValue",
        @"i": @"intValue",
        @"f": @"floatValue"
    };
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
