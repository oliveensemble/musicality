//
//  PrivacyPolicyViewController.m
//  Musicality
//
//  Created by Evan Lewis on 6/22/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

#import "MStore.h"
#import "Button.h"
#import "UserPrefs.h"
#import "PrivacyPolicyViewController.h"

@interface PrivacyPolicyViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *introText;
@property (weak, nonatomic) IBOutlet UITextView *policyText;

@end

@implementation PrivacyPolicyViewController

- (IBAction)back:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureView];
}

- (void)configureView {
    if ([[UserPrefs sharedPrefs] isDarkModeEnabled]) {
        self.view.backgroundColor = [UIColor blackColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
}

@end
