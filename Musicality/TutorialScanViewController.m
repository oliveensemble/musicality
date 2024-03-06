//
//  TutorialScanViewController.m
//  Musicality
//
//  Created by Elle Lewis on 7/30/16.
//  Copyright © 2016 Elle Lewis. All rights reserved.
//

#import "TutorialScanViewController.h"
#import "Button.h"
#import "UserPrefs.h"
#import "AutoScan.h"

@interface TutorialScanViewController ()

@end

@implementation TutorialScanViewController

#pragma mark - Targets

- (IBAction)manualScanButtonTapped:(Button *)sender {
  [self performSegueWithIdentifier:@"toPopularArtists" sender:self];
}

- (IBAction)autoScanButtonTapped:(Button *)sender {
  [[UserPrefs sharedPrefs] setIsAutoUpdateEnabled:YES];
  [[AutoScan sharedScan] startScan];
  [self loadMainStoryboard];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"toPopularArtists"]) {
    [[UserPrefs sharedPrefs] setIsAutoUpdateEnabled:NO];
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [[UserPrefs sharedPrefs] savePrefs];
}

- (void)loadMainStoryboard {
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notFirstRun"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  UIViewController *initialViewController = [storyBoard instantiateInitialViewController];
  [self presentViewController:initialViewController animated:YES completion:nil];
}

@end
