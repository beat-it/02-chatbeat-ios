//
//  ConnectViewController.m
//  beatit2
//
//  Created by Dusan Beblavy on 02/05/2017.
//  Copyright © 2017 Dusan Beblavy. All rights reserved.
//

#import "ConnectViewController.h"
#import <SendBirdSDK/SendBirdSDK.h>
#import "AppDelegate.h"

@interface ConnectViewController ()

@end

@implementation ConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"Connect"]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        appDelegate.senderId = self.nameEmail.text;
        appDelegate.senderName = self.nameAlias.text;
        
        [SBDMain connectWithUserId:self.nameEmail.text completionHandler:^(SBDUser * _Nullable user, SBDError * _Nullable error) {
            NSLog(@"connected");
            [SBDMain updateCurrentUserInfoWithNickname:self.nameAlias.text profileUrl:nil completionHandler:^(SBDError * _Nullable error) {
                NSLog(@"Profile updated");
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"updateOpenChannels"
                 object:self];
            }];
        }];
    }
}


@end
