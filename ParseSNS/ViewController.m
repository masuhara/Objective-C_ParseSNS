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

- (IBAction)addItem {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"入力" message:@"メモを入力して下さい。" delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"送信", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

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
    [SVProgressHUD showWithStatus:@"ロード中"];
    PFQuery *query = [PFQuery queryWithClassName:@"Memo"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            dataArray = [[objects valueForKey:@"text"] mutableCopy];
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

/*
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^ {
        self.view.center = CGPointMake(self.view.center.x, self.view.center.y - 150);
        
    }completion:^(BOOL finished) {
        
    }];

}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^ {
        self.view.center = CGPointMake(self.view.center.x, self.view.center.y + 150);
    } completion:^(BOOL finished) {
        
    }];
}
 */







@end
