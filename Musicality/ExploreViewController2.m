//
//  ExploreViewController.m
//  Musicality
//
//  Created by Evan Lewis on 10/14/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import StoreKit;

#import "Album.h"
#import "Button.h"
#import "MStore.h"
#import "Artist.h"
#import "UserPrefs.h"
#import "LoadingView.h"
#import "UIImageView+Haneke.h"
#import "ArtistViewController.h"
#import "ExploreNavigationBar.h"
#import "ExploreViewController.h"
#import "VariousArtistsViewController.h"

typedef NS_OPTIONS(NSUInteger, FeedTypes) {
  newAlbums = 1 << 0,
  topCharts = 1 << 1
};

@interface ExploreViewController () <NSXMLParserDelegate, SKStoreProductViewControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, copy) NSMutableArray *tableViewArray;
@property (nonatomic, copy) NSDictionary *genreDictionary;
@property (nonatomic, weak) ExploreNavigationBar *navigationBar;
@property (nonatomic, weak) Button *recentAlbumsButton;
@property (nonatomic, weak) Button *topChartsButton;

@property BOOL elementDidBegin;
@property (nonatomic) NSString *targetNode;
@property (nonatomic) NSMutableString *albumNameFeed;
@property (nonatomic) NSMutableString *artistNameFeed;
@property (nonatomic) NSString *albumArtFeed;
@property (nonatomic) NSString *albumURLFeed;
@property (nonatomic) NSNumber *artistID;

@property (nonatomic, weak) Album *selectedAlbum;
@property (nonatomic) NSUInteger currentFeedType;
@property (nonatomic) NSString *currentGenreTitle;
@property (nonatomic) NSNumber *currentGenreID;
@property (nonatomic) UIColor *bwTextColor;
@property (nonatomic) UIColor *bwBackgroundColor;
@property BOOL isGenreSelected;
@property BOOL isLoading;

@property (nonatomic) LoadingView *loadingView;
@property (nonatomic) NSNumber *alertViewActionID;
@property (nonatomic) UIAlertView *alertView;

@end

@implementation ExploreViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
 
  /*
  if (!self.tableViewArray) {
    _tableViewArray = [NSMutableArray array];
  }
  
  //Check if feed is out of date (not updated within the past hour)
  NSDate *lastFeedDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastFeedDate"];
  if (!lastFeedDate) {
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate dateWithTimeIntervalSinceNow:-8600] forKey:@"lastFeedDate"];
    lastFeedDate = [NSDate dateWithTimeIntervalSinceNow:-8600];
  }
  NSDate *hourAgo = [NSDate dateWithTimeIntervalSinceNow:-3600];
  if (![mStore thisDate:lastFeedDate isMoreRecentThan:hourAgo]) {
    //Remove all old items from table view array
    [self.tableViewArray removeAllObjects];
    [self.tableViewArray addObject:@"All Genres"];
    self.currentFeedType = topCharts;
    [self setFeedButton];
    self.currentGenreID = [NSNumber numberWithInt:-1];
    self.currentGenreTitle = @"All Genres";
    [self fetchFeed];
  }*/
  
  //dark mode customization
  if ([[UserPrefs sharedPrefs] isDarkModeEnabled]) {
    self.view.backgroundColor = [UIColor blackColor];
    _bwTextColor = [UIColor whiteColor];
    _bwBackgroundColor = [UIColor blackColor];
  } else {
    self.view.backgroundColor = [UIColor whiteColor];
    _bwTextColor = [UIColor blackColor];
    _bwBackgroundColor = [UIColor whiteColor];
  }
  
  //Tab Bar customization
  UIImage *selectedImage = [[UIImage imageNamed:@"explore_selected_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  self.tabBarItem.selectedImage = selectedImage;
  self.tabBarController.tabBar.barTintColor = self.bwBackgroundColor;
  self.tabBarController.tabBar.tintColor = self.bwTextColor;
  [self.tableView headerViewForSection:0];
  [self.tableView reloadData];
  
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  if (!self.tableViewArray) {
    _tableViewArray = [NSMutableArray array];
  }
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"appDidReceiveNotification" object:nil];
  
  //allows back swipe to work
  self.navigationController.interactivePopGestureRecognizer.delegate = nil;
  [self.navigationController setNavigationBarHidden:YES animated:NO];
  
  self.currentGenreTitle = @"All Genres";
  
  _genreDictionary = @{@"Alternative" : @20,
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
  
  [self.tableViewArray addObject:@"All Genres"];
  self.currentFeedType = topCharts;
  [self setFeedButton];
  self.currentGenreID = [NSNumber numberWithInt:-1];
  self.currentGenreTitle = @"All Genres";
  [self fetchFeed];
}

-(void)viewDidAppear:(BOOL)animated {
  if (self.tableViewArray.count <= 1 && !self.isLoading) {
    [self fetchFeed];
  }
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

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
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
}

- (void)fetchFeed {
  //Loading view
  [self beginLoading];
  [self.tableViewArray removeAllObjects];
  [self.tableViewArray addObject:self.currentGenreTitle];
  [self.tableView reloadData];
  
  NSURL *url;
  if (self.currentFeedType == newAlbums) {
    if ([self.currentGenreID isEqual: @-1]) {
      url = [[NSURL alloc]initWithString:@"https://itunes.apple.com/WebObjects/MZStore.woa/wpa/MRSS/newreleases/sf=143441/limit=50/rss.xml"];
    } else {
      url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://itunes.apple.com/WebObjects/MZStore.woa/wpa/MRSS/newreleases/sf=143441/limit=50/genre=%@/rss.xml", self.currentGenreID]];
    }
  } else if (self.currentFeedType == topCharts) {
    if ([self.currentGenreID isEqual: @-1]) {
      url = [[NSURL alloc]initWithString:@"https://itunes.apple.com/us/rss/topalbums/limit=50/xml"];
    } else {
      url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"https://itunes.apple.com/us/rss/topalbums/limit=50/genre=%@/xml", self.currentGenreID]];
    }
  } else {
    return;
  }
  DLog(@"Fetching URL: %@", url);
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // do your background tasks here
    NSXMLParser *parser = [[NSXMLParser alloc]initWithContentsOfURL:url];
    parser.delegate = self;
    [parser parse];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastFeedDate"];
    self.elementDidBegin = NO;
  });
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark Table View Data

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  
  //Add navigation bar to header
  _navigationBar = [[[NSBundle mainBundle] loadNibNamed:@"ExploreNavigationBar" owner:self options:nil] objectAtIndex:0];
  _navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, _navigationBar.frame.size.height);
  _navigationBar.layer.shadowColor = [self.bwTextColor CGColor];
  _navigationBar.layer.backgroundColor = [self.bwBackgroundColor CGColor];
  _navigationBar.layer.shadowOpacity = 0.4;
  _navigationBar.layer.shadowRadius = 2.0;
  _navigationBar.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
  _navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:_navigationBar.bounds].CGPath;
  
  self.navigationBar.exploreLabel.textColor = self.bwTextColor;
  
  //Add new button to naviagation bar
  _recentAlbumsButton = (Button*)[self.navigationBar viewWithTag:1];
  [self.recentAlbumsButton addTarget:self
                              action:@selector(showNew:)
                    forControlEvents:UIControlEventTouchUpInside];
  
  _topChartsButton = (Button*)[self.navigationBar viewWithTag:2];
  [self.topChartsButton addTarget:self
                           action:@selector(showTopCharts:)
                 forControlEvents:UIControlEventTouchUpInside];
  [self setFeedButton];
  
  UIButton *topOfPageButton = (UIButton*)[self.navigationBar viewWithTag:4];
  [topOfPageButton addTarget:self
                      action:@selector(topOfPage)
            forControlEvents:UIControlEventTouchUpInside];
  
  
  return _navigationBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if ((indexPath.row == 0 && !self.isGenreSelected) ||
      (indexPath.row <= self.genreDictionary.count && self.isGenreSelected)) {
    return 50;
  } else {
    return 195;
  }
  return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 110;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.tableViewArray.count;
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
  
  if (indexPath.row == 0 ||
      (self.isGenreSelected && indexPath.row <= self.genreDictionary.count)) {
    
    UITableViewCell *genreCell = [tableView dequeueReusableCellWithIdentifier:@"GenreCell" forIndexPath:indexPath];
    UILabel *genreLabel;
    genreLabel = (UILabel*)[genreCell.contentView viewWithTag:1];
    genreLabel.textColor = self.bwTextColor;
    genreCell.contentView.backgroundColor = self.bwBackgroundColor;
    genreLabel.text = [NSString stringWithFormat:@"%@", self.tableViewArray[indexPath.row]];
    return genreCell;
    
  } else if ((self.isGenreSelected && indexPath.row > self.genreDictionary.count) ||
             !self.isGenreSelected) {
    Album* album = self.tableViewArray[indexPath.row];
    
    UITableViewCell *albumCell = [tableView dequeueReusableCellWithIdentifier:@"AlbumCell" forIndexPath:indexPath];
    albumCell.contentView.backgroundColor = self.bwBackgroundColor;
    UILabel *albumNameLabel = (UILabel*)[albumCell.contentView viewWithTag:1];
    albumNameLabel.textColor = self.bwTextColor;
    albumNameLabel.text = album.title;
    UILabel *artistLabel = (UILabel*)[albumCell.contentView viewWithTag:2];
    artistLabel.textColor = self.bwTextColor;
    artistLabel.text = [NSString stringWithFormat:@"%@", album.artist];
    Button *artistButton = (Button*)[albumCell.contentView viewWithTag:3];
    [artistButton setColorPrefs:[[UserPrefs sharedPrefs] isDarkModeEnabled]];
    artistButton.userData = album.userData;
    artistButton.userData2 = album.artist;
    artistButton.userData3 = album.URL;
    [artistButton addTarget:self
                     action:@selector(toArtist:)
           forControlEvents:UIControlEventTouchUpInside];
    
    
    
    UIImageView *albumImageView = (UIImageView*)[albumCell.contentView viewWithTag:4];
    [albumImageView hnk_setImageFromURL:album.artworkURL placeholder:[mStore imageWithColor:[UIColor clearColor]]];
    
    //Gesture recognizer
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showActionSheet:)];
    longPress.minimumPressDuration = 0.5;
    [albumCell addGestureRecognizer:longPress];
    
    return albumCell;
  }
  return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (indexPath.row == 0 && !self.isGenreSelected) {
    [self toggleGenreSelection];
  } else if (indexPath.row < self.genreDictionary.count + 1 && self.isGenreSelected) {
    if (indexPath.row == 0) {
      self.currentGenreTitle = @"All Genres";
      self.currentGenreID = @-1;
    } else {
      self.currentGenreTitle = self.genreDictionary.allKeys[indexPath.row - 1];
      self.currentGenreID = self.genreDictionary.allValues[indexPath.row - 1];
    }
    [self toggleGenreSelection];
  } else {
    if ((indexPath.row >= self.genreDictionary.count + 1 && self.isGenreSelected) || (!self.isGenreSelected && indexPath.row != 0)) {
      [self toiTunes:indexPath];
    }
  }
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
  
}

#pragma mark NSXMLParser Delegate Methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
  self.targetNode = nil;
  
  if ([elementName isEqualToString:@"item"] || [elementName isEqualToString:@"entry"]) {
    self.elementDidBegin = YES;
    return;
  } else {
    if ([elementName isEqualToString:@"im:artist"] && !self.artistID) {
      NSString* artistLink = [attributeDict objectForKey:@"href"];
      if (artistLink && !self.artistID) {
        self.artistID = [NSNumber numberWithInt:[[mStore formattedAlbumIDFromURL:[NSURL URLWithString:artistLink]] intValue]];
      }
    }
    self.targetNode = elementName;
  }
  
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
  
  if ([self.targetNode isEqualToString:@"itms:album"] || [self.targetNode isEqualToString:@"im:name"]) {
    if (!self.albumNameFeed) {
      _albumNameFeed = [[NSMutableString alloc] initWithString:string];
    } else {
      [self.albumNameFeed appendString:string];
    }
  } else if ([self.targetNode isEqualToString:@"itms:artist"] || [self.targetNode isEqualToString:@"im:artist"]) {
    if (!self.artistNameFeed) {
      _artistNameFeed = [[NSMutableString alloc] initWithString:string];
    } else {
      [self.artistNameFeed appendString:string];
    }
  } else if ([self.targetNode isEqualToString:@"itms:coverArt"] || [self.targetNode isEqualToString:@"im:image"]) {
    self.albumArtFeed = string;
  } else if ([self.targetNode isEqualToString:@"itms:albumLink"] || [self.targetNode isEqualToString:@"id"]) {
    self.albumURLFeed = string;
  } else if ([self.targetNode isEqualToString:@"itms:artistLink"]) {
    self.artistID = [NSNumber numberWithInt:[[mStore formattedAlbumIDFromURL:[NSURL URLWithString:string]] intValue]];
  } else {
    return;
  }
  self.targetNode = nil;
  
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  if ([elementName isEqualToString:@"item"] || [elementName isEqualToString:@"entry"]) {
    if (self.albumNameFeed && self.artistNameFeed && self.albumArtFeed) {
      Album *newAlbum = [[Album alloc] initWithAlbumTitle:self.albumNameFeed
                                                   artist:self.artistNameFeed
                                               artworkURL:self.albumArtFeed
                                                 albumURL:self.albumURLFeed
                                              releaseDate:nil];
      newAlbum.userData = self.artistID;
      // when that method finishes you can run whatever you need to on the main thread
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableViewArray addObject:newAlbum];
        [self.tableView reloadData];
      });
    }
    
    self.elementDidBegin = NO;
    self.targetNode = nil;
    self.albumNameFeed = nil;
    self.artistNameFeed = nil;
    self.albumArtFeed = nil;
    self.albumURLFeed = nil;
    self.artistID = nil;
  }
  
  if ([elementName isEqualToString:@"channel"] || [elementName isEqualToString:@"feed"]) {
    //Loading View
    DLog(@"Finished");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //Load tutorial
    if(![userDefaults boolForKey:@"notFirstRun"]) {
      [userDefaults setBool:YES forKey:@"notFirstRun"];
      [userDefaults synchronize];
      UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Tutorial" bundle:nil];
      [[UIApplication sharedApplication] cancelAllLocalNotifications];
      UINavigationController *nav = (UINavigationController *)[storyboard instantiateViewControllerWithIdentifier:@"Tutorial"];
      [self presentViewController:nav animated:YES completion:nil];
    }
    [self endLoading];
  }
  
}

#pragma mark Navigation

- (void)toArtist:(Button*)sender {
  NSNumber *num = sender.userData;
  if (num) {
    Artist *artist = [[Artist alloc] initWithArtistID:num andName:sender.userData2];
    [self performSegueWithIdentifier:@"toArtist" sender:artist];
  } else {
    NSURL *url = sender.userData3;
    if (url) {
      [self performSegueWithIdentifier:@"toVariousArtists" sender:url];
    }
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqualToString:@"toArtist"]) {
    ArtistViewController *artistViewController = segue.destinationViewController;
    artistViewController.artist = sender;
  } else if ([segue.identifier isEqualToString:@"toVariousArtists"]) {
    VariousArtistsViewController *variousArtistsVC = segue.destinationViewController;
    variousArtistsVC.albumLink = sender;
  }
}

- (void)indexPathForiTunes:(Button *)button {
  [self toiTunes:button.userData];
}

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

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)topOfPage {
  [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  self.isLoading = NO;
  [self.navigationBar.layer removeAllAnimations];
}

#pragma mark Targets

- (void)showNew:(Button*)sender {
  if ([sender isKindOfClass:[Button class]] && self.currentFeedType != newAlbums) {
    self.currentFeedType = newAlbums;
    if (self.isGenreSelected) {
      [self toggleGenreSelection];
    }
    [self fetchFeed];
  }
}

- (void)showTopCharts:(Button*)sender {
  if ([sender isKindOfClass:[Button class]] && self.currentFeedType != topCharts) {
    self.currentFeedType = topCharts;
    if (self.isGenreSelected) {
      [self toggleGenreSelection];
    }
    [self fetchFeed];
  }
}

- (void)setFeedButton {
  
  if (self.currentFeedType == newAlbums) {
    [self.topChartsButton setBackgroundImage:[mStore imageWithColor:self.bwBackgroundColor] forState:UIControlStateNormal];
    [self.topChartsButton setTitleColor:self.bwTextColor forState:UIControlStateNormal];
    self.topChartsButton.layer.borderColor = [self.bwTextColor CGColor];
    [self.recentAlbumsButton setBackgroundImage:[mStore imageWithColor:self.bwTextColor] forState:UIControlStateNormal];
    [self.recentAlbumsButton setTitleColor:self.bwBackgroundColor forState:UIControlStateNormal];
    self.recentAlbumsButton.layer.borderColor = [self.bwTextColor CGColor];
  } else {
    [self.topChartsButton setBackgroundImage:[mStore imageWithColor:self.bwTextColor] forState:UIControlStateNormal];
    [self.topChartsButton setTitleColor:self.bwBackgroundColor forState:UIControlStateNormal];
    self.topChartsButton.layer.borderColor = [self.bwTextColor CGColor];
    [self.recentAlbumsButton setBackgroundImage:[mStore imageWithColor:self.bwBackgroundColor] forState:UIControlStateNormal];
    [self.recentAlbumsButton setTitleColor:self.bwTextColor forState:UIControlStateNormal];
    self.recentAlbumsButton.layer.borderColor = [self.bwTextColor CGColor];
  }
  
}

- (void)toggleGenreSelection {
  [self.tableView beginUpdates];
  
  NSMutableArray *indexPaths = [NSMutableArray array];
  //Adds the required number of index paths
  for (int i = 0; i < [self.genreDictionary count]; i++) {
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i + 1 inSection:0];
    [indexPaths addObject:indexpath];
  }
  
  if (!self.isGenreSelected) {
    //Open genre selection view
    self.isGenreSelected = YES;
    [self.tableViewArray replaceObjectAtIndex:0 withObject:@"All Genres"];
    for (int i = 0; i < [self.genreDictionary count]; i++) {
      [self.tableViewArray insertObject:[self.genreDictionary allKeys][i] atIndex:i + 1];
    }
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    [self.tableView reloadData];
  } else {
    //Close genre selection view
    self.isGenreSelected = NO;
    [self.tableViewArray removeObjectsInArray:self.genreDictionary.allKeys];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [self.tableView endUpdates];
    [self beginLoading];
    [self fetchFeed];
  }
}

- (void)showActionSheet:(id)sender {
  UILongPressGestureRecognizer *longPress = sender;
  if (longPress.state == UIGestureRecognizerStateBegan) {
    UITableViewCell *cell = (UITableViewCell*)longPress.view;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    DLog(@"Index path row for action: %ld", (long)indexPath.row);
    Album *album = self.tableViewArray[indexPath.row];
    
    NSString *textToShare = [NSString stringWithFormat:@"%@ - %@", album.artist, album.title];
    NSURL *link = [NSURL URLWithString:[NSString stringWithFormat:@"%@&at=%@", album.URL, mStore.affiliateToken]];
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

#pragma mark Loading

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  CGRect frame = self.loadingView.frame;
  frame.origin.y = scrollView.contentOffset.y + self.tableView.frame.size.height - self.loadingView.frame.size.height;
  self.loadingView.frame = frame;
  [self.view bringSubviewToFront:self.loadingView];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
  if (!self.isLoading && self.tableViewArray.count <= 1) {
    [self fetchFeed];
  }
}

- (void)beginLoading {
  self.isLoading = YES;
  if (!_loadingView) {
    _loadingView = [[[NSBundle mainBundle] loadNibNamed:@"LoadingView" owner:self options:nil] objectAtIndex:0];
    self.loadingView.frame = CGRectMake(0, self.tabBarController.tabBar.frame.origin.y - self.tabBarController.tabBar.bounds.size.height, self.view.bounds.size.width, self.loadingView.frame.size.height);
    self.loadingView.viewLabel.text = @"Loading";
    [self.view addSubview:self.loadingView];
  }
}

- (void)endLoading {
  self.isLoading = NO;
  [self.loadingView removeFromSuperview];
  self.loadingView = nil;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"appDidReceiveNotification" object:nil];
}

@end
