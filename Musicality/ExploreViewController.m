//
//  ExploreViewController.m
//  Musicality
//
//  Created by Evan Lewis on 10/14/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import StoreKit;
#import "UserPrefs.h"
#import "ExploreFetch.h"
#import "GenreTableViewCell.h"
#import "ExploreNavigationBar.h"
#import "ExploreViewController.h"

//The different states the view can be in; either selecting a genre or scrolling through albums
typedef NS_OPTIONS(NSUInteger, ViewState) {
  browse = 1 << 0,
  genreSelection = 1 << 1,
  loading = 1 << 2
  //TODO: Work on loading state and fetch feed
};

typedef NS_OPTIONS(NSUInteger, FeedType) {
  new = 1 << 0,
  topCharts = 1 << 1
};

@interface ExploreViewController () <SKStoreProductViewControllerDelegate, ExploreFetchDelegate>

@property (nonatomic) NSMutableArray *tableViewArray;
@property (nonatomic) NSDictionary *genres;

@property (nonatomic) NSUInteger viewState;
@property (nonatomic) NSUInteger feedType;

@end

@implementation ExploreViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  //Allows swipe back to function
  self.navigationController.interactivePopGestureRecognizer.delegate = nil;
  [self.navigationController setNavigationBarHidden:YES animated:NO];
  
  //Register TableView cells
  [self.tableView registerClass:[GenreTableViewCell class] forCellReuseIdentifier:@"genreCell"];
  
  //Tab Bar customization
  UIImage *selectedImage = [[UIImage imageNamed:@"explore_selected_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  self.tabBarItem.selectedImage = selectedImage;
  if ([[UserPrefs sharedPrefs] isDarkModeEnabled]) {
    self.tabBarController.tabBar.barTintColor = [UIColor blackColor];
    self.tabBarController.tabBar.tintColor = [UIColor whiteColor];
  } else {
    self.tabBarController.tabBar.barTintColor = [UIColor whiteColor];
    self.tabBarController.tabBar.tintColor = [UIColor blackColor];
  }
  
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
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  
}

- (void)fetchFeed:(int)genre {
  ExploreFetch *exploreFetch;
  NSURL *url;
  
  if (self.feedType == topCharts) {
    if (genre == -1) {
      url = [NSURL URLWithString:@"https://itunes.apple.com/us/rss/topalbums/limit=100/xml"];
    } else {
      url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/us/rss/topalbums/limit=100/genre=%i/xml", genre]];
    }
  }
  exploreFetch = [[ExploreFetch alloc] initWithURL:url delegate:self];
}

- (void)exploreFetchDidFinish:(ExploreFetch *)downloader {
  
}

#pragma mark TableView Methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  
  //Create Navigation Bar and set its bounds
  ExploreNavigationBar *navigationBar = [[[NSBundle mainBundle] loadNibNamed:@"ExploreNavigationBar" owner:self options:nil] objectAtIndex:0];
  navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, navigationBar.frame.size.height);
  navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:navigationBar.bounds].CGPath;
  
  return navigationBar;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == 0 || (self.viewState == genreSelection && indexPath.row <= self.genres.count)) {
    GenreTableViewCell *genreCell = [tableView dequeueReusableCellWithIdentifier:@"genreCell"];
    genreCell.textLabel.text = self.tableViewArray[indexPath.row];
    NSNumber *genreId = (NSNumber*)self.genres.allValues[indexPath.row + 1];
    genreCell.genreId = genreId.intValue;
    return genreCell;
  }
  return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == 0 && self.viewState == browse) {
    [self toggleGenreSelection:^(bool finished) {}];
  } else if (indexPath.row <= self.genres.count && self.viewState == genreSelection) {
    if (indexPath.row == 0) {
      [self toggleGenreSelection:^(bool finished) {
        //Fetch feed
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