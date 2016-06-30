//
//  TutorialInfoViewController.m
//  Musicality
//
//  Created by Evan Lewis on 6/20/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

#import "Button.h"
#import "TutorialInfoViewController.h"

@interface TutorialInfoViewController ()

@end

@implementation TutorialInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toScan:(Button *)sender {
    [self performSegueWithIdentifier:@"toScan" sender:sender];
}

@end
