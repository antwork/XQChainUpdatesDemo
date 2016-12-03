//
//  ViewController.m
//  XQChainUpdatesDemo
//
//  Created by qxu on 2016/12/1.
//  Copyright © 2016年 qxu. All rights reserved.
//

#import "RootViewController.h"
#import "XQChainUpdates.h"
#import "DynamicChangeValueInCellController.h"
#import "DynamicChangeHeihgtInCellController.h"

@interface Model : NSObject

@property (nonatomic, strong) NSString *name;

@end

@implementation Model


@end

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"ChainUpdateDemo";
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSInteger row = indexPath.row;
    if (row == 0) {
        cell.textLabel.text = @"Dynamic value";
    } else if (row == 1) {
        cell.textLabel.text = @"Dynamic height";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    if (row == 0) {
        DynamicChangeValueInCellController *tb = [[DynamicChangeValueInCellController alloc] init];
        [self.navigationController pushViewController:tb animated:true];
    } else if (row == 1) {
        DynamicChangeHeihgtInCellController *tb = [[DynamicChangeHeihgtInCellController alloc] init];
        [self.navigationController pushViewController:tb animated:true];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
