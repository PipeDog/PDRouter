//
//  PDManualParamViewController.m
//  PDRouter_Example
//
//  Created by liang on 2024/3/21.
//  Copyright © 2024 liang. All rights reserved.
//

#import "PDManualParamViewController.h"
#import "PDRouter.h"

PD_EXPORT_PAGE("dog://open/page/manualparam", PDManualParamViewController)

@interface PDManualParamViewController () <PDRouterManualParamReceiver>

@end

@implementation PDManualParamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Manual Param";
}

#pragma mark - PDRouterManualParamReceiver
- (void)onRouterParameters:(NSDictionary<NSString *,id> *)parameters {
    NSLog(@"PDManualParamViewController#onRouterParameters -> parameters: %@.", parameters);
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
