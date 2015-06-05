//
//  ViewController.m
//  ParseSNS
//
//  Created by Master on 2015/06/05.
//  Copyright (c) 2015年 net.masuhara. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>

@end

@implementation ViewController {
    //表示する配列
    IBOutlet UITableView *mainTableView;
    
    //取ってきたデータを入れるための配列
    NSMutableArray *dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 配列の初期化
    if (!dataArray) {
        dataArray = [NSMutableArray new];
    }
    
    mainTableView.dataSource = self;
    mainTableView.delegate = self;
    
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addItem {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"入力" message:@"メモを入力して下さい。" delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"送信", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // Parseとデータをやりとりするために、PFObjectにParseに作成したMemoクラスを格納しておく
        PFObject *object = [PFObject objectWithClassName:@"Memo"];
        
        // PFObjectクラスのtextカラムに、testという文字列を格納
        object[@"text"] = [alertView textFieldAtIndex:0].text;
        
        // Parseに送信して保存。バックグラウンドスレッドで行う。
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                
                return;
            }else {
                [self loadData];
            }
        }];
    }
}

#pragma mark - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [dataArray objectAtIndex:indexPath.row];
    
    return cell;
}


#pragma mark - Private
- (IBAction)refresh {
    [self loadData];
}


- (void)loadData {
    PFQuery *query = [PFQuery queryWithClassName:@"Memo"];
    dataArray = [[[query findObjects] valueForKey:@"text"] mutableCopy];
    [mainTableView reloadData];
}

@end
