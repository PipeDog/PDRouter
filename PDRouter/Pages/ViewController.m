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

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    if (self.navigationController) {
        [[PDRouterAgent defaultAgent] setNavigationController:self.navigationController];
    }
}

#pragma mark - UITableView Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse" forIndexPath:indexPath];
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        // push
        [[PDRouter defaultRouter] openURL:[PDRouterHost stringByAppendingString:@"/push"] routerParams:@{@"title": @"push"}];
    } else if (indexPath.row == 1) {
        // present
        [[PDRouter defaultRouter] openURL:[PDRouterHost stringByAppendingString:@"/present"] routerParams:nil];
    } else if (indexPath.row == 2) {
        // dismiss
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (indexPath.row == 3) {
        // web
        [[PDRouter defaultRouter] openURL:@"https://www.baidu.com" routerParams:nil];
    } else if (indexPath.row == 4) {
        // group/first
        [[PDRouter defaultRouter] openURL:[PDRouterHost stringByAppendingString:@"/group/first"] routerParams:@{@"title": @"first"}];
    } else if (indexPath.row == 5) {
        // group/second
        [[PDRouter defaultRouter] openURL:[PDRouterHost stringByAppendingString:@"/group/second"] routerParams:@{@"title": @"second"}];
    } else if (indexPath.row == 6) {
        // group/third
        [[PDRouter defaultRouter] openURL:[PDRouterHost stringByAppendingString:@"/group/third?title=third"] routerParams:@{@"testKey": @"testValue"}];
    } else if (indexPath.row == 7) {
        // pageClass/register
        PDRouterRegister(PDTestViewController);
    } else if (indexPath.row == 8) {
        // pageClass/open
        PDRouterOpen(PDTestViewController, @{@"inputKey": @"inputValue"});
    }
}

#pragma mark - Getter Methods
- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[@"push",
                       @"present",
                       @"dismiss",
                       @"web",
                       @"group/first",
                       @"group/second",
                       @"group/third",
                       @"pageClass/register",
                       @"pageClass/open"];
    }
    return _dataArray;
}

@end
