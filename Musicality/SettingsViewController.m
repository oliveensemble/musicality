//
//  SettingsViewController.m
//  Musicality
//
//  Created by Evan Lewis on 11/13/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import MessageUI;
@import StoreKit;

#import "MStore.h"
#import "AutoScan.h"
#import "UserPrefs.h"
#import "ArtistList.h"
#import "Blacklist.h"
#import "SettingsNavigationBar.h"
#import "SettingsViewController.h"

@interface SettingsViewController () <MFMailComposeViewControllerDelegate, SKStoreProductViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) SettingsNavigationBar *navigationBar;

@property BOOL isDarkModeEnabled;
@property BOOL isAutoUpdateEnabled;

@property (nonatomic) UIColor *bwTextColor;
@property (nonatomic) UIColor *bwBackgroundColor;
@property (nonatomic) NSString *nightModeText;
@property (nonatomic) NSString *autoupdateText;
@property (nonatomic) NSNumber *alertViewActionID;

@property (nonatomic) UIAlertView *alertView;

@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *cells;

@end

@implementation SettingsViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  _isDarkModeEnabled = [[UserPrefs sharedPrefs] isDarkModeEnabled];
  _isAutoUpdateEnabled = [[UserPrefs sharedPrefs] isAutoUpdateEnabled];
  
  //dark mode customization
  if (self.isDarkModeEnabled) {
    self.view.backgroundColor = [UIColor blackColor];
    _bwTextColor = [UIColor whiteColor];
    _bwBackgroundColor = [UIColor blackColor];
    self.nightModeText = @"On";
  } else {
    self.view.backgroundColor = [UIColor whiteColor];
    _bwTextColor = [UIColor blackColor];
    _bwBackgroundColor = [UIColor whiteColor];
    self.nightModeText = @"Off";
  }
  
  if (self.isAutoUpdateEnabled) {
    self.autoupdateText = @"On";
  } else {
    self.autoupdateText = @"Off";
  }
  
  //Tab Bar customization
  self.tabBarController.tabBar.barTintColor = self.bwBackgroundColor;
  self.tabBarController.tabBar.tintColor = self.bwTextColor;
  
  UITableViewCell *eveningCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
  eveningCell.detailTextLabel.text = self.nightModeText;
  
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Uncomment the following line to preserve selection between presentations.
  self.clearsSelectionOnViewWillAppear = NO;
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"appDidReceiveNotification" object:nil];
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark Alert View

- (void)didReceiveNotification:(NSNotification*)notif {
  NSDictionary *notificationOptions = notif.userInfo;
  NSNumber *num = [notificationOptions objectForKey:@"albumID"];
  NSString *artistName = [notificationOptions objectForKey:@"artistName"];
  if (num && artistName && !self.alertView) {
    _alertView = [[UIAlertView alloc] initWithTitle:@"Check it out!" message:[NSString stringWithFormat:@"New release by %@", artistName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"View", nil];
    self.alertViewActionID = num;
    self.alertView.tag = 1;
    [self.alertView show];
  }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
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
      [[ArtistList sharedList] removeAllArtists];
      [[Blacklist sharedList] removeAllArtists];
      [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
  }
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  //Add navigation bar to header
  _navigationBar = [[[NSBundle mainBundle] loadNibNamed:@"SettingsNavigationBar" owner:self options:nil] objectAtIndex:0];
  _navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, _navigationBar.frame.size.height);
  _navigationBar.backgroundColor = self.bwBackgroundColor;
  _navigationBar.layer.shadowColor = [self.bwTextColor CGColor];
  _navigationBar.layer.shadowOpacity = 0.4;
  _navigationBar.layer.shadowRadius = 2.0;
  _navigationBar.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
  _navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:_navigationBar.bounds].CGPath;
  UILabel *settingsLabel = (UILabel*)[self.navigationBar viewWithTag:1];
  settingsLabel.textColor = self.bwTextColor;
  return _navigationBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 72;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  
  cell.backgroundColor = self.bwBackgroundColor;
  cell.textLabel.textColor = self.bwTextColor;
  cell.detailTextLabel.textColor = self.bwTextColor;
  if (indexPath.row == 1) {
    cell.detailTextLabel.text = self.autoupdateText;
  }
  if (indexPath.row == 2) {
    cell.detailTextLabel.text = self.nightModeText;
  }
  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.row) {
    case 0: {
      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/musicality-never-miss-a-beat/id945094708?ls=1&mt=8"]];
    }
      break;
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
      DLog(@"Dark mode toggled");
      [self toggleDarkMode];
    }
      break;
    case 3: {
      if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"Musicality Help/Feedback"];
        [mail setToRecipients:@[@"musicality.help@gmail.com"]];
        
        [self presentViewController:mail animated:YES completion:NULL];
      } else {
        DLog(@"This device cannot send email");
      }
    }
      break;
    case 5: {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear all data" message:@"Are you sure? You can turn 'Scan Library Automatically' on to restart library search" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Clear", nil];
      alert.tag = 2;
      [alert show];
    }
    default:
      break;
  }
  [[UserPrefs sharedPrefs] savePrefs];
  [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)toggleDarkMode {
  
  if (self.isDarkModeEnabled) {
    //Turn it off
    _isDarkModeEnabled = NO;
    _bwTextColor = [UIColor blackColor];
    _bwBackgroundColor = [UIColor whiteColor];
    [[self.cells[2] detailTextLabel] setText:@"Off"];
  } else {
    //Turn it on
    _isDarkModeEnabled = YES;
    _bwTextColor = [UIColor whiteColor];
    _bwBackgroundColor = [UIColor blackColor];
    [[self.cells[2] detailTextLabel] setText:@"On"];
  }
  
    self.view.backgroundColor = self.bwBackgroundColor;
  for (UITableViewCell *cell in self.cells) {
    cell.backgroundColor = self.bwBackgroundColor;
    cell.textLabel.textColor = self.bwTextColor;
    cell.detailTextLabel.textColor = self.bwTextColor;
    [cell setSelected:NO animated:NO];
  }
  
  self.navigationBar.backgroundColor = self.bwBackgroundColor;
  self.navigationBar.layer.shadowColor = [self.bwBackgroundColor CGColor];
  UILabel *settingsLabel = (UILabel*)[self.navigationBar viewWithTag:1];
  settingsLabel.textColor = self.bwTextColor;
  
  //Tab Bar customization
  self.tabBarController.tabBar.barTintColor = self.bwBackgroundColor;
  self.tabBarController.tabBar.tintColor = self.bwBackgroundColor;
  
  [[UserPrefs sharedPrefs] setIsDarkModeEnabled:self.isDarkModeEnabled];
  [[UserPrefs sharedPrefs] savePrefs];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"darkModeToggled" object:self];

}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
  [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[UserPrefs sharedPrefs] savePrefs];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"appDidReceiveNotification" object:nil];
}

@end
