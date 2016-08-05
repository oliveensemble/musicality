//
//  ArtistViewController.m
//  Musicality
//
//  Created by Evan Lewis on 11/24/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import StoreKit;

#import "ArtistViewController.h"
#import "MViewControllerDelegate.h"
#import "ArtistFetch.h"
#import "ArtistNavigationBar.h"
#import "ColorScheme.h"
#import "Artist.h"
#import "ArtistList.h"
#import "MStore.h"
#import "AlbumTableViewCell.h"
#import "UIImageView+Haneke.h"
#import "NotificationManager.h"
#import "Blacklist.h"
#import "UserPrefs.h"

@interface ArtistViewController () <SKStoreProductViewControllerDelegate, MViewControllerDelegate, ArtistFetchDelegate>

@property (nonatomic) NSMutableArray *tableViewArray;
@property (nonatomic, weak) ArtistNavigationBar *navigationBar;

@property (nonatomic) SKStoreProductViewController *storeViewController;

@property BOOL isInNotificationList;

@end

@implementation ArtistViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewMovedToForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
  //Tab Bar customization
  UIImage *selectedImage = [[UIImage imageNamed:@"mic_selected_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  self.tabBarItem.selectedImage = selectedImage;
  self.tabBarController.tabBar.barTintColor = [[ColorScheme sharedScheme] primaryColor];
  self.tabBarController.tabBar.tintColor = [[ColorScheme sharedScheme] secondaryColor];
  [self.tableView headerViewForSection:0];
  
  self.view.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
  
  self.navigationController.interactivePopGestureRecognizer.delegate = nil;
  [self.navigationController setNavigationBarHidden:YES animated:NO];
  
  [self.tableView registerNib:[UINib nibWithNibName:@"AlbumTableViewCell" bundle:nil] forCellReuseIdentifier:@"albumCell"];
  _tableViewArray = [NSMutableArray array];
  ArtistFetch *artistFetch = [[ArtistFetch alloc] initWithDelegate:self];
  [artistFetch fetchAlbumsForArtist: self.artist];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  for (Artist *artistNotified in [[ArtistList sharedList] artistSet]) {
    if (artistNotified.artistID == self.artist.artistID) {
      self.isInNotificationList = YES;
    }
  }
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

#pragma mark ArtistFetch Delegate
- (void)didFinishFetchingArtistAlbums:(NSArray *)albums {
  [self.tableView beginUpdates];
  _tableViewArray = [NSMutableArray array];
  [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
  [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
  //Add the items to the table view array
  [self.tableViewArray addObjectsFromArray: albums];
  
  NSMutableArray *indexPaths = [NSMutableArray array];
  //Then add the required number of index paths
  for (int i = 0; i < albums.count; i++) {
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:0];
    [indexPaths addObject:indexpath];
  }
  [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
  [self.tableView endUpdates];
  [self.tableView reloadData];
}

#pragma mark Table View Data

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  
  //Add navigation bar to header
  _navigationBar = [[[NSBundle mainBundle] loadNibNamed:@"ArtistNavigationBar" owner:self options:nil] objectAtIndex:0];
  _navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationBar.frame.size.height);
  _navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.navigationBar.bounds].CGPath;
  _navigationBar.artistLabel.text = self.artist.name;
  [_navigationBar.addToListButton addTarget:self
                                     action:@selector(addToNotificationList)
                           forControlEvents:UIControlEventTouchUpInside];
  [_navigationBar.topOfPageButton addTarget:self
                                     action:@selector(topOfPage)
                           forControlEvents:UIControlEventTouchUpInside];
  [_navigationBar.backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
  
  if (self.isInNotificationList) {
    [self.navigationBar.addToListButton setTitle:@"  Unfollow  " forState:UIControlStateNormal];
  } else {
    [self.navigationBar.addToListButton setTitle:@"  Follow  " forState:UIControlStateNormal];
  }
  return _navigationBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 96;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 150;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.tableViewArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  Album *album = self.tableViewArray[indexPath.row];
  AlbumTableViewCell *albumCell = [tableView dequeueReusableCellWithIdentifier:@"albumCell"];
  albumCell.albumLabel.text = album.title;
  albumCell.artistLabel.text = album.artist;
  if (album.isPreOrder) {
    albumCell.preOrderLabel.hidden = NO;
  } else {
    albumCell.preOrderLabel.hidden = YES;
  }
  [albumCell.albumImageView hnk_setImageFromURL:album.artworkURL placeholder:[mStore imageWithColor:[UIColor clearColor]]];
  albumCell.viewArtistButton.hidden = YES;
  
  //Add gesture recognizer for action sheet
  //Gesture recognizer
  UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showActionSheet:)];
  longPress.minimumPressDuration = 0.5;
  [albumCell addGestureRecognizer:longPress];
  return albumCell;
  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self toiTunes:indexPath];
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  // Remove seperator inset
  if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
    cell.separatorInset = UIEdgeInsetsZero;
  }
  
  // Prevent the cell from inheriting the Table View's margin settings
  if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
    cell.preservesSuperviewLayoutMargins = NO;
  }
  
  // Explictly set your cell's layout margins
  if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
    cell.layoutMargins = UIEdgeInsetsZero;
  }
}

#pragma mark Targets
- (void)showActionSheet:(id)sender {
  
  UILongPressGestureRecognizer *longPress = sender;
  
  if (longPress.state == UIGestureRecognizerStateBegan) {
    AlbumTableViewCell *albumCell = (AlbumTableViewCell*)longPress.view;
    NSString *textToShare = [NSString stringWithFormat:@"%@ - %@", albumCell.cellInfo[@"Artist"], albumCell.cellInfo[@"Album"]];
    NSURL *link = [NSURL URLWithString:[NSString stringWithFormat:@"%@&at=%@", albumCell.cellInfo[@"AlbumURL"], mStore.affiliateToken]];
    NSArray *shareObjects = @[textToShare, link];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:shareObjects applicationActivities:nil];
    NSArray *excludeActivities = @[UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    activityVC.excludedActivityTypes = excludeActivities;
    
    if ([activityVC respondsToSelector:@selector(popoverPresentationController)]) {
      //iOS8 on iPad
      UILongPressGestureRecognizer* lp = sender;
      activityVC.popoverPresentationController.sourceView = lp.view;
    }
    [self presentViewController:activityVC animated:YES completion:nil];
  }
}

- (void)topOfPage {
  [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark NotificationList

- (void)addToNotificationList {
  
  if (!self.isInNotificationList) {
    // If the user clicks Follow
    [[ArtistList sharedList] addArtistToList:self.artist];
    [[Blacklist sharedList] removeArtist:self.artist];
    
    [self.navigationBar.addToListButton setTitle:@"  Unfollow  " forState:UIControlStateNormal];
    self.isInNotificationList = YES;
  } else {
    // If the user clicks Unfollow
    [[ArtistList sharedList] removeArtist:self.artist];
    
    [self.navigationBar.addToListButton setTitle:@"  Follow  " forState:UIControlStateNormal];
    self.isInNotificationList = NO;
    [[UserPrefs sharedPrefs] setArtistListNeedsUpdating:YES];
  }
  
}

#pragma mark Navigation

- (void)back:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)toiTunes:(NSIndexPath *)indexPath {
  // Initialize Product View Controller
  SKStoreProductViewController *storeProductViewController = [[SKStoreProductViewController alloc] init];
  Album *album = self.tableViewArray[indexPath.row];
  
  // Configure View Controller
  storeProductViewController.delegate = self;
  [storeProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : [mStore formattedAlbumIDFromURL:album.URL], SKStoreProductParameterAffiliateToken : mStore.affiliateToken} completionBlock:^(BOOL result, NSError *error) {
    if (error) {
      DLog(@"Error %@ with User Info %@.", error, [error userInfo]);
    } else {
      // Present Store Product View Controller
      [self presentViewController:storeProductViewController animated:YES completion:nil];
    }
  }];
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

@end
