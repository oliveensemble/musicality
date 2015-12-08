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
  
}

- (void)viewWillAppear:(BOOL)animated {
  
  [super viewWillAppear:animated];
  
  _libraryListArray = [mStore artistsFromUserLibrary];
  _selectedArtistsArray = [NSMutableArray array];
  
}

#pragma mark NSOperation Delegate

- (PendingOperations *)pendingOperations {
  if (!_pendingOperations) {
    _pendingOperations = [[PendingOperations alloc] init];
  }
  return _pendingOperations;
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
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    selectedCell.backgroundColor = [UIColor blackColor];
    selectedCell.textLabel.textColor = [UIColor whiteColor];
    [self.selectedArtistsArray addObject:self.libraryListArray[indexPath.row]];
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

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
  selectedCell.backgroundColor = [UIColor whiteColor];
  selectedCell.textLabel.textColor = [UIColor blackColor];
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
  } else {
    [self toArtistsList:self];
  }
}

- (void)artistSearchDidFinish:(ArtistSearch *)downloader {
  [[ArtistList sharedList] addArtistToList:downloader.artist];
  [self.pendingOperations.requestsInProgress removeObjectForKey:[NSString stringWithFormat:@"Artist Search for %@", downloader.artist.name]];
  if (self.pendingOperations.requestsInProgress.count == 0) {
    DLog(@"Finished");
    if (![[UserPrefs sharedPrefs] artistListNeedsUpdating]) {
      [[UserPrefs sharedPrefs] setArtistListNeedsUpdating:YES];
    }
    [self toArtistsList:self];
    [self.pendingOperations.requestQueue cancelAllOperations];
  }
}

- (void)toArtistsList:(id)sender {
  [self.navigationController popViewControllerAnimated:YES];
}

- (void)topOfPage {
  [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark Loading

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"toArtistsList" object:nil];
}

@end
