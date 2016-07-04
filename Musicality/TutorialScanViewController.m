//
//  TutorialScanViewController.m
//  Musicality
//
//  Created by Evan Lewis on 6/20/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

#import "Button.h"
#import "AutoScan.h"
#import "UserPrefs.h"
#import "ArtistList.h"
#import "Blacklist.h"
#import "TutorialScanViewController.h"

@interface TutorialScanViewController () <UIAlertViewDelegate>

@property (nonatomic) UIAlertView *alertView;

@end

@implementation TutorialScanViewController

- (IBAction)manual:(Button *)sender {
    [[UserPrefs sharedPrefs] setIsAutoUpdateEnabled:NO];
    [self showAlertBodyWithString:@"You music library will not be scanned until you import or add artists to your list. You can change this in the settings"];
}

- (IBAction)autoScan:(Button *)sender {
    [[UserPrefs sharedPrefs] setIsAutoUpdateEnabled:YES];
    [[AutoScan sharedScan] startScan];
    [self showAlertBodyWithString:@"A scan has started. If you exit the app the scan will resume next time you tap on the artists tab"];
}

- (void)showAlertBodyWithString:(NSString*)text {
    if (self.alertView) {
        [_alertView dismissWithClickedButtonIndex:0 animated:NO];
    }
    _alertView = [[UIAlertView alloc] initWithTitle:nil message:text delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    [self.alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notFirstRun"];
        UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *initialViewController = [storyBoard instantiateInitialViewController];
        [self presentViewController:initialViewController animated:YES completion:nil];
    } else if ([[UserPrefs sharedPrefs] isAutoUpdateEnabled]) {
        [[UserPrefs sharedPrefs] setIsAutoUpdateEnabled:NO];
        [[AutoScan sharedScan] stopScan];
        [[ArtistList sharedList] removeAllArtists];
        [[Blacklist sharedList] removeAllArtists];
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[UserPrefs sharedPrefs] savePrefs];
}

@end
