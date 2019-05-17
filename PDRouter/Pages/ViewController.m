//
//  ViewController.m
//  PDRouter
//
//  Created by liang on 2018/3/3.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "ViewController.h"
#import "PDRouter.h"
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
    if (![PDRouter globalRouter].navigationController) {
        [PDRouter globalRouter].navigationController = self.navigationController;
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
        [[PDRouter globalRouter] openURL:@"PDPage" routerParams:@{@"title": @"push跳转"}];
    } else if (indexPath.row == 1) {
        // present
        [[PDRouter globalRouter] openURL:@"ViewControllerPresent" routerParams:@{@"present": @(1)}];
    } else if (indexPath.row == 2) {
        // dismiss
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if (indexPath.row == 3) {
        // web
        [[PDRouter globalRouter] openURL:@"https://www.baidu.com" routerParams:nil];
    } else if (indexPath.row == 4) {
        // log
        [[PDRouter globalRouter] openURL:@"log" routerParams:@{@"arg1": @"value"}];
    } else if (indexPath.row == 5) {
        // withParam
        [[PDRouter globalRouter] openURL:@"pdog://openpage?title=这是title&key=value" routerParams:@{@"key1": @"value", @"key2": @(2)}];
    } else if (indexPath.row == 6) {
        [[PDRouter globalRouter] openURL:@"pdog://firstpage/?key=value&key1=value1" routerParams:@{@"append": @(1)}];
    } else if (indexPath.row == 7) {
        [[PDRouter globalRouter] openURL:@"pdog://secondpage/path?key=value&key1=value1" routerParams:@{@"append": @(1)}];
    } else if (indexPath.row == 8) {
        [[PDRouter globalRouter] openURL:@"pdog://testpage?key=value&key1=value1" routerParams:@{@"append": @(1), @"title": @"This is title."}];
    } else if (indexPath.row == 9) {
        [[PDRouter globalRouter] openURL:@"pdog://thirdpage/path/?key=value&key1=value1" routerParams:@{@"append": @(1), @"title": @"This is title."}];
    } else if (indexPath.row == 10) {
        [[PDRouter globalRouter] openURL:@"PDTestViewController" routerParams:@{@"title": @"test title"}];
    }
}

#pragma mark - Getter Methods
- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[@"push",
                       @"present",
                       @"dismiss",
                       @"web",
                       @"log",
                       @"withParam",
                       @"pdog://firstpage/",
                       @"pdog://secondpage/path",
                       @"pdog://testpage",
                       @"pdog://thirdpage/path/",
                       @"PDTestViewController"];
    }
    return _dataArray;
}

@end
