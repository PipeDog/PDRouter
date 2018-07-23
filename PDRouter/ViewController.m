//
//  ViewController.m
//  PDRouter
//
//  Created by liang on 2018/3/3.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "ViewController.h"
#import "PDRouter.h"
#import "PDRouterAgent.h"
#import "PDPage.h"
#import "PDTestViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if (self.navigationController) {
        [[PDRouterAgent defaultAgent] setNavigationController:self.navigationController];
    }
}

- (IBAction)openURL:(id)sender {
    PDRouterOpen([PDTestViewController class], @{@"title": @"测试"});
}

- (IBAction)push:(id)sender {
    [[PDRouter defaultRouter] sendAction:@"pdog://net.pipedog.com/push?action=push&age=26" params:@{@"doc": @"file", @"key": @"value"} from:self];
}

- (IBAction)pushOtherEvent:(id)sender {
    [[PDRouter defaultRouter] sendAction:@"pdog://net.pipedog.com/pushother?action=pushother&author="];
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)present:(id)sender {
    [[PDRouter defaultRouter] sendAction:@"pdog://net.pipedog.com/present?action=present&author=http://www.baidu.com"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
