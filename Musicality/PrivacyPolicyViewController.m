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

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  UIColor *textColor = [UIColor blackColor];
  UIColor *backgroundColor = [UIColor whiteColor];
  
  if ([[UserPrefs sharedPrefs] isDarkModeEnabled]) {
    textColor = [UIColor whiteColor];
    backgroundColor = [UIColor blackColor];
  }
  
  self.view.backgroundColor = backgroundColor;
  _titleLabel.textColor = textColor;
  _introText.textColor = textColor;
  _policyText.textColor = textColor;
}

- (IBAction)back:(id)sender {
  [self dismissViewControllerAnimated:YES
                           completion:nil];
}

@end
