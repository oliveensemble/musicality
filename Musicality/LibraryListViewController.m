//
//  LibraryListViewController.m
//  Musicality
//
//  Created by Evan Lewis on 11/27/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

#import "Artist.h"
#import "Button.h"
#import "MStore.h"
#import "Blacklist.h"
#import "UserPrefs.h"
#import "ArtistList.h"
#import "LibraryNavigationBar.h"
#import "LibraryListViewController.h"

@interface LibraryListViewController ()

@property (nonatomic, weak) LibraryNavigationBar *navigationBar;
@property (nonatomic) NSArray *libraryListArray;
@property (nonatomic) NSMutableArray *selectedArtistsArray;

@end

@implementation LibraryListViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.navigationController.navigationBarHidden = YES;
  self.navigationController.interactivePopGestureRecognizer.delegate = nil;
  NSMutableOrderedSet *artistList = [NSMutableOrderedSet orderedSetWithArray:[mStore artistsFromUserLibrary]];
  _libraryListArray = [artistList array];
  artistList = nil;
}

- (PendingOperations *)pendingOperations {
  if (!_pendingOperations) {
    _pendingOperations = [[PendingOperations alloc] init];
  }
  return _pendingOperations;
}

- (void)viewWillAppear:(BOOL)animated {
  
  [super viewWillAppear:animated];
  
  //Tab Bar customization
  UIImage *selectedImage = [[UIImage imageNamed:@"mic_selected_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
  self.tabBarItem.selectedImage = selectedImage;
  self.tabBarController.tabBar.barTintColor = [UIColor whiteColor];
  self.tabBarController.tabBar.tintColor = [UIColor blackColor];
  
  _selectedArtistsArray = [NSMutableArray array];
  
}

#pragma mark Table View Data

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  
  //Add navigation bar to header
  _navigationBar = [[[NSBundle mainBundle] loadNibNamed:@"LibraryNavigationBar" owner:self options:nil] objectAtIndex:0];
  _navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, _navigationBar.frame.size.height);
  _navigationBar.layer.shadowOpacity = 0.4;
  _navigationBar.layer.shadowRadius = 2.0;
  _navigationBar.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
  _navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:_navigationBar.bounds].CGPath;
  Button *cancelButton = (Button*)[self.navigationBar viewWithTag:1];
  [cancelButton addTarget:self
                   action:@selector(toArtistsList:)
         forControlEvents:UIControlEventTouchUpInside];
  
  Button *addArtistsButton = (Button*)[self.navigationBar viewWithTag:2];
  [addArtistsButton addTarget:self
                       action:@selector(searchArtists)
             forControlEvents:UIControlEventTouchUpInside];
  
  UIButton *topOfPageButton = (UIButton*)[self.navigationBar viewWithTag:3];
  [topOfPageButton addTarget:self
                      action:@selector(topOfPage)
            forControlEvents:UIControlEventTouchUpInside];
  
  return _navigationBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // Return the number of rows in the section.
  return self.libraryListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArtistCell" forIndexPath:indexPath];
  cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.libraryListArray[indexPath.row] name]];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  //[tableView deselectRowAtIndexPath:indexPath animated:NO];
  UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
  if (!self.selectedArtistsArray) {
    _selectedArtistsArray = [NSMutableArray array];
  }
  if (self.selectedArtistsArray.count == 0) {
    selectedCell.backgroundColor = self.bwTextColor;
    selectedCell.textLabel.textColor = self.bwBackgroundColor;
    selectedCell.textLabel.backgroundColor = [UIColor clearColor];
    [self.selectedArtistsArray addObject:self.libraryListArray[indexPath.row]];
    return;
  } else {
    for (int i = 0; i < self.selectedArtistsArray.count; i++) {
      NSString *artistInArray = self.selectedArtistsArray[i];
      if ([selectedCell.textLabel.text isEqualToString:artistInArray]) {
        return;
      }
    }
  }
  
  selectedCell.backgroundColor = self.bwTextColor;
  selectedCell.textLabel.textColor = self.bwBackgroundColor;
  selectedCell.textLabel.backgroundColor = [UIColor clearColor];
  [self.selectedArtistsArray addObject:self.libraryListArray[indexPath.row]];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  
  if (cell.isSelected == YES) {
    cell.backgroundColor = self.bwTextColor;
    cell.textLabel.textColor = self.bwBackgroundColor;
  } else {
    cell.backgroundColor = self.bwBackgroundColor;
    cell.textLabel.textColor = self.bwTextColor;
  }
  
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

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
  selectedCell.backgroundColor = self.bwBackgroundColor;
  selectedCell.textLabel.textColor = self.bwTextColor;
  [self.selectedArtistsArray removeObjectIdenticalTo:self.libraryListArray[indexPath.row]];
}

#pragma mark Artist Search

- (void)searchArtists {
  NSMutableArray *itemsToRemove = [NSMutableArray array];
  for(Artist* artist in self.selectedArtistsArray) {
    if ([[ArtistList sharedList] isInList:artist]) {
      [itemsToRemove addObject:artist];
    } else {
      if ([[Blacklist sharedList] isInList:artist]) {
        [[Blacklist sharedList] removeArtist:artist];
      }
    }
  }
  [self.selectedArtistsArray removeObjectsInArray:itemsToRemove];
  [[Blacklist sharedList] saveChanges];
  
  if (self.selectedArtistsArray.count > 0) {
    for (Artist *artist in self.selectedArtistsArray) {
      ArtistSearch *artistSearch = [[ArtistSearch alloc] initWithArtist:artist delegate:self];
      [self.pendingOperations.requestsInProgress setObject:artistSearch forKey:[NSString stringWithFormat:@"Artist Search for %@", artist.name]];
      [self.pendingOperations.requestQueue addOperation:artistSearch];
    }
    [self beginLoading];
  } else {
    [self toArtistsList:self];
  }
}

- (void)artistSearchDidFinish:(ArtistSearch *)downloader {
  [[ArtistList sharedList] addArtistToList:downloader.artist];
  [self.pendingOperations.requestsInProgress removeObjectForKey:[NSString stringWithFormat:@"Artist Search for %@", downloader.artist.name]];
  self.loadingView.viewLabel.text = [NSString stringWithFormat:@"Checking %@", downloader.artist.name];
  if (self.pendingOperations.requestsInProgress.count == 0) {
    DLog(@"Finished");
    if (![[UserPrefs sharedPrefs] artistListNeedsUpdating]) {
      [[UserPrefs sharedPrefs] setArtistListNeedsUpdating:YES];
    }
    [self endLoading];
    [self toArtistsList:self];
    [self.pendingOperations.requestQueue cancelAllOperations];
  }
}

- (void)toArtistsList:(id)sender {
  if (![[sender class] isSubclassOfClass:[Button class]]) {
    [self endLoading];
  }
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)topOfPage {
  [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
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
    self.loadingView.viewLabel.text = @"Checking Artists";
    [self.view addSubview:self.loadingView];
  }
}

- (void)endLoading {
  [self.loadingView removeFromSuperview];
  self.loadingView = nil;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"toArtistsList" object:nil];
}

@end
