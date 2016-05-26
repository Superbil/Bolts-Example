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
    self.actions = @[@"Cancel Flow", @"Cancel Flow 2", @"Set Result", @"Set Result 2", @"Cancel token", @"Set Result or Cancel", @"Just Cancel"];

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
        case 4:
            [self cancelToken];
            break;
        case 5:
            [self setResultOrCancel];
            break;
        case 6:
            [self justCancel];
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
        NSLog(@"result: %@", task.result);
        NSLog(@"A");
        return nil;
    }];

    [s setResult:@"E"];

    [s.task continueWithBlock:^id(BFTask *task) {
        NSLog(@"result: %@", task.result);
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

- (void)cancelToken {
    __block BOOL cancel = NO;

    BFTaskCompletionSource *s = [BFTaskCompletionSource taskCompletionSource];

    BFCancellationTokenSource *cts = [BFCancellationTokenSource cancellationTokenSource];
    [cts.token registerCancellationObserverWithBlock:^{
        cancel = YES;
        NSLog(@"D");
        [s setResult:nil];
    }];

    [[BFTask taskWithDelay:10] continueWithBlock:^id(BFTask *task) {
        [cts cancel];
        NSLog(@"cacnel %@", cancel ? @"YES":@"NO");
        return nil;
    }];

    [s.task continueWithBlock:^id(BFTask *task) {
        if (task.cancelled) {
            NSLog(@"C");
        }
        NSLog(@"A");
        return nil;
    } cancellationToken:cts.token];

    NSLog(@"B");
    NSLog(@"cacnel %@", cancel ? @"YES":@"NO");
}

- (void)setResultOrCancel {
    BFTaskCompletionSource *s = [BFTaskCompletionSource taskCompletionSource];

    BFCancellationTokenSource *cts = [BFCancellationTokenSource cancellationTokenSource];
    [cts.token registerCancellationObserverWithBlock:^{
        NSLog(@"D");
    }];

    [[BFTask taskWithDelay:10] continueWithBlock:^id(BFTask *task) {
        [s setResult:nil];
        return nil;
    }];

    [s.task continueWithBlock:^id(BFTask *task) {
        if (task.cancelled) {
            NSLog(@"C");
        }
        NSLog(@"A");
        return nil;
    } cancellationToken:cts.token];

    NSLog(@"B");
}

- (void)justCancel {
    BFTaskCompletionSource *s = [BFTaskCompletionSource taskCompletionSource];

    [[BFTask taskWithDelay:10] continueWithBlock:^id(BFTask *task) {
        [s cancel];
        return nil;
    }];

    [s.task continueWithBlock:^id(BFTask *task) {
        if (task.cancelled) {
            NSLog(@"C");
        }
        NSLog(@"A");
        return nil;
    }];

    NSLog(@"B");
}

@end
