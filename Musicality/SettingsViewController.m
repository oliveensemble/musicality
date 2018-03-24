//
//  SettingsViewController.m
//  Musicality
//
//  Created by Evan Lewis on 11/13/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import MessageUI;
@import StoreKit;
@import SafariServices;
#import "MStore.h"
#import "AutoScan.h"
#import "UserPrefs.h"
#import "ArtistList.h"
#import "Blacklist.h"
#import "ColorScheme.h"
#import "MTabBarController.h"
#import "SettingsNavigationBar.h"
#import "SettingsViewController.h"
#import "NotificationManager.h"

@interface SettingsViewController () <MFMailComposeViewControllerDelegate, SKStoreProductViewControllerDelegate, UIAlertViewDelegate, MViewControllerDelegate>

@property (nonatomic, weak) SettingsNavigationBar *navigationBar;

@property (nonatomic) SKStoreProductViewController *storeViewController;

@property BOOL isAutoUpdateEnabled;
@property BOOL isDarkModeEnabled;
@property BOOL isAppleMusicEnabled;

@property (copy, nonatomic) NSString *autoupdateText;
@property (copy, nonatomic) NSString *darkModeText;
@property (copy, nonatomic) NSString *appleMusicText;
@property (nonatomic) NSNumber *alertViewActionID;

@property (nonatomic) UIAlertView *alertView;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *cells;

@end

@implementation SettingsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //Tab Bar customization
    UIImage *selectedImage = [[UIImage imageNamed:@"settings_selected_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.selectedImage = selectedImage;
    self.tabBarController.tabBar.barTintColor = [[ColorScheme sharedScheme] primaryColor];
    self.tabBarController.tabBar.tintColor = [[ColorScheme sharedScheme] secondaryColor];
    [self.tableView headerViewForSection:3];

    self.view.backgroundColor = [[ColorScheme sharedScheme] primaryColor];

    _isAutoUpdateEnabled = [[UserPrefs sharedPrefs] isAutoUpdateEnabled];
    _isDarkModeEnabled = [[UserPrefs sharedPrefs] isDarkModeEnabled];
    _isAppleMusicEnabled = [[UserPrefs sharedPrefs] isAppleMusicEnabled];

    self.autoupdateText = self.isAutoUpdateEnabled ? @"On" : @"Off";
    self.darkModeText = self.isDarkModeEnabled ? @"On" : @"Off";
    self.appleMusicText = self.isAppleMusicEnabled ? @"On" : @"Off";

    [self viewMovedToForeground];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewMovedToForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
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

    if ([[UserPrefs sharedPrefs] isAppleMusicEnabled]) {
        SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://geo.itunes.apple.com/us/album/id%@?app=music&at=1l3vuBC", albumID]]];
        [self presentViewController:safariVC animated:true completion:^{
            [self dismissViewControllerAnimated:true completion:nil];
        }];
    } else {
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
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Alert View

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1) {
        if (buttonIndex == 1) {
            SKStoreProductViewController *storeProductViewController = [[SKStoreProductViewController alloc] init];
            storeProductViewController.delegate = self;
            [storeProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : self.alertViewActionID, SKStoreProductParameterAffiliateToken : mStore.affiliateToken} completionBlock:^(BOOL result, NSError *error) {
                if (error) {
                    DLog(@"Error %@ with User Info %@.", error, [error userInfo]);
                } else {
                    // Present Store Product View Controller
                    [self presentViewController:storeProductViewController animated:YES completion:^{
                        self.alertView = nil;
                    }];
                }
            }];
        }
        self.alertViewActionID = nil;
    } else if (alertView.tag == 2) {
        if (buttonIndex == 1) {
            [[AutoScan sharedScan] stopScan];
            [[ArtistList sharedList] removeAllArtists];
            [[Blacklist sharedList] removeAllArtists];
            [[UserPrefs sharedPrefs] setIsDarkModeEnabled:NO];
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Tutorial" bundle:nil];
            UIViewController *initialViewController = [storyBoard instantiateInitialViewController];
            [self presentViewController:initialViewController animated:YES completion:nil];
        }
    }
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //Add navigation bar to header
    _navigationBar = [[[NSBundle mainBundle] loadNibNamed:@"SettingsNavigationBar" owner:self options:nil] objectAtIndex:0];
    _navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, _navigationBar.frame.size.height);
    _navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:_navigationBar.bounds].CGPath;
    return _navigationBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 95;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row == 1) {
        cell.detailTextLabel.text = self.autoupdateText;
    } else if (indexPath.row == 2) {
        cell.detailTextLabel.text = self.darkModeText;
    } else if (indexPath.row == 6) {
        cell.detailTextLabel.text = self.appleMusicText;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/musicality-never-miss-a-beat/id945094708?ls=1&mt=8"]];
            break;
        }
        case 1: {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (self.isAutoUpdateEnabled) {
                self.isAutoUpdateEnabled = NO;
                [[UserPrefs sharedPrefs] setIsAutoUpdateEnabled:NO];
                cell.detailTextLabel.text = @"Off";
                DLog(@"Auto update off");
                if ([[AutoScan sharedScan] isScanning]) {
                    [[AutoScan sharedScan] stopScan];
                }
            } else {
                self.isAutoUpdateEnabled = YES;
                [[UserPrefs sharedPrefs] setIsAutoUpdateEnabled:YES];
                cell.detailTextLabel.text = @"On";
                DLog(@"Auto update on");
                if (![[AutoScan sharedScan] isScanning]) {
                    [[AutoScan sharedScan] startScan];
                }
            }
            [[UserPrefs sharedPrefs] setArtistListNeedsUpdating:YES];
            break;
        }
        case 2: {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (self.isDarkModeEnabled) {
                self.isDarkModeEnabled = NO;
                [[UserPrefs sharedPrefs] setIsDarkModeEnabled:NO];
                cell.detailTextLabel.text = @"Off";
                self.darkModeText = @"Off";
                DLog(@"Dark mode off");
            } else {
                self.isDarkModeEnabled = YES;
                [[UserPrefs sharedPrefs] setIsDarkModeEnabled:YES];
                cell.detailTextLabel.text = @"On";
                self.darkModeText = @"On";
                DLog(@"Dark mode on");
            }
            [self toggleDarkMode];
            break;
        }
        case 3: {
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
                mail.mailComposeDelegate = self;
                [mail setSubject:@"Musicality Help/Feedback"];
                [mail setToRecipients:@[@"evanlwsapps+musicalityhelp@gmail.com"]];

                [self presentViewController:mail animated:YES completion:NULL];
            } else {
                DLog(@"This device cannot send email");
            }
            break;
        }
        case 5: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear all data" message:@"Are you sure? You can turn 'Scan Library Automatically' on to restart library search" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Clear", nil];
            alert.tag = 2;
            [alert show];
            break;
        }
        case 6: {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            if (self.isAppleMusicEnabled) {
                self.isAppleMusicEnabled = NO;
                [[UserPrefs sharedPrefs] setIsAppleMusicEnabled:NO];
                cell.detailTextLabel.text = @"Off";
                self.appleMusicText = @"Off";
                DLog(@"Apple music off");
            } else {
                self.isAppleMusicEnabled = YES;
                [[UserPrefs sharedPrefs] setIsAppleMusicEnabled:YES];
                cell.detailTextLabel.text = @"On";
                self.appleMusicText = @"On";
                DLog(@"Apple music on");
            }
            break;
        }
        default:
            break;
    }

    [[UserPrefs sharedPrefs] savePrefs];
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)toggleDarkMode {
    if (self.isDarkModeEnabled) {
        self.view.backgroundColor = [UIColor blackColor];
        //Tab Bar customization
        self.tabBarController.tabBar.barTintColor = [UIColor blackColor];
        self.tabBarController.tabBar.tintColor = [UIColor blackColor];
        self.navigationBar.backgroundColor = [UIColor blackColor];
        self.navigationBar.settingsLabel.textColor = [UIColor whiteColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
        self.tabBarController.tabBar.barTintColor = [UIColor whiteColor];
        self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
        self.navigationBar.backgroundColor = [UIColor whiteColor];
        self.navigationBar.settingsLabel.textColor = [UIColor blackColor];
    }
    [self.tableView reloadData];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UserPrefs sharedPrefs] savePrefs];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

@end
