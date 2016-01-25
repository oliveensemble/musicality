//
//  ArtistListViewController.m
//  Musicality
//
//  Created by Evan Lewis on 11/12/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import StoreKit;
#import "MStore.h"
#import "AutoScan.h"
#import "UserPrefs.h"
#import "ArtistList.h"
#import "UIImageView+Haneke.h"
#import "AlbumTableViewCell.h"
#import "FilterTableViewCell.h"
#import "LatestReleaseSearch.h"
#import "ArtistViewController.h"
#import "ArtistsNavigationBar.h"
#import "ArtistListViewController.h"
#import "LibraryListViewController.h"
#import "VariousArtistsViewController.h"

typedef NS_OPTIONS(NSUInteger, ViewState) {
  browse = 1 << 0,
  filterSelection = 1 << 1
};

typedef NS_OPTIONS(NSUInteger, FilterType) {
  latestReleases = 1 << 0,
  artists = 1 << 1,
  hidePreOrders = 1 << 2,
};

@interface ArtistListViewController () <SKStoreProductViewControllerDelegate>

@property (nonatomic, weak) ArtistsNavigationBar *navigationBar;

@property (nonatomic) NSMutableArray *tableViewArray;
@property (nonatomic) NSArray *filters;

@property (nonatomic) NSString *currentFilterTitle;

@property (nonatomic) NSUInteger viewState;
@property (nonatomic) NSUInteger filterType;
@property BOOL isUpdating;

@end

@implementation ArtistListViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  //Allows swipe back to function
  self.navigationController.interactivePopGestureRecognizer.delegate = nil;
  [self.navigationController setNavigationBarHidden:YES animated:NO];
  
  //Register TableView cells
  [self.tableView registerNib:[UINib nibWithNibName:@"FilterTableViewCell" bundle:nil] forCellReuseIdentifier:@"filterCell"];
  [self.tableView registerNib:[UINib nibWithNibName:@"AlbumTableViewCell" bundle:nil]forCellReuseIdentifier:@"albumCell"];
  
  //Tab Bar customization
  UIImage *selectedImage = [[UIImage imageNamed:@"mic_selected_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  self.tabBarItem.selectedImage = selectedImage;
  self.tabBarController.tabBar.barTintColor = [UIColor whiteColor];
  self.tabBarController.tabBar.tintColor = [UIColor blackColor];
  [self.tableView headerViewForSection:0];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(update) name:@"autoScanFinished" object:nil];
  
  //Clear the badge when the user views the page
  [[[[[self tabBarController] tabBar] items] objectAtIndex:1] setBadgeValue:nil];
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
  
  //Filter Items
  _filters = @[@"Latest Releases", @"Artists", @"Hide Pre-Orders"];
  
  self.viewState = browse;
  self.filterType = latestReleases;
  self.currentFilterTitle = @"Latest Releases";
  self.isUpdating = NO;
  
  //Add the items to the table view array
  self.tableViewArray = [NSMutableArray arrayWithObject:self.currentFilterTitle];
  NSArray *sortedAlbums = [self sortedAlbums];
  [self.tableViewArray addObjectsFromArray:sortedAlbums];
  
  [self update];
}

- (void)viewWillAppear:(BOOL)animated {
  
  if ([[UserPrefs sharedPrefs] artistListNeedsUpdating] && ![[AutoScan sharedScan] isScanning]) {
    [self update];
  }
  
  if ([[AutoScan sharedScan] isScanning]) {
    [self beginLoading];
    [self updateLoadingLabelWithString:@"Scanning Library"];
  }
}

#pragma mark NSOperation Methods

- (void)update {
  
  [self endLoading];
  if (self.viewState == filterSelection) {
    [self toggleFilterSelection:^(bool finished) {
      nil;
    }];
  }
  
  [self beginLoading];
  NSOrderedSet *artistSet = [[ArtistList sharedList] artistSet];
  if (artistSet.count == 0) {
    DLog(@"No artists found");
    [self endLoading];
    return;
  }
  
  for (Artist* artist in [[ArtistList sharedList] artistSet]) {
    if (([mStore thisDate:[NSDate dateWithTimeIntervalSinceNow:-604800] isMoreRecentThan:artist.lastCheckDate]) || artist.lastCheckDate == nil) {
      LatestReleaseSearch *albumSearch = [[LatestReleaseSearch alloc] initWithArtist:artist delegate:self];
      [self.pendingOperations.requestsInProgress setObject:albumSearch forKey:[NSString stringWithFormat:@"Album Search for %@", artist.name]];
      [self.pendingOperations.requestQueue addOperation:albumSearch];
    }
  }
}

- (PendingOperations *)pendingOperations {
  if (!_pendingOperations) {
    _pendingOperations = [[PendingOperations alloc] init];
  }
  return _pendingOperations;
}

- (void)latestReleaseSearchDidFinish:(LatestReleaseSearch *)downloader {
  [[ArtistList sharedList] updateLatestRelease:downloader.album forArtist:downloader.artist];
  [self.pendingOperations.requestsInProgress removeObjectForKey:[NSString stringWithFormat:@"Album Search for %@", downloader.artist.name]];
  [self updateLoadingLabelWithString:[NSString stringWithFormat:@"Updating %@", downloader.artist.name]];

  if (self.pendingOperations.requestsInProgress.count == 0) {
    [[ArtistList sharedList] saveChanges];
    [self populate];
    [self endLoading];
  }
}

- (void)populate {
  [self.tableView beginUpdates];
  [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
  [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
  //Add the items to the table view array
  self.tableViewArray = [NSMutableArray arrayWithObject:self.currentFilterTitle];
  NSArray *sortedAlbums = [self sortedAlbums];
  [self.tableViewArray addObjectsFromArray:sortedAlbums];
  
  NSMutableArray *indexPaths = [NSMutableArray array];
  //Then add the required number of index paths
  for (int i = 0; i < sortedAlbums.count; i++) {
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i + 1 inSection:0];
    [indexPaths addObject:indexpath];
  }
  [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
  [self.tableView endUpdates];
  [self.tableView reloadData];
}

- (NSMutableArray *)sortedAlbums {
  //Sort albums after checking, before they are to be displayed
  NSMutableArray *albumsArray = [NSMutableArray array];
  for (Artist *artist in [[ArtistList sharedList] artistSet]) {
    if (artist.latestRelease) {
      artist.latestRelease.artistID = artist.artistID;
      [albumsArray addObject:artist.latestRelease];
    }
  }
  
  NSPredicate *filterPreOrders = [NSPredicate predicateWithBlock:^BOOL(Album *album, NSDictionary<NSString *,id> * _Nullable bindings) {
    return album.isPreOrder == NO;
  }];
  
  if (self.filterType == latestReleases) {
    return [[[[albumsArray sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects] mutableCopy];
  } else if (self.filterType == artists) {
    return albumsArray;
  } else if (self.filterType == hidePreOrders) {
    NSArray *albums = [albumsArray filteredArrayUsingPredicate:filterPreOrders];
    return [[[[albums sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects] mutableCopy];
  }
  return nil;
}

#pragma mark TableView Methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  
  //Create Navigation Bar and set its bounds
  _navigationBar = [[[NSBundle mainBundle] loadNibNamed:@"ArtistsNavigationBar" owner:self options:nil] objectAtIndex:0];
  _navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationBar.frame.size.height);
  _navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.navigationBar.bounds].CGPath;
  [_navigationBar.importFromLibraryButton addTarget:self action:@selector(toLibraryList:) forControlEvents:UIControlEventTouchUpInside];
  [_navigationBar.refreshButton addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
  [_navigationBar.topOfPageButton addTarget:self action:@selector(topOfPage) forControlEvents:UIControlEventTouchUpInside];
  
  return _navigationBar;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.tableViewArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 95;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0 || (self.viewState == filterSelection && indexPath.row < self.filters.count)) {
    return  50;
  } else {
    return 150;
  }
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
  
  // Set layout margins to zero
  if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
    cell.layoutMargins = UIEdgeInsetsZero;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == 0 || (self.viewState == filterSelection && indexPath.row < self.filters.count)) {
    FilterTableViewCell *filterCell = [tableView dequeueReusableCellWithIdentifier:@"filterCell"];
    filterCell.filterLabel.text = self.tableViewArray[indexPath.row];
    return filterCell;
  } else {
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
    [albumCell.viewArtistButton addTarget:self action:@selector(toArtist:) forControlEvents:UIControlEventTouchUpInside];
    
    //Add user info to cell and button
    albumCell.viewArtistButton.buttonInfo = @{@"AlbumURL" : album.URL, @"Artist" : album.artist, @"ArtistID" : album.artistID};
    albumCell.cellInfo = @{@"AlbumURL" : album.URL, @"Artist" : album.artist, @"ArtistID" : album.artistID, @"Album" : album.title};
    
    //Add gesture recognizer for action sheet
    //Gesture recognizer
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showActionSheet:)];
    longPress.minimumPressDuration = 0.5;
    [albumCell addGestureRecognizer:longPress];
    return albumCell;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  //If the user selected the first item in the array and the filter selection was closed:
  if (indexPath.row == 0 && self.viewState == browse) {
    //Open genre selection
    [self toggleFilterSelection:^(bool finished) {}];
  } else if (indexPath.row < self.filters.count && self.viewState == filterSelection) {
    //New filter selected; we need to refetch
    if (indexPath.row == 0) {
      [self toggleFilterSelection:^(bool finished) {
        self.currentFilterTitle = @"Latest Releases";
        self.filterType = latestReleases;
      }];
    } else if (indexPath.row == 1) {
      [self toggleFilterSelection:^(bool finished) {
        self.currentFilterTitle = @"Artists";
        self.filterType = artists;
      }];
    } else {
      [self toggleFilterSelection:^(bool finished) {
        self.currentFilterTitle = @"Hide Pre-Orders";
        self.filterType = hidePreOrders;
      }];
    }
    [self populate];
  } else if ((indexPath.row > self.filters.count && self.viewState == filterSelection) || (indexPath.row > 0 && self.viewState == browse)){
    AlbumTableViewCell *albumCell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self toiTunes:albumCell.cellInfo];
  }
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Targets
- (void)toggleFilterSelection:(void (^)(bool finished))completion {
  [self.tableView beginUpdates];
  
  NSMutableArray *indexPaths = [NSMutableArray array];
  //Adds the required number of index paths
  for (int i = 1; i < [self.filters count]; i++) {
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:0];
    [indexPaths addObject:indexpath];
  }
  
  if (self.viewState == browse) {
    //Open genre selection view
    self.viewState = filterSelection;
    //If we had a previous genre selected, the top will be that item. We need to switch it back to all genres
    [self.tableViewArray replaceObjectAtIndex:0 withObject:@"Latest Releases"];
    for (int i = 1; i < [self.filters count]; i++) {
      //Add the list of genres to the tableView
      [self.tableViewArray insertObject:self.filters[i] atIndex:i];
    }
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    [self.tableView reloadData];
  } else {
    //Close genre selection view
    self.viewState = browse;
    [self.tableViewArray removeObjectsInArray:self.filters];
    [self.tableViewArray insertObject:self.currentFilterTitle atIndex:0];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
  }
  
  completion(YES);
}

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

- (void)refresh {
  DLog(@"Refresh");
  for (Artist* artist in [[ArtistList sharedList] artistSet]) {
    LatestReleaseSearch *albumSearch = [[LatestReleaseSearch alloc] initWithArtist:artist delegate:self];
    [self.pendingOperations.requestsInProgress setObject:albumSearch forKey:[NSString stringWithFormat:@"Album Search for %@", artist.name]];
    [self.pendingOperations.requestQueue addOperation:albumSearch];
  }
}

- (void)topOfPage {
  if (self.tableViewArray.count > 5) {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
  }
}

#pragma mark Navigation

- (void)beginLoading {
  if (!self.isUpdating) {
    self.isUpdating = YES;
    [self.navigationBar beginLoading];
  }
}

- (void)updateLoadingLabelWithString:(NSString*)text {
  if (self.isUpdating) {
    [self.navigationBar updateLoadingLabelWithString:text];
  }
}

- (void)endLoading {
  if (self.isUpdating) {
    self.isUpdating = NO;
    [self.navigationBar endLoading];
  }
}

- (void)toiTunes:(NSDictionary*)cellInfo {
  // Initialize Product View Controller
  SKStoreProductViewController *storeProductViewController = [[SKStoreProductViewController alloc] init];
  // Configure View Controller
  storeProductViewController.delegate = self;
  [storeProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : [mStore formattedAlbumIDFromURL:cellInfo[@"AlbumURL"]], SKStoreProductParameterAffiliateToken : mStore.affiliateToken} completionBlock:^(BOOL result, NSError *error) {
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

- (void)toArtist:(Button*)sender {
  if (![sender.buttonInfo[@"ArtistID"] isEqual: @0]) {
    Artist *artist = [[Artist alloc] initWithArtistID:sender.buttonInfo[@"ArtistID"] andName:sender.buttonInfo[@"Artist"]];
    [self performSegueWithIdentifier:@"toArtist" sender:artist];
  } else {
    [self performSegueWithIdentifier:@"toVariousArtists" sender:sender.buttonInfo[@"AlbumURL"]];
  }
}

- (void)toLibraryList:(Button*)sender {
  [self performSegueWithIdentifier:@"toLibraryList" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"toArtist"]) {
    ArtistViewController *artistVC = segue.destinationViewController;
    artistVC.artist = sender;
  } else if ([segue.identifier isEqualToString:@"toVariousArtists"]) {
    VariousArtistsViewController *variousArtistsVC = segue.destinationViewController;
    variousArtistsVC.albumLink = sender;
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"autoScanDone" object:nil];
}

@end