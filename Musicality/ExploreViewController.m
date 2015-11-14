//
//  ExploreViewController.m
//  Musicality
//
//  Created by Evan Lewis on 10/14/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import StoreKit;
@import Crashlytics;
#import "Album.h"
#import "MStore.h"
#import "UserPrefs.h"
#import "UIImageView+Haneke.h"
#import "AlbumTableViewCell.h"
#import "GenreTableViewCell.h"
#import "ExploreNavigationBar.h"
#import "ExploreViewController.h"

//The different states the view can be in; either selecting a genre or scrolling through albums
typedef NS_OPTIONS(NSUInteger, ViewState) {
  browse = 1 << 0,
  genreSelection = 1 << 1,
  loading = 1 << 2
};

typedef NS_OPTIONS(NSUInteger, FeedType) {
  new = 1 << 0,
  topCharts = 1 << 1
};

@interface ExploreViewController () <SKStoreProductViewControllerDelegate, ExploreFetchDelegate>

@property (nonatomic, weak) ExploreNavigationBar *navigationBar;

@property (nonatomic) NSMutableArray *tableViewArray;
@property (nonatomic) NSDictionary *genres;

@property (nonatomic) NSUInteger viewState;
@property (nonatomic) NSUInteger feedType;

@property (nonatomic) UIColor *cellTextColor;
@property (nonatomic) UIColor *cellBackgroundColor;

@end

@implementation ExploreViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  //Allows swipe back to function
  self.navigationController.interactivePopGestureRecognizer.delegate = nil;
  [self.navigationController setNavigationBarHidden:YES animated:NO];
  
  //Register TableView cells
  [self.tableView registerNib:[UINib nibWithNibName:@"GenreTableViewCell" bundle:nil] forCellReuseIdentifier:@"genreCell"];
  [self.tableView registerNib:[UINib nibWithNibName:@"AlbumTableViewCell" bundle:nil]forCellReuseIdentifier:@"albumCell"];
  //Tab Bar customization
  UIImage *selectedImage = [[UIImage imageNamed:@"explore_selected_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  self.tabBarItem.selectedImage = selectedImage;
  
  //List of genres
  _genres = @{@"Alternative" : @20,
              @"Blues" : @2,
              @"Children's Music" : @4,
              @"Christian & Gospel" : @22,
              @"Classical" : @5,
              @"Comedy" : @3,
              @"Country" : @6,
              @"Dance" : @17,
              @"Electronic" : @7,
              @"Fitness & Workout" : @50,
              @"Hip-Hop/Rap" : @18,
              @"Jazz" : @11,
              @"Latino" : @12,
              @"Pop" : @14,
              @"R&B/Soul" : @15,
              @"Reggae" : @24,
              @"Rock" : @21,
              @"Singer/Songwriter" : @10,
              @"Soundtrack" : @16,
              @"World" : @19};
  
  self.tableViewArray = [NSMutableArray arrayWithObject:@"All Genres"];
  self.viewState = browse;
  self.feedType = topCharts;
  [self fetchFeed:-1];
}

#pragma mark NSOperation Delegate

- (PendingOperations *)pendingOperations {
  if (!_pendingOperations) {
    _pendingOperations = [[PendingOperations alloc] init];
  }
  return _pendingOperations;
}

- (void)fetchFeed:(int)genre {
  NSURL *url;
  
  if (self.feedType == topCharts) {
    if (genre == -1) {
      url = [NSURL URLWithString:@"https://itunes.apple.com/us/rss/topalbums/limit=100/xml"];
    } else {
      url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/us/rss/topalbums/limit=100/genre=%i/xml", genre]];
    }
  }
  ExploreFetch *exploreFetch = [[ExploreFetch alloc] initWithURL:url delegate:self];
  [self.pendingOperations.requestsInProgress setObject:exploreFetch forKey:@"ExploreFetch"];
  [self.pendingOperations.requestQueue addOperation:exploreFetch];
}

- (void)exploreFetchDidFinish:(ExploreFetch *)downloader {
  if (self.viewState == genreSelection) {
    [self toggleGenreSelection:^(bool finished) {}];
  }
  [self.tableView beginUpdates];
  
  //Add the items to the table view array
  [self.tableViewArray addObjectsFromArray:downloader.albumArray];
  
  NSMutableArray *indexPaths = [NSMutableArray array];
  //Then add the required number of index paths
  for (int i = 0; i < downloader.albumArray.count; i++) {
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i + 1 inSection:0];
    [indexPaths addObject:indexpath];
  }
  [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
  [self.tableView endUpdates];
  [self.tableView reloadData];
}

#pragma mark TableView Methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  
  //Create Navigation Bar and set its bounds
  _navigationBar = [[[NSBundle mainBundle] loadNibNamed:@"ExploreNavigationBar" owner:self options:nil] objectAtIndex:0];
  _navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationBar.frame.size.height);
  _navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.navigationBar.bounds].CGPath;
  
  return _navigationBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 110;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.tableViewArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0 || (self.viewState == genreSelection && indexPath.row <= self.genres.count)) {
    return  50;
  } else {
    return 195;
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
    GenreTableViewCell *genreCell = [tableView dequeueReusableCellWithIdentifier:@"genreCell"];
    NSNumber *genreId = (NSNumber*)self.genres.allValues[indexPath.row + 1];
    genreCell.genreId = genreId.intValue;
    return genreCell;
  } else {
    Album *album = self.tableViewArray[indexPath.row];
    AlbumTableViewCell *albumCell = [tableView dequeueReusableCellWithIdentifier:@"albumCell"];
    albumCell.albumLabel.text = album.title;
    albumCell.artistLabel.text = album.artist;
    [albumCell.albumImageView hnk_setImageFromURL:album.artworkURL placeholder:[mStore imageWithColor:[UIColor clearColor]]];
    return albumCell;
  }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  //If the user selected the first item in the array and the genre selection was closed:
  if (indexPath.row == 0 && self.viewState == browse) {
    //Open genre selection
    [self toggleGenreSelection:^(bool finished) {}];
  } else if (indexPath.row <= self.genres.count && self.viewState == genreSelection) {
    //If genre selection was open:
    if (indexPath.row == 0) {
      //Close genre selection
      [self toggleGenreSelection:^(bool finished) {}];
    } else {
      //New genre selected; we need to refetch
      [self toggleGenreSelection:^(bool finished) {
        NSNumber *selectedGenreValue = self.genres.allValues[indexPath.row -1];
        [self fetchFeed:selectedGenreValue.intValue];
      }];
    }
  }
  
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

@end