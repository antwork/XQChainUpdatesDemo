//
//  DynamicChangeHeihgtInCellController.m
//  XQChainUpdatesDemo
//
//  Created by qxu on 03/12/2016.
//  Copyright © 2016 qxu. All rights reserved.
//

#import "DynamicChangeHeihgtInCellController.h"
#import "XQChainUpdates.h"
#import "DynamicHeightCell.h"

@interface HeightModel : NSObject

@property (nonatomic, strong) NSNumber *isChoosed;

@end

@implementation HeightModel


@end

@interface DynamicChangeHeihgtInCellController ()

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation DynamicChangeHeihgtInCellController

- (void)dealloc {
    for (HeightModel *model in self.items) {
        [model removeChainByPath87:nil];
    }
    NSLog(@"tb dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.items = [NSMutableArray array];
    for (int i = 0; i < 100; i++) {
        HeightModel *model = [[HeightModel alloc] init];
        [self.items addObject:model];
    }
    NSString *name = NSStringFromClass(DynamicHeightCell.class);
    
    [self.tableView registerNib:[UINib nibWithNibName:name bundle:nil] forCellReuseIdentifier:name];
    
    [self setAutomaticallyAdjustsScrollViewInsets:true];
    
    //    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *name = NSStringFromClass(DynamicHeightCell.class);
    DynamicHeightCell *cell = [tableView dequeueReusableCellWithIdentifier:name];
    
    HeightModel *model = self.items[indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    __weak typeof(cell) weakCell = cell;
    [model chainPath87:@"isChoosed" view:cell.contentLabel manualUpdate:true action:^(NSObject *obj) {
        __strong typeof (weakCell) strongCell = weakCell;
        
        HeightModel *tmpModel = (HeightModel *)obj;
        BOOL choosed = [tmpModel.isChoosed boolValue];
        NSString *title = choosed?@"-":@"+";
        [strongCell.operateButton setTitle:title forState:UIControlStateNormal];
        
        NSInteger index = [weakSelf.items indexOfObject:obj];
        if (index != NSNotFound) {
            NSIndexPath *idx = [NSIndexPath indexPathForRow:index inSection:0];
            
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView endUpdates];
            
            [weakSelf.tableView scrollToRowAtIndexPath:idx atScrollPosition:UITableViewScrollPositionNone animated:NO];
        }
    }];
    cell.operateButton.tag = indexPath.row;
    [cell.operateButton removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    [cell.operateButton addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
    cell.contentLabel.text = @"Swift is a new programming language for iOS, macOS, watchOS, and tvOS apps that builds on the best of C and Objective-C, without the constraints of C compatibility. Swift adopts safe programming patterns and adds modern features to make programming easier, more flexible, and more fun. Swift’s clean slate, backed by the mature and much-loved Cocoa and Cocoa Touch frameworks, is an opportunity to reimagine how software development works";
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HeightModel *model = self.items[indexPath.row];
    if ([model.isChoosed boolValue]) {
        return 120;
    }
    
    return 44;
}

- (void)add:(UIButton *)sender {
    NSInteger tag = sender.tag;
    HeightModel *model = [self.items objectAtIndex:tag];
    model.isChoosed = @(![model.isChoosed boolValue]);
}


@end
