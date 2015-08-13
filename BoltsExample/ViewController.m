//
//  ViewController.m
//  BoltsExample
//
//  Created by Superbil on 2015/8/11.
//  Copyright (c) 2015年 Superbil. All rights reserved.
//

#import "ViewController.h"

#import <Bolts.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *actions;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.actions = @[@"Cancel Flow", @"Cancel Flow 2", @"Set Result", @"Set Result 2"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.actions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.actions[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 22.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self cancelFlow];
            break;
        case 1:
            [self cancelFlow2];
            break;
        case 2:
            [self setResultWithSource];
            break;
        case 3:
            [self setResultWithSource2];
            break;
        default:
            break;
    }
}

- (void)cancelFlow {
    NSLog(@"%s", __FUNCTION__);
    BFCancellationTokenSource *cts = [BFCancellationTokenSource cancellationTokenSource];
    [cts.token registerCancellationObserverWithBlock:^{
        NSLog(@"A");
    }];

    BFTask *task = [BFTask taskWithDelay:500];
    [task continueWithBlock:^id(BFTask *task) {
        NSLog(@"B");
        return nil;
    } cancellationToken:cts.token];

    NSLog(@"C");

    [cts cancel];
}

- (void)cancelFlow2 {
    NSLog(@"%s", __FUNCTION__);
    BFCancellationTokenSource *cts = [BFCancellationTokenSource cancellationTokenSource];
    [cts.token registerCancellationObserverWithBlock:^{
        NSLog(@"A");
    }];

    BFTask *task = [BFTask taskWithResult:nil];
    [task continueWithBlock:^id(BFTask *task) {
        NSLog(@"B");
        return nil;
    } cancellationToken:cts.token];

    NSLog(@"C");

    [cts cancel];
}

- (void)setResultWithSource {
    NSLog(@"%s", __FUNCTION__);
    BFTaskCompletionSource *s = [BFTaskCompletionSource taskCompletionSource];
    [s.task continueWithBlock:^id(BFTask *task) {
        NSLog(@"A");
        return nil;
    }];

    [s setResult:@YES];

    [s.task continueWithBlock:^id(BFTask *task) {
        NSLog(@"B");
        return nil;
    }];

    NSLog(@"C");
}

- (void)setResultWithSource2 {
    NSLog(@"%s", __FUNCTION__);
    BFTaskCompletionSource *s = [BFTaskCompletionSource taskCompletionSource];

    [[BFTask taskWithDelay:1] continueWithBlock:^id(BFTask *task) {
        [s setResult:@YES];
        return nil;
    }];

    [[s.task continueWithBlock:^id(BFTask *task) {
        NSLog(@"A");
        return task;
    }] continueWithBlock:^id(BFTask *task) {
        NSLog(@"B");
        return nil;
    }];

    [s.task continueWithBlock:^id(BFTask *task) {
        NSLog(@"C");
        return nil;
    }];

    NSLog(@"D");
}

@end
