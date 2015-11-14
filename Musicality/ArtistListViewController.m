//
//  ArtistListViewController.m
//  Musicality
//
//  Created by Evan Lewis on 11/12/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//
@import StoreKit;

#import "ArtistListViewController.h"
#import "ArtistsNavigationBar.h"
#import "ArtistViewController.h"
#import "UIImageView+Haneke.h"
#import "NotificationList.h"
#import "AlbumTableViewCell.h"
#import "LoadingView.h"
#import "UserPrefs.h"
#import "ArtistList.h"
#import "Blacklist.h"
#import "AutoScan.h"
#import "MStore.h"

@interface ArtistListViewController () <SKStoreProductViewControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) ArtistsNavigationBar *navigationBar;

@property (nonatomic) NSMutableArray *tableViewArray;
@property (nonatomic, copy) NSArray *filterArray;

@property (nonatomic) UIColor *bwTextColor;
@property (nonatomic) UIColor *bwBackgroundColor;

@property (nonatomic) NSString *currentFilterTitle;

@property (nonatomic) Artist *actionArtist;
@property (nonatomic) Album *actionAlbum;

@property BOOL isUpdating;
@property BOOL isFilterSelected;

@property (nonatomic) LoadingView *loadingView;
@property (nonatomic) NSNumber *alertViewActionID;

@property (nonatomic) UIAlertView *alertView;

@end

@implementation ArtistListViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.isUpdating = NO;
  
  if(![self needsUpdates]) {
    [self populate];
  }
  
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  //Tab Bar customization
  UIImage *selectedImage = [[UIImage imageNamed:@"mic_selected_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  self.tabBarItem.selectedImage = selectedImage;
  self.tabBarController.tabBar.barTintColor = [UIColor whiteColor];
  self.tabBarController.tabBar.tintColor = [UIColor blackColor];
  
  self.isUpdating = NO;
  self.navigationController.navigationBarHidden = YES;
  self.navigationController.interactivePopGestureRecognizer.delegate = nil;
  
  _tableViewArray = [NSMutableArray array];
  _filterArray = @[@"Latest Releases", @"Artists", @"Hide Pre-Orders"];
  self.currentFilterTitle = self.filterArray.firstObject;
  
  [self.tableView registerNib:[UINib nibWithNibName:@"AlbumTableViewCell" bundle:nil] forCellReuseIdentifier:@"albumCell"];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(forceUpdate) name:@"autoScanDone" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAutoScanStatus:) name:@"autoScanUpdate" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"appDidReceiveNotification" object:nil];
  
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if ([[AutoScan sharedScan] isScanning]) {
    [self beginLoading];
    self.loadingView.viewLabel.text = @"Library scan in progress";
  }
}

#pragma mark Updating

- (BOOL)needsUpdates {
  
  if (![[NSUserDefaults standardUserDefaults] boolForKey:@"AutoScan Finished"]) {
    [[AutoScan sharedScan] startScan];
    return YES;
  }
  
  if ([[ArtistList sharedList] artistSet].count == 0) {
    [self.tableViewArray removeAllObjects];
    [self.tableView reloadData];
    if ([[UserPrefs sharedPrefs] isAutoUpdateEnabled]) {
      [[AutoScan sharedScan] startScan];
    }
    return YES;
  }
  
  if (!self.isUpdating && ![[AutoScan sharedScan] isScanning]) {
    if ([[UserPrefs sharedPrefs] isAutoUpdateEnabled] && [mStore thisDate:[NSDate dateWithTimeIntervalSinceNow:-86400] isMoreRecentThan:[NSDate date]]) {
      [[AutoScan sharedScan] startScan];
    }
    if ([[UserPrefs sharedPrefs] artistListNeedsUpdating]) {
      [[UserPrefs sharedPrefs] setArtistListNeedsUpdating:YES];
      [self updateList];
      return YES;
    } else if ([mStore thisDate:[NSDate dateWithTimeIntervalSinceNow:-86400] isMoreRecentThan:[mStore lastLibraryScanDate]]) {
      [mStore setLastLibraryScanDate:[NSDate date]];
      [self updateList];
      return YES;
    }
  }
  
  if (self.tableViewArray.count == 0 && [[UserPrefs sharedPrefs] isAutoUpdateEnabled] && ![[AutoScan sharedScan] isScanning]) {
    [[AutoScan sharedScan] startScan];
  }
  
  return NO;
}

- (void)updateList {
  DLog(@"Checking library");
  self.isUpdating = YES;
  [self beginLoading];
  NSMutableOrderedSet *artistsSet = [[ArtistList sharedList] artistSet];
  
  if (artistsSet.count == 0) {
    DLog(@"No artists to check");
    self.isUpdating = NO;
    [self endLoading];
    return;
  }
  
  BOOL needsUpdates = false;
  for (Artist* artist in [[ArtistList sharedList] artistSet]) {
    if ([mStore thisDate:[NSDate dateWithTimeIntervalSinceNow:-604800] isMoreRecentThan:artist.lastCheckDate]) {
      LatestReleaseSearch *albumSearch = [[LatestReleaseSearch alloc] initWithArtist:artist delegate:self];
      [self.pendingOperations.requestsInProgress setObject:albumSearch forKey:[NSString stringWithFormat:@"Album Search for %@", artist.name]];
      [self.pendingOperations.requestQueue addOperation:albumSearch];
      needsUpdates = YES;
    }
  }
  
  if (!needsUpdates) {
    self.isUpdating = NO;
    DLog(@"Done checking");
    [self endLoading];
    [self populate];
  }
}

- (void)forceUpdate {
  if (!self.isUpdating && ![[AutoScan sharedScan] isScanning] && ([[ArtistList sharedList] artistSet].count > 0)) {
    self.isUpdating = YES;
    [self beginLoading];
    for (Artist* artist in [[ArtistList sharedList] artistSet]) {
      LatestReleaseSearch *albumSearch = [[LatestReleaseSearch alloc] initWithArtist:artist delegate:self];
      [self.pendingOperations.requestsInProgress setObject:albumSearch forKey:[NSString stringWithFormat:@"Album Search for %@", artist.name]];
      [self.pendingOperations.requestQueue addOperation:albumSearch];
    }
  }
}

- (void)populate {
  [self.tableViewArray removeAllObjects];
  [self.tableViewArray addObject:self.currentFilterTitle];
  [self.tableViewArray addObjectsFromArray:[self sortedAlbums]];
  [self.tableView reloadData];
}

#pragma mark Alert View

- (void)didReceiveNotification:(NSNotification*)notif {
  NSDictionary *notificationOptions = notif.userInfo;
  NSNumber *num = [notificationOptions objectForKey:@"albumID"];
  NSString *artistName = [notificationOptions objectForKey:@"artistName"];
  if (num && artistName && !self.alertView) {
    _alertView = [[UIAlertView alloc] initWithTitle:@"Check it out!" message:[NSString stringWithFormat:@"New release by %@", artistName] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"View", nil];
    self.alertViewActionID = num;
    [self.alertView show];
  }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == 1) {
    SKStoreProductViewController *storeProductViewController = [[SKStoreProductViewController alloc] init];
    storeProductViewController.delegate = self;
    [storeProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier :self.alertViewActionID, SKStoreProductParameterAffiliateToken : mStore.affiliateToken} completionBlock:^(BOOL result, NSError *error) {
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
}

- (NSMutableArray *)sortedAlbums {
  //Sort albums after checking, before they are to be displayed
  NSMutableArray *albumsArray = [NSMutableArray array];
  for (Artist *artist in [[ArtistList sharedList] artistSet]) {
    if (artist.latestRelease) {
      artist.latestRelease.userData = artist.artistID;
      [albumsArray addObject:artist.latestRelease];
    }
  }
  
  if ([self.currentFilterTitle isEqualToString:self.filterArray[0]]) {
    return [[[[albumsArray sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects] mutableCopy];
  } else if ([self.currentFilterTitle isEqualToString:self.filterArray[1]]) {
    return albumsArray;
  } else if ([self.currentFilterTitle isEqualToString:self.filterArray[2]]) {
    NSMutableArray *albums = [NSMutableArray array];
    for (Album *album in albumsArray) {
      if (!album.isPreOrder) {
        [albums addObject:album];
      }
    }
    return [[[[albums sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects] mutableCopy];
  }
  return nil;
}

- (void)toggleFilterSelection {
  [self.tableView beginUpdates];
  
  NSMutableArray *indexPaths = [NSMutableArray array];
  //Adds the required number of index paths
  for (int i = 0; i < self.filterArray.count; i++) {
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:0];
    [indexPaths addObject:indexpath];
  }
  
  if (!self.isFilterSelected) {
    [self.tableViewArray removeObjectAtIndex:0];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    //Open filter selection view
    self.isFilterSelected = YES;
    for (int i = 0; i < self.filterArray.count; i++) {
      [self.tableViewArray insertObject:self.filterArray[i] atIndex:i];
    }
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    [self.tableView reloadData];
  } else {
    //Close filter selection view
    self.isFilterSelected = NO;
    [self.tableViewArray removeObjectsInArray:self.filterArray];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    [self populate];
  }
}

#pragma mark NSOperation Delegate

- (PendingOperations *)pendingOperations {
  if (!_pendingOperations) {
    _pendingOperations = [[PendingOperations alloc] init];
  }
  return _pendingOperations;
}

- (void)latestReleaseSearchDidFinish:(LatestReleaseSearch *)downloader {
  [[ArtistList sharedList] updateLatestRelease:downloader.album forArtist:downloader.artist];
  [self.pendingOperations.requestsInProgress removeObjectForKey:[NSString stringWithFormat:@"Album Search for %@", downloader.artist.name]];
  self.loadingView.viewLabel.text = [NSString stringWithFormat:@"Updating %@", downloader.artist.name];
  if (self.pendingOperations.requestsInProgress.count == 0) {
    [self endLoading];
    [self populate];
    if (self.isUpdating) {
      mStore.lastLibraryScanDate = [NSDate date];
      [[Blacklist sharedList] saveChanges];
      [[NotificationList sharedList] determineNotificationItems];
      [self populate];
    }
    self.isUpdating = NO;
  }
}

- (void)updateAutoScanStatus:(NSNotification*)notification {
  if ([notification.name isEqualToString:@"autoScanUpdate"]) {
    NSDictionary *userInfo = notification.userInfo;
    NSString *artistName = userInfo[@"artistName"];
    [self beginLoading];
    self.loadingView.viewLabel.text = [NSString stringWithFormat:@"Checking %@", artistName];
  }
}

#pragma mark Table View Delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  //Add navigation bar to header
  _navigationBar = [[[NSBundle mainBundle] loadNibNamed:@"ArtistsNavigationBar" owner:self options:nil] objectAtIndex:0];
  _navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, _navigationBar.frame.size.height);
  _navigationBar.layer.shadowColor = [self.bwTextColor CGColor];
  _navigationBar.layer.backgroundColor = [self.bwBackgroundColor CGColor];
  _navigationBar.layer.shadowOpacity = 0.4;
  _navigationBar.layer.shadowRadius = 2.0;
  _navigationBar.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
  _navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:_navigationBar.bounds].CGPath;
  
  self.navigationBar.artistsLabel.textColor = self.bwTextColor;
  
  UIButton *topOfPageButton = (UIButton*)[self.navigationBar viewWithTag:3];
  [topOfPageButton addTarget:self
                      action:@selector(topOfPage)
            forControlEvents:UIControlEventTouchUpInside];
  
  //Add target for importbutton
  Button *importArtistsButton = (Button*)[self.navigationBar viewWithTag:1];
  [importArtistsButton addTarget:self
                          action:@selector(toLibraryList:)
                forControlEvents:UIControlEventTouchUpInside];
  
  Button *refreshButton = (Button*)[self.navigationBar viewWithTag:4];
  [refreshButton addTarget:self action:@selector(forceUpdate) forControlEvents:UIControlEventTouchUpInside];
  
  return _navigationBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 110;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (self.isFilterSelected) {
    if (indexPath.row < self.filterArray.count) {
      return 50;
    } else {
      return 195;
    }
  } else {
    if (indexPath.row == 0) {
      return 50;
    } else {
      return 195;
    }
  }
  return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // Return the number of rows in the section.
  return self.tableViewArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0 || (self.isFilterSelected && indexPath.row < self.filterArray.count)) {
    UITableViewCell *filterCell = [self.tableView dequeueReusableCellWithIdentifier:@"FilterCell" forIndexPath:indexPath];
    UILabel *filterLabel = (UILabel*)[filterCell.contentView viewWithTag:1];
    filterLabel.textColor = self.bwTextColor;
    filterCell.contentView.backgroundColor = self.bwBackgroundColor;
    filterLabel.text = [NSString stringWithFormat:@"%@", self.tableViewArray[indexPath.row]];
    return filterCell;
  } else if ((self.isFilterSelected && indexPath.row >= self.filterArray.count) || !self.isFilterSelected) {
    Album *album = self.tableViewArray[indexPath.row];
    AlbumTableViewCell *albumCell = [self.tableView dequeueReusableCellWithIdentifier:@"albumCell"];
    albumCell.albumLabel.text = album.title;
    albumCell.artistLabel.text = album.artist;
    //Load image in the background
    [albumCell.albumImageView hnk_setImageFromURL:album.artworkURL placeholder:[mStore imageWithColor:[UIColor clearColor]]];
    
    //Gesture recognizer
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showActionSheet:)];
    longPress.minimumPressDuration = 0.5;
    [albumCell addGestureRecognizer:longPress];
    return albumCell;
  }
  return nil;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (self.isFilterSelected) {
    if (indexPath.row < self.filterArray.count) {
      [self toggleFilterSelection];
      if (![self.currentFilterTitle isEqualToString:self.filterArray[indexPath.row]]) {
        self.currentFilterTitle = self.filterArray[indexPath.row];
        [self populate];
      }
    } else {
      [self toiTunes:indexPath];
    }
  } else {
    if (indexPath.row == 0) {
      [self toggleFilterSelection];
    } else {
      [self toiTunes:indexPath];
    }
  }
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Navigation

- (void)toiTunes:(NSIndexPath *)indexPath {
  // Initialize Product View Controller
  SKStoreProductViewController *storeProductViewController = [[SKStoreProductViewController alloc] init];
  Album *album = self.tableViewArray[indexPath.row];
  [self beginLoading];
  self.loadingView.viewLabel.text = [NSString stringWithFormat:@"Loading %@", album.title];
  // Configure View Controller
  storeProductViewController.delegate = self;
  [storeProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : [mStore formattedAlbumIDFromURL:album.URL], SKStoreProductParameterAffiliateToken : mStore.affiliateToken} completionBlock:^(BOOL result, NSError *error) {
    if (error) {
      DLog(@"Error %@ with User Info %@.", error, [error userInfo]);
    } else {
      // Present Store Product View Controller
      [self presentViewController:storeProductViewController animated:YES completion:nil];
    }
    [self endLoading];
  }];
}

- (void)toArtist:(Button*)sender {
  //Artist *artist = [[Artist alloc] initWithArtistID:sender.userData andName:sender.userData2];
  //[self performSegueWithIdentifier:@"toArtist" sender:artist];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
  if ([segue.identifier isEqualToString:@"toArtist"]) {
    ArtistViewController *artistViewController = segue.destinationViewController;
    artistViewController.artist = sender;
  }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)toLibraryList:(id)sender {
  [self performSegueWithIdentifier:@"toLibraryList" sender:self];
}

- (void)showActionSheet:(id)sender {
  UILongPressGestureRecognizer *longPress = sender;
  if (longPress.state == UIGestureRecognizerStateBegan) {
    UITableViewCell *cell = (UITableViewCell*)longPress.view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    DLog(@"Index path row for action: %ld", (long)indexPath.row);
    self.actionAlbum = self.tableViewArray[indexPath.row];
    self.actionAlbum.userData = indexPath;
    self.actionArtist = [[ArtistList sharedList] getArtist:[self.actionAlbum artist]];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Hide Artist" otherButtonTitles: @"Share", nil];
    [actionSheet showInView:self.view];
  }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
  if (buttonIndex == 1) {
    Album *album = self.actionAlbum;
    NSData *imageData = [NSData dataWithContentsOfURL:album.artworkURL];
    UIImage *image = [UIImage imageWithData:imageData];
    NSString *textToShare = [NSString stringWithFormat:@"%@ - %@", album.artist, album.title];
    NSURL *link = [NSURL URLWithString:[NSString stringWithFormat:@"%@&at=%@", album.URL, mStore.affiliateToken]];
    NSArray *shareObjects = @[textToShare, image, link];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:shareObjects applicationActivities:nil];
    NSArray *excludeActivities = @[UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    activityVC.excludedActivityTypes = excludeActivities;
    [self presentViewController:activityVC animated:YES completion:nil];
  } else if (buttonIndex == 0) {
    DLog(@"Hiding artist");
    NSIndexPath *indexPath = self.actionAlbum.userData;
    [self.tableViewArray removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [[Blacklist sharedList] addArtistToList:self.actionArtist];
  }
  self.actionArtist = nil;
  self.actionAlbum = nil;
}

- (void)topOfPage {
  [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
  [self updateList];
}

#pragma mark Loading

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  CGRect frame = self.loadingView.frame;
  frame.origin.y = scrollView.contentOffset.y + self.tableView.frame.size.height - self.loadingView.frame.size.height;
  self.loadingView.frame = frame;
  
  [self.view bringSubviewToFront:self.loadingView];
}

- (void)beginLoading {
  if (!_loadingView) {
    _loadingView = [[[NSBundle mainBundle] loadNibNamed:@"LoadingView" owner:self options:nil] objectAtIndex:0];
    self.loadingView.frame = CGRectMake(0, self.tabBarController.tabBar.frame.origin.y - self.tabBarController.tabBar.bounds.size.height, self.view.bounds.size.width, self.loadingView.frame.size.height);
    self.loadingView.viewLabel.text = @"Updating Artists";
    [self.view addSubview:self.loadingView];
  }
}

- (void)endLoading {
  [self.loadingView removeFromSuperview];
  self.loadingView = nil;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"appDidReceiveNotification" object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"autoScanUpdate" object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"autoScanDone" object:nil];
}

@end