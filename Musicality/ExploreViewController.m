//
//  ExploreViewController.m
//  Musicality
//
//  Created by Evan Lewis on 10/14/14.
//  Copyright © 2014 Evan Lewis. All rights reserved.
//
// The first view that the app loads. The explore tab shows the top albums in iTunes

@import StoreKit;
@import Crashlytics;
#import "Album.h"
#import "Artist.h"
#import "MStore.h"
#import "AutoScan.h"
#import "UserPrefs.h"
#import "ColorScheme.h"
#import "ExploreViewModel.h"
#import "UIImageView+Haneke.h"
#import "AlbumTableViewCell.h"
#import "FilterTableViewCell.h"
#import "ExploreNavigationBar.h"
#import "ArtistViewController.h"
#import "ExploreViewController.h"
#import "MViewControllerDelegate.h"
#import "VariousArtistsViewController.h"

//The different states the view can be in; either selecting a genre or scrolling through albums. The feed type changes whether it is the top charts or the new albums view
typedef NS_OPTIONS(NSUInteger, ViewState) {
  browse = 1 << 0,
  genreSelection = 1 << 1,
  loading = 1 << 2
};

typedef NS_OPTIONS(NSUInteger, FeedType) {
  new = 1 << 0,
  topCharts = 1 << 1
};

@interface ExploreViewController () <ExploreViewModelDelegate, MViewControllerDelegate, SKStoreProductViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIRefreshControl *refresh;
@property (nonatomic, weak) ExploreNavigationBar *navigationBar;
@property (nonatomic) ExploreViewModel *exploreViewModel;

@property (nonatomic) NSMutableArray *tableViewArray;
@property (nonatomic) NSArray *albumArray;
@property (nonatomic) NSDictionary *genres;

@property (nonatomic) NSUInteger viewState;
@property (nonatomic) NSUInteger feedType;

@property (nonatomic) UIColor *cellTextColor;
@property (nonatomic) UIColor *cellBackgroundColor;

@property int currentGenreId;
@property (copy, nonatomic) NSString *currentGenreTitle;

@property (nonatomic) UIView *loadingView;

@end

@implementation ExploreViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  //Allows swipe back to functiondidReceiveNotification
  self.navigationController.interactivePopGestureRecognizer.delegate = nil;
  [self.navigationController setNavigationBarHidden:YES animated:NO];
  
  //Register notification
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewMovedToForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
  
  //Register TableView cells
  [self.tableView registerNib:[UINib nibWithNibName:@"FilterTableViewCell" bundle:nil] forCellReuseIdentifier:@"filterCell"];
  [self.tableView registerNib:[UINib nibWithNibName:@"AlbumTableViewCell" bundle:nil]forCellReuseIdentifier:@"albumCell"];
  
  _exploreViewModel = [[ExploreViewModel alloc] initWithDelegate:self];
  
  //List of genres
  _genres = @{@"Alternative" : @20, @"Blues" : @2, @"Children's Music" : @4, @"Christian & Gospel" : @22, @"Classical" : @5, @"Comedy" : @3, @"Country" : @6, @"Dance" : @17, @"Electronic" : @7, @"Fitness & Workout" : @50, @"Hip-Hop/Rap" : @18, @"Jazz" : @11, @"Latino" : @12, @"Pop" : @14, @"R&B/Soul" : @15, @"Reggae" : @24, @"Rock" : @21, @"Singer/Songwriter" : @10, @"Soundtrack" : @16, @"World" : @19};
  
  self.tableViewArray = [NSMutableArray arrayWithObject:@"All Genres"];
  self.viewState = browse;
  self.feedType = topCharts;
  self.currentGenreId = -1;
  self.currentGenreTitle = @"All Genres";
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  //Tab Bar customization
  UIImage *selectedImage = [[UIImage imageNamed:@"explore_selected_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  self.tabBarItem.selectedImage = selectedImage;
  self.tabBarController.tabBar.barTintColor = [[ColorScheme sharedScheme] primaryColor];
  self.tabBarController.tabBar.tintColor = [[ColorScheme sharedScheme] secondaryColor];
  [self.tableView headerViewForSection:0];
  
  self.view.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
  [self.tableView reloadData];
  [self viewMovedToForeground];
}

#pragma mark - MViewController Delegate
- (void)viewMovedToForeground {
  if ((!self.albumArray || [self.albumArray count] == 0) && self.viewState != loading) {
    [self fetchFeed];
  }
  
  self.refresh.tintColor = [[ColorScheme sharedScheme] secondaryColor];
  [self checkForNotification: mStore.localNotification];
}

- (void)checkForNotification:(UILocalNotification *)localNotification {
  if (localNotification) {
    DLog(@"Local Notification: %@", mStore.localNotification);
    // Remove the local notification when we're finished with it so it doesn't get reused
    [mStore setLocalNotification:nil];
    DLog(@"Not background, calling toiTunes");
    [self loadStoreProductViewController:localNotification.userInfo];
  }
}

#pragma mark NSOperation Delegate

- (void)fetchFeed {
  [self beginLoading];
  [self.exploreViewModel beginWithFeedType:self.feedType andGenre:self.currentGenreId];
}

- (void)didFinishFetchingFeed:(NSArray *)albumArray {
  [self refresh:self];
  
  if (self.viewState == genreSelection) {
    [self toggleGenreSelection:^(bool finished) {}];
  }
  
  [self.tableView beginUpdates];
  [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
  [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
  //Add the items to the table view array
  self.tableViewArray = [NSMutableArray arrayWithObject: self.currentGenreTitle];
  _albumArray = [NSArray arrayWithArray: albumArray];
  [self.tableViewArray addObjectsFromArray: self.albumArray];
  
  NSMutableArray *indexPaths = [NSMutableArray array];
  //Then add the required number of index paths
  for (int i = 0; i < albumArray.count; i++) {
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i + 1 inSection:0];
    [indexPaths addObject:indexpath];
  }
  [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
  [self.tableView endUpdates];
  [self.tableView reloadData];
  
  [self endLoading];
  
  if (![mStore isToday: mStore.lastLibraryScanDate] && [[UserPrefs sharedPrefs] isAutoUpdateEnabled] && ![[AutoScan sharedScan] isScanning]) {
    [[AutoScan sharedScan] startScan];
  }
}

#pragma mark TableView Methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  //Create Navigation Bar and set its bounds
  _navigationBar = [[[NSBundle mainBundle] loadNibNamed:@"ExploreNavigationBar" owner:self options:nil] objectAtIndex:0];
  _navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationBar.frame.size.height);
  _navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.navigationBar.bounds].CGPath;
  [_navigationBar.topChartsButton addTarget:self action:@selector(showTopCharts:) forControlEvents:UIControlEventTouchUpInside];
  [_navigationBar.exploreNewButton addTarget:self action:@selector(showNewReleases:) forControlEvents:UIControlEventTouchUpInside];
  [_navigationBar.topOfPageButton addTarget:self action:@selector(topOfPage) forControlEvents:UIControlEventTouchUpInside];
  if (self.feedType == topCharts) {
    [_navigationBar.topChartsButton setSelectedStyle];
    [_navigationBar.exploreNewButton setDeselectedStyle];
  } else {
    [_navigationBar.exploreNewButton setSelectedStyle];
    [_navigationBar.topChartsButton setDeselectedStyle];
  }
  return _navigationBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 96;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.tableViewArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0 || (self.viewState == genreSelection && indexPath.row <= self.genres.count)) {
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
  
  if (indexPath.row == 0 || (self.viewState == genreSelection && indexPath.row <= self.genres.count)) {
    FilterTableViewCell *filterCell = [tableView dequeueReusableCellWithIdentifier:@"filterCell"];
    NSNumber *filterId;
    if (indexPath.row == 0) {
      filterId = @-1;
    } else {
      filterId = (NSNumber*)self.genres.allValues[indexPath.row - 1];
    }
    filterCell.filterId = filterId.intValue;
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
    NSDictionary *userInfo = @{@"AlbumURL" : album.URL, @"Artist" : album.artist, @"ArtistID" : album.artistID, @"albumID" : [mStore formattedAlbumIDFromURL:album.URL]};
    albumCell.viewArtistButton.buttonInfo = userInfo;
    albumCell.cellInfo = userInfo;
    if ([album.artistID isEqual: @0]) {
      [albumCell.viewArtistButton setTitle:@"View Artists" forState:UIControlStateNormal];
      [albumCell.viewArtistButton setTitle:@"View Artists" forState:UIControlStateHighlighted];
    } else {
      [albumCell.viewArtistButton setTitle:@"View Artist" forState:UIControlStateNormal];
      [albumCell.viewArtistButton setTitle:@"View Artist" forState:UIControlStateHighlighted];
    }
    
    //Add gesture recognizer for action sheet
    //Gesture recognizer
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showActionSheet:)];
    longPress.minimumPressDuration = 0.5;
    [albumCell addGestureRecognizer:longPress];
    return albumCell;
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  //If the user selected the first item in the array and the genre selection was closed:
  if (indexPath.row == 0 && self.viewState == browse) {
    //Open genre selection
    [self toggleGenreSelection:^(bool finished) {}];
  } else if (indexPath.row <= self.genres.count && self.viewState == genreSelection) {
    //New genre selected; we need to refetch
    if (indexPath.row == 0) {
      [self toggleGenreSelection:^(bool finished) {
        self.currentGenreId = -1;
        self.currentGenreTitle = @"All Genres";
        [self fetchFeed];
      }];
    } else {
      NSNumber *selectedGenreValue = self.genres.allValues[indexPath.row - 1];
      if (selectedGenreValue.intValue == self.currentGenreId) {
        //Close genre selection
        [self toggleGenreSelection:^(bool finished) {}];
      } else {
        [self toggleGenreSelection:^(bool finished) {
          self.currentGenreId = selectedGenreValue.intValue;
          self.currentGenreTitle = self.genres.allKeys[indexPath.row - 1];
          [self fetchFeed];
        }];
      }
    }
  } else if ((indexPath.row > self.genres.count && self.viewState == genreSelection) || (indexPath.row > 0 && self.viewState == browse)){
    AlbumTableViewCell *albumCell = [self.tableView cellForRowAtIndexPath:indexPath];
    [self loadStoreProductViewController:albumCell.cellInfo];
  }
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark Targets

- (void)toggleGenreSelection:(void (^)(bool finished))completion {
  [self.tableView beginUpdates];
  
  NSMutableArray *indexPaths = [NSMutableArray array];
  //Adds the required number of index paths
  for (int i = 0; i < [self.genres count]; i++) {
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i + 1 inSection:0];
    [indexPaths addObject:indexpath];
  }
  
  if (self.viewState == browse) {
    //Open genre selection view
    self.viewState = genreSelection;
    //If we had a previous genre selected, the top will be that item. We need to switch it back to all genres
    [self.tableViewArray replaceObjectAtIndex:0 withObject:@"All Genres"];
    for (int i = 0; i < [self.genres count]; i++) {
      //Add the list of genres to the tableView
      [self.tableViewArray insertObject:[self.genres allKeys][i] atIndex:i + 1];
    }
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    [self.tableView reloadData];
  } else {
    //Close genre selection view
    self.viewState = browse;
    [self.tableViewArray removeObjectsInArray:self.genres.allKeys];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
  }
  
  completion(YES);
}

- (void)showTopCharts:(Button*)sender {
  self.feedType = topCharts;
  [self.navigationBar.topChartsButton setSelectedStyle];
  [self.navigationBar.exploreNewButton setDeselectedStyle];
  [self fetchFeed];
}

- (void)showNewReleases:(Button*)sender {
  self.feedType = new;
  [self.navigationBar.exploreNewButton setSelectedStyle];
  [self.navigationBar.topChartsButton setDeselectedStyle];
  [self fetchFeed];
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

- (void)topOfPage {
  [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (IBAction)refresh:(id)sender {
  // If the user pulls down to refresh, start refreshing
  if ([sender isKindOfClass:[UIRefreshControl class]]) {
    [self fetchFeed];
  } else {
    // If the VC calls the method, end refreshing
    [self.refresh endRefreshing];
  }
}

- (void)beginLoading {
  DLog(@"");
  //Close genre selection if it's open
  if (self.viewState == genreSelection) {
    [self toggleGenreSelection:^(bool finished) {
      nil;
    }];
  }
  
  //If it's not loading yet then start
  if (self.viewState != loading) {
    self.viewState = loading;
    self.loadingView = [[UIView alloc] initWithFrame:self.view.frame];
    self.loadingView.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
    self.loadingView.alpha = 0;
    UILabel* loadingLabel = [[UILabel alloc] initWithFrame:self.loadingView.frame];
    loadingLabel.text = @"Loading";
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
    loadingLabel.center = self.loadingView.center;
    [self.loadingView addSubview:loadingLabel];
    [self.view insertSubview:self.loadingView belowSubview:self.navigationBar];
    [UIView animateWithDuration:0.2 animations:^{
      self.loadingView.alpha = 1.0;
    }];
  }
}

- (void)endLoading {
  DLog(@"");
  if (self.viewState == loading) {
    self.viewState = browse;
    [UIView animateWithDuration:0.2 animations:^{
      self.loadingView.alpha = 0.0;
    } completion:^(BOOL finished) {
      [self.loadingView removeFromSuperview];
      self.loadingView = nil;
    }];
  }
}

#pragma mark Navigation

- (void)toArtist:(Button*)sender {
  if (![sender.buttonInfo[@"ArtistID"] isEqual: @0]) {
    Artist *artist = [[Artist alloc] initWithArtistID:sender.buttonInfo[@"ArtistID"] andName:sender.buttonInfo[@"Artist"]];
    [self performSegueWithIdentifier:@"toArtist" sender:artist];
  } else {
    [self performSegueWithIdentifier:@"toVariousArtists" sender:sender.buttonInfo[@"AlbumURL"]];
  }
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

- (void)loadStoreProductViewController:(NSDictionary *)userInfo {
  NSNumber *albumID = userInfo[@"albumID"];
  if (!albumID) {
    return;
  }
  
  // Initialize Product View Controller
  if ([SKStoreProductViewController class] != nil) {
    // Configure View Controller
    SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
    [storeViewController setDelegate:self];
    NSDictionary *productParams = @{SKStoreProductParameterITunesItemIdentifier : albumID, SKStoreProductParameterAffiliateToken : mStore.affiliateToken};
    [storeViewController loadProductWithParameters:productParams completionBlock:^(BOOL result, NSError *error) {
      if (error) {
        // handle the error
        NSLog(@"%@",error.description);
      }
      [self presentViewController:storeViewController animated:YES completion:nil];
    }];
  }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  
  if (self.loadingView) {
    CGRect frame = self.loadingView.frame;
    frame.origin.y = scrollView.contentOffset.y;
    self.loadingView.frame = frame;
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

@end