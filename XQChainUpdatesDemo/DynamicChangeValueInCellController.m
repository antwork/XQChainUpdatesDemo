//
//  TableViewController.m
//  XQChainUpdatesDemo
//
//  Created by qxu on 03/12/2016.
//  Copyright © 2016 qxu. All rights reserved.
//

#import "DynamicChangeValueInCellController.h"
#import "XQChainUpdates.h"

@interface CountModel : NSObject

@property (nonatomic, strong) NSNumber *count;

@property (nonatomic, strong) NSNumber *random;

@property (nonatomic, strong) NSTimer *timer;

- (void)plus;

- (void)upRandom;

- (void)doSth;

@end

@implementation CountModel

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
}

- (instancetype)init {
    if (self = [super init]) {
        self.count = @(arc4random() % 10);
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(doSth) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)plus {
    self.count = @([self.count integerValue] + 1);
}

- (void)upRandom {
    self.random = @(arc4random());
}

- (void)doSth {
    [self plus];
    [self upRandom];
}

- (NSNumber *)count {
    if (!_count) {
        _count = @(0);
    }
    return _count;
}

- (NSNumber *)random {
    if (!_random) {
        _random = @(arc4random());
    }
    return _random;
}


@end

@interface DynamicChangeValueInCellController ()

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation DynamicChangeValueInCellController

- (void)dealloc {
    for (CountModel *model in self.items) {
        [model removeChainByPath87:nil];
    }
    NSLog(@"tb dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.items = [NSMutableArray array];
    for (int i = 0; i < 100; i++) {
        CountModel *model = [[CountModel alloc] init];
        [self.items addObject:model];
    }
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    CountModel *model = self.items[indexPath.row];
    
    __weak typeof(model) weakSelf = model;
    __weak typeof(cell) weakCell = cell;
    [model chainPath87:@"count" view:cell.textLabel action:^(NSObject *obj) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        __strong typeof (weakCell) strongCell = weakCell;
        strongCell.textLabel.text = strongSelf.count.stringValue;
    }];
    [model chainPath87:@"random" view:cell.detailTextLabel action:^(NSObject *obj) {
        __strong typeof (weakSelf) strongSelf = weakSelf;
        __strong typeof (weakCell) strongCell = weakCell;
        strongCell.detailTextLabel.text = strongSelf.random.stringValue;
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"+" forState:UIControlStateNormal];
    [btn setFrame:CGRectMake(0, 0, 30, 30)];
    btn.tag = indexPath.row;
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setTitle:@"R" forState:UIControlStateNormal];
    [btn1 setFrame:CGRectMake(30, 0, 30, 30)];
    btn1.tag = indexPath.row;
    [btn1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(random:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [view addSubview:btn];
    [view addSubview:btn1];
    
    cell.accessoryView = view;
    
    return cell;
}

- (void)add:(UIButton *)sender {
    NSInteger tag = sender.tag;
    CountModel *model = [self.items objectAtIndex:tag];
    [model plus];
}

- (void)random:(UIButton *)sender {
    NSInteger tag = sender.tag;
    CountModel *model = [self.items objectAtIndex:tag];
    [model upRandom];
}

@end
