//
//  ViewController.m
//  ParseSNS
//
//  Created by Master on 2015/06/05.
//  Copyright (c) 2015年 net.masuhara. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import "SVProgressHUD.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UITextFieldDelegate>

@end

@implementation ViewController {
    IBOutlet UITableView *mainTableView;
    NSMutableArray *dataArray;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
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
    cell.textLabel.text = [[dataArray valueForKey:@"text"] objectAtIndex:indexPath.row];
    return cell;
}

#pragma mark - TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [SVProgressHUD showWithStatus:@"削除中..." maskType:SVProgressHUDMaskTypeBlack];
        PFObject *object = dataArray[indexPath.row];
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [SVProgressHUD dismiss];
                [SVProgressHUD showSuccessWithStatus:@"削除成功!"];
                [dataArray removeObjectAtIndex:indexPath.row];
                [mainTableView reloadData];
            }else {
                [SVProgressHUD dismiss];
                [self showErrorAlert:error];
            }
        }];
    }
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        PFObject *object = [PFObject objectWithClassName:@"Memo"];
        object[@"text"] = [alertView textFieldAtIndex:0].text;
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                [self loadData];
                if (succeeded) {
                    [SVProgressHUD showSuccessWithStatus:@"送信成功!"];
                }
            }else {
                [self showErrorAlert:error];
            }
        }];
    }
}


#pragma mark - Private
- (IBAction)addItem {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"入力" message:@"メモを入力して下さい。" delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"送信", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

- (IBAction)refresh {
    [self loadData];
}

- (void)loadData {
    [SVProgressHUD showWithStatus:@"ロード中"];
    PFQuery *query = [PFQuery queryWithClassName:@"Memo"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            dataArray = [objects mutableCopy];
            [mainTableView reloadData];
        }else {
            [self showErrorAlert:error];
        }
        [SVProgressHUD dismiss];
    }];
}

- (void)showErrorAlert:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"エラー" message:@"通信エラーが発生しました" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}


@end
