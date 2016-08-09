//
//  PrivacyPolicyViewController.m
//  Musicality
//
//  Created by Evan Lewis on 6/22/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

@import StoreKit;
#import "MStore.h"
#import "Button.h"
#import "UserPrefs.h"
#import "ColorScheme.h"
#import "PrivacyPolicyViewController.h"
#import "MViewControllerDelegate.h"
#import "NotificationManager.h"

@interface PrivacyPolicyViewController () <MViewControllerDelegate, SKStoreProductViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *introText;
@property (weak, nonatomic) IBOutlet UITextView *policyText;

@property (nonatomic) SKStoreProductViewController *storeViewController;

@end

@implementation PrivacyPolicyViewController

- (IBAction)back:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewMovedToForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.view.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
  self.introText.textColor = [[ColorScheme sharedScheme] secondaryColor];
  self.titleLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
  self.policyText.textColor = [[ColorScheme sharedScheme] secondaryColor];
  [self viewMovedToForeground];
}

#pragma mark - MViewController Delegate
- (void)viewMovedToForeground {
  if (self.storeViewController) {
    [self.storeViewController dismissViewControllerAnimated:NO completion:nil];
  }
  
  [self checkForNotification: [[NotificationManager sharedManager] localNotification]];
}

- (void)checkForNotification:(UILocalNotification *)localNotification {
  if (localNotification) {
    DLog(@"Local Notification: %@", [[NotificationManager sharedManager] localNotification]);
    // Remove the local notification when we're finished with it so it doesn't get reused
    [[NotificationManager sharedManager] setLocalNotification:nil];
    [self loadStoreProductViewController:localNotification.userInfo];
  }
}

- (void)loadStoreProductViewController:(NSDictionary *)userInfo {
  NSNumber *albumID = userInfo[@"albumID"];
  if (!albumID) {
    return;
  }
  
  // Initialize Product View Controller
  if ([SKStoreProductViewController class] != nil) {
    // Configure View Controller
    _storeViewController = [[SKStoreProductViewController alloc] init];
    [self.storeViewController setDelegate:self];
    NSDictionary *productParams = @{SKStoreProductParameterITunesItemIdentifier : albumID, SKStoreProductParameterAffiliateToken : mStore.affiliateToken};
    [self.storeViewController loadProductWithParameters:productParams completionBlock:^(BOOL result, NSError *error) {
      if (error) {
        // handle the error
        NSLog(@"%@",error.description);
      }
      [self presentViewController:self.storeViewController animated:YES completion:nil];
    }];
  }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

@end
