//
//  ArtistViewController.m
//  Musicality
//
//  Created by Evan Lewis on 11/24/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import StoreKit;

#import "Album.h"
#import "Button.h"
#import "MStore.h"
#import "UserPrefs.h"
#import "ArtistList.h"
#import "AlbumTableViewCell.h"
#import "UIImageView+Haneke.h"
#import "ArtistNavigationBar.h"
#import "ArtistViewController.h"

@interface ArtistViewController () <NSURLSessionTaskDelegate, SKStoreProductViewControllerDelegate>

@property (nonatomic) NSMutableArray *albumList;
@property (nonatomic, weak) ArtistNavigationBar *navigationBar;
@property (nonatomic) Button *notifyButton;
@property BOOL hasPreOrder;
@property BOOL isInNotificationList;

@property (nonatomic) UIColor *bwTextColor;
@property (nonatomic) UIColor *bwBackgroundColor;

@property (nonatomic) NSNumber *alertViewActionID;

@property (nonatomic) UIAlertView *alertView;

@end

@implementation ArtistViewController

- (void)viewWillAppear:(BOOL)animated {
  
  [super viewWillAppear:animated];
  
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
  
  //    //Tab Bar customization
  UIImage *selectedImage = [[UIImage imageNamed:@"explore_selected_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  self.tabBarItem.selectedImage = selectedImage;
  self.tabBarController.tabBar.barTintColor = self.bwBackgroundColor;
  self.tabBarController.tabBar.tintColor = self.bwTextColor;
  
  for (Artist *artistNotified in [[ArtistList sharedList] artistSet]) {
    if (artistNotified.artistID == self.artist.artistID) {
      self.isInNotificationList = YES;
    }
  }
  
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationController.interactivePopGestureRecognizer.delegate = nil;
  [self.navigationController setNavigationBarHidden:YES animated:NO];
  DLog(@"ARTIST %@\n\n\n\n\n" , self.artist.description);
  
  [self.tableView registerNib:[UINib nibWithNibName:@"AlbumTableViewCell" bundle:nil] forCellReuseIdentifier:@"albumCell"];
  
  //Session config
  NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
  sessionConfig.timeoutIntervalForRequest = 10;
  NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
  
  NSURL *artistURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@&entity=album&sort=recent", self.artist.artistID]];
  NSURLSessionDownloadTask *getAlbumsTask = [session downloadTaskWithURL:artistURL];
  [getAlbumsTask resume];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"appDidReceiveNotification" object:nil];
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

#pragma mark Table View Data

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  
  //Add navigation bar to header
  _navigationBar = [[[NSBundle mainBundle] loadNibNamed:@"ArtistNavigationBar" owner:self options:nil] objectAtIndex:0];
  UILabel *artistNameLabel = (UILabel*)[self.navigationBar viewWithTag:1];
  artistNameLabel.text = [NSString stringWithFormat:@"%@", self.artist.name];
  artistNameLabel.textColor = self.bwTextColor;
  
  _notifyButton = (Button*)[self.navigationBar viewWithTag:2];
  [self.notifyButton addTarget:self
                        action:@selector(addToNotificationList)
              forControlEvents:UIControlEventTouchUpInside];
  
  UIButton *topOfPageButton = (UIButton*)[self.navigationBar viewWithTag:3];
  [topOfPageButton addTarget:self
                      action:@selector(topOfPage)
            forControlEvents:UIControlEventTouchUpInside];
  
  Button *backButton = (Button*)[self.navigationBar viewWithTag:4];
  [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
  
  if (self.isInNotificationList) {
    [self.notifyButton setTitle:@"  Remove from list  " forState:UIControlStateNormal];
  } else {
    [self.notifyButton setTitle:@"  Add to list  " forState:UIControlStateNormal];
  }
  
  _navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, _navigationBar.frame.size.height);
  _navigationBar.layer.shadowColor = [self.bwTextColor CGColor];
  _navigationBar.layer.shadowOpacity = 0.4;
  _navigationBar.layer.shadowRadius = 2.0;
  _navigationBar.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
  _navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:_navigationBar.bounds].CGPath;
  _navigationBar.backgroundColor = self.bwBackgroundColor;
  
  return _navigationBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 110;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0 ||
      (indexPath.row == 1 && self.hasPreOrder))  {
    return 230;
  }
  return 195;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.albumList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  Album *album = self.albumList[indexPath.row];
  NSString *name = album.title;
  
  if (self.hasPreOrder) {
    UITableViewCell *preOrderCell = [tableView dequeueReusableCellWithIdentifier:@"PreOrderCell" forIndexPath:indexPath];
    preOrderCell.backgroundColor = self.bwBackgroundColor;
    UILabel *nameLabel = (UILabel*)[preOrderCell.contentView viewWithTag:1];
    nameLabel.textColor = self.bwTextColor;
    nameLabel.text = name;
    UIImageView *albumImageView = (UIImageView*)[preOrderCell.contentView viewWithTag:2];
    [albumImageView hnk_setImageFromURL:album.artworkURL placeholder:[mStore imageWithColor:[UIColor clearColor]]];
    UILabel *trackNumLabel = (UILabel*)[preOrderCell.contentView viewWithTag:4];
    trackNumLabel.textColor = self.bwTextColor;
    if (album.userData) {
      if ([album.userData  isEqual:@1]) {
        trackNumLabel.text = @"1 track";
      } else {
        trackNumLabel.text = [NSString stringWithFormat:@"%@ tracks", album.userData];
      }
    } else {
      trackNumLabel.hidden = YES;
    }
    return preOrderCell;
  }
  
  if ((indexPath.row == 0 && !self.hasPreOrder) || (indexPath.row == 1 && self.hasPreOrder)) {
    UITableViewCell *latestReleaseCell = [tableView dequeueReusableCellWithIdentifier:@"LatestReleaseCell" forIndexPath:indexPath];
    latestReleaseCell.backgroundColor = self.bwBackgroundColor;
    UILabel *nameLabel = (UILabel*)[latestReleaseCell.contentView viewWithTag:1];
    nameLabel.textColor = self.bwTextColor;
    nameLabel.text = name;
    UIImageView *albumImageView = (UIImageView*)[latestReleaseCell.contentView viewWithTag:2];
    [albumImageView hnk_setImageFromURL:album.artworkURL placeholder:[mStore imageWithColor:[UIColor clearColor]]];
    UILabel *latestReleaseLabel = (UILabel*)[latestReleaseCell.contentView viewWithTag:3];
    latestReleaseLabel.textColor = self.bwTextColor;
    UILabel *trackNumLabel = (UILabel*)[latestReleaseCell.contentView viewWithTag:4];
    trackNumLabel.textColor = self.bwTextColor;
    if (album.userData) {
      if ([album.userData  isEqual:@1]) {
        trackNumLabel.text = @"1 track";
      } else {
        trackNumLabel.text = [NSString stringWithFormat:@"%@ tracks", album.userData];
      }
    } else {
      trackNumLabel.hidden = YES;
    }
    return latestReleaseCell;
  }
  
  UITableViewCell *albumCell = [tableView dequeueReusableCellWithIdentifier:@"AlbumCell" forIndexPath:indexPath];
  albumCell.backgroundColor = self.bwBackgroundColor;
  UILabel *nameLabel = (UILabel*)[albumCell.contentView viewWithTag:1];
  nameLabel.textColor = self.bwTextColor;
  nameLabel.text = name;
  UIImageView *albumImageView = (UIImageView*)[albumCell.contentView viewWithTag:2];
  [albumImageView hnk_setImageFromURL:album.artworkURL placeholder:[mStore imageWithColor:[UIColor clearColor]]];
  UILabel *trackNumLabel = (UILabel*)[albumCell.contentView viewWithTag:4];
  trackNumLabel.textColor = self.bwTextColor;
  if (album.userData) {
    if ([album.userData  isEqual:@1]) {
      trackNumLabel.text = @"1 track";
    } else {
      trackNumLabel.text = [NSString stringWithFormat:@"%@ tracks", album.userData];
    }
  } else {
    trackNumLabel.hidden = YES;
  }
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

#pragma mark NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
  
  dispatch_async(dispatch_get_main_queue(), ^{
    NSData *data = [NSData dataWithContentsOfURL:location];
    if (data) {
      NSError *error;
      NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingMutableContainers
                                                                   error:&error];
      
      [self parseAndAddAlbums:jsonObject[@"results"]];
    };
    
    data = nil;
  });
}

- (void)parseAndAddAlbums:(NSArray*)jsonArray {
  
  for (int i = 1; i < [jsonArray count]; i++) {
    NSDictionary *albumDictionary = [jsonArray objectAtIndex:i];
    NSString *name;
    NSString *buyURL;
    NSString *artworkURL;
    NSString *releaseDate;
    NSNumber *trackCount;
    for (int j = 0; j < [albumDictionary count]; j++) {
      NSString *nodeTitle = [albumDictionary allKeys][j];
      id nodeValue = [albumDictionary allValues][j];
      
      if ([nodeTitle isEqualToString:@"collectionCensoredName"]) {
        name = nodeValue;
      } else if ([nodeTitle isEqualToString:@"collectionViewUrl"]) {
        buyURL = nodeValue;
      } else if ([nodeTitle isEqualToString:@"artworkUrl100"]) {
        artworkURL = nodeValue;
      } else if ([nodeTitle isEqualToString:@"releaseDate"]) {
        releaseDate = nodeValue;
      } else if ([nodeTitle isEqualToString:@"trackCount"]) {
        trackCount = [NSNumber numberWithInt:[nodeValue intValue]];
      }
    }
    
    Album *newAlbum = [[Album alloc] initWithAlbumTitle:name
                                                 artist:self.artist.name
                                             artworkURL:artworkURL
                                               albumURL:buyURL
                                            releaseDate:releaseDate];
    newAlbum.userData = trackCount;
    if (!releaseDate || [mStore thisDate:[NSDate date] isMoreRecentThan:newAlbum.releaseDate]) {
      newAlbum.isPreOrder = YES;
    }
    
    if (!self.albumList) {
      self.albumList = [[NSMutableArray alloc] initWithCapacity:30];
    }
    
    [self.albumList addObject:newAlbum];
    name = nil;
    buyURL = nil;
    artworkURL = nil;
    releaseDate = nil;
  }
  
  if (self.albumList.count > 0) {
    if (self.albumList.count == 1 || !self.hasPreOrder) {
      self.artist.latestRelease = self.albumList.firstObject;
    } else {
      self.artist.latestRelease = self.albumList[1];
    }
  }
  
  [self.tableView reloadData];
}

#pragma mark NotificationList

- (void)addToNotificationList {
  
  if (!self.isInNotificationList) {
    [[ArtistList sharedList] addArtistToList:self.artist];
    [self.notifyButton setTitle:@"  Remove from list  " forState:UIControlStateNormal];
    self.isInNotificationList = YES;
  } else {
    [[ArtistList sharedList] removeArtist:self.artist];
    [self.notifyButton setTitle:@"  Add to list  " forState:UIControlStateNormal];
    self.isInNotificationList = NO;
  }
  
}

- (void)back:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)toiTunes:(NSIndexPath *)indexPath {
  // Initialize Product View Controller
  SKStoreProductViewController *storeProductViewController = [[SKStoreProductViewController alloc] init];
  Album *album = self.albumList[indexPath.row];
  
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

- (void)topOfPage {
  [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"appDidReceiveNotification" object:nil];
}

@end
