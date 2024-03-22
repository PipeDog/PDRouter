//
//  PDViewController.m
//  PDRouter
//
//  Created by liang on 03/21/2024.
//  Copyright (c) 2024 liang. All rights reserved.
//

#import "PDViewController.h"
#import "PDRouter.h"
#import "PDLogInterceptor.h"

@interface PDViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSArray *dataArray;

@end

@implementation PDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"导航测试入口";
    
    [PDRouter globalRouter].navigator = self.navigationController;
    [[PDRouter globalRouter] addInterceptor:[[PDLogInterceptor alloc] init]];
}

#pragma mark - UITableView Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseCellId" forIndexPath:indexPath];
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *rowId = self.dataArray[indexPath.row];
    if ([rowId isEqualToString:@"dog://open/page/autoparam"]) {
        [[PDRouter globalRouter] openURL:@"dog://open/page/autoparam" parameters:@{
            @"map": @{@"k1": @"v1", @"k2": @2},
            @"array": @[@"e1", @2, @"e3", @4.0],
            @"s": @"This is a string value.",
            @"i": @123,
            @"f": @3.001,
            @"none": @900,
            @"str": @"str"
        }];
    } else if ([rowId isEqualToString:@"dog://open/page/manualparam"]) {
        [[PDRouter globalRouter] openURL:@"dog://open/page/manualparam" parameters:@{
            @"map": @{@"k1": @"v1", @"k2": @2},
            @"array": @[@"e1", @2, @"e3", @4.0],
        }];
    }
}

#pragma mark - Getter Methods
- (NSArray *)dataArray {
    if (!_dataArray) {
        _dataArray = @[
            @"dog://open/page/autoparam",
            @"dog://open/page/manualparam"
        ];
    }
    return _dataArray;
}

@end
