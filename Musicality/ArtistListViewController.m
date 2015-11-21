//
//  ArtistListViewController.m
//  Musicality
//
//  Created by Evan Lewis on 11/12/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

#import "MStore.h"
#import "ArtistList.h"
#import "UIImageView+Haneke.h"
#import "AlbumTableViewCell.h"
#import "FilterTableViewCell.h"
#import "LatestReleaseSearch.h"
#import "ArtistsNavigationBar.h"
#import "ArtistListViewController.h"

typedef NS_OPTIONS(NSUInteger, ViewState) {
  browse = 1 << 0,
  filterSelection = 1 << 1
};

typedef NS_OPTIONS(NSUInteger, FilterType) {
  latestReleases = 1 << 0,
  artists = 1 << 1,
  hidePreOrders = 1 << 2,
};

@interface ArtistListViewController ()

@property (nonatomic, weak) ArtistsNavigationBar *navigationBar;

@property (nonatomic) NSMutableArray *tableViewArray;
@property (nonatomic) NSDictionary *filters;

@property (nonatomic) NSString *currentFilterTitle;

@property (nonatomic) NSUInteger viewState;
@property (nonatomic) NSUInteger filterType;

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
  
  //Filter Items
  _filters = @{
               @"Latest Releases": @0,
               @"Artists" : @1,
               @"Hide Pre-Orders" : @2
               };
  
  self.viewState = browse;
  self.filterType = latestReleases;
  self.currentFilterTitle = @"Latest Releases";
  [self update];
}

#pragma mark NSOperation Methods

- (void)update {
  
  DLog(@"");
  
  NSOrderedSet *artistSet = [[ArtistList sharedList] artistSet];
  if (artistSet.count == 0) {
    DLog(@"No artists found");
    return;
  }
  
  for (Artist* artist in [[ArtistList sharedList] artistSet]) {
    if ([mStore thisDate:[NSDate dateWithTimeIntervalSinceNow:-604800] isMoreRecentThan:artist.lastCheckDate]) {
      LatestReleaseSearch *albumSearch = [[LatestReleaseSearch alloc] initWithArtist:artist delegate:self];
      [self.pendingOperations.requestsInProgress setObject:albumSearch forKey:[NSString stringWithFormat:@"Album Search for %@", artist.name]];
      [self.pendingOperations.requestQueue addOperation:albumSearch];
    }
  }
  
  if (self.pendingOperations.requestsInProgress.count == 0) {
    [self populate];
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
  if (self.pendingOperations.requestsInProgress.count == 0) {
    [self populate];
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
  [_navigationBar.importFromLibraryButton addTarget:self action:@selector(toImportArtists:) forControlEvents:UIControlEventTouchUpInside];
  [_navigationBar.refreshButton addTarget:self action:@selector(update) forControlEvents:UIControlEventTouchUpInside];
  return _navigationBar;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.tableViewArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 95;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0 || (self.viewState == filterSelection && indexPath.row <= self.filters.count)) {
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
  
  if (indexPath.row == 0 || (self.viewState == filterSelection && indexPath.row <= self.filters.count)) {
    FilterTableViewCell *filterCell = [tableView dequeueReusableCellWithIdentifier:@"filterCell"];
    NSNumber *filterId;
    if (indexPath.row == 0) {
      filterId = @0;
    } else {
      filterId = (NSNumber*)self.filters.allValues[indexPath.row - 1];
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

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"autoScanDone" object:nil];
}

@end