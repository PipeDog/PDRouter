//
//  PDTestViewController.m
//  PDRouter
//
//  Created by liang on 2018/7/19.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDTestViewController.h"

@interface PDTestViewController ()

@end

@implementation PDTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = self.routerParams[@"title"];
    
    NSLog(@"params = [%@]", self.routerParams);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
