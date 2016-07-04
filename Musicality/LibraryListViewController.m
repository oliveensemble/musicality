//
//  LibraryListViewController.m
//  Musicality
//
//  Created by Evan Lewis on 11/27/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import StoreKit;
#import "Artist.h"
#import "Button.h"
#import "MStore.h"
#import "Blacklist.h"
#import "UserPrefs.h"
#import "ArtistList.h"
#import "LoadingView.h"
#import "ColorScheme.h"
#import "LibraryNavigationBar.h"
#import "LibraryListViewController.h"

//The different states the view can be in; either selecting a genre or scrolling through albums
typedef NS_OPTIONS(NSUInteger, ViewState) {
    browse = 1 << 0,
    loading = 1 << 1
};

@interface LibraryListViewController () <MViewControllerDelegate, SKStoreProductViewControllerDelegate>

@property (nonatomic, weak) LibraryNavigationBar *navigationBar;
@property (nonatomic) NSArray *libraryListArray;

@property (nonatomic) NSUInteger viewState;
@property (nonatomic) LoadingView *loadingBar;


@end

@implementation LibraryListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewMovedToForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
    //Allows swipe back to function
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    //Register TableView cells
    [self.tableView registerNib:[UINib nibWithNibName:@"FilterTableViewCell" bundle:nil] forCellReuseIdentifier:@"filterCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"AlbumTableViewCell" bundle:nil]forCellReuseIdentifier:@"albumCell"];
    
    self.viewState = browse;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Tab Bar customization
    UIImage *selectedImage = [[UIImage imageNamed:@"mic_selected_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.selectedImage = selectedImage;
    self.tabBarController.tabBar.barTintColor = [[ColorScheme sharedScheme] primaryColor];
    self.tabBarController.tabBar.tintColor = [[ColorScheme sharedScheme] secondaryColor];
    [self.tableView headerViewForSection:1];
    
    self.view.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
    
    _libraryListArray = [mStore artistsFromUserLibrary];
    _selectedArtistsArray = [NSMutableArray array];
    self.tableView.tintColor = [[ColorScheme sharedScheme] secondaryColor];
    [self.tableView reloadData];
    [self viewMovedToForeground];
}

#pragma mark - MViewController Delegate
- (void)viewMovedToForeground {
    DLog(@"Moved to foreground");
    [self checkForNotification: mStore.localNotification];
}

- (void)checkForNotification:(UILocalNotification *)localNotification {
    if (localNotification) {
        DLog(@"Local Notification: %@", mStore.localNotification);
        // Remove the local notification when we're finished with it so it doesn't get reused
        [mStore setLocalNotification:nil];
        [self loadStoreProductViewController:localNotification.userInfo];
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
    return 96;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.libraryListArray.count;
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
    
    if ([self.selectedArtistsArray containsObject: self.libraryListArray[indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
    cell.textLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
    cell.detailTextLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
    cell.accessoryView.tintColor = [[ColorScheme sharedScheme] secondaryColor];
    cell.tintColor = [[ColorScheme sharedScheme] secondaryColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArtistCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ArtistCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.libraryListArray[indexPath.row] name]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.viewState == browse) {
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedArtistsArray addObject:self.libraryListArray[indexPath.row]];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    selectedCell.accessoryType = UITableViewCellAccessoryNone;
    [self.selectedArtistsArray removeObjectIdenticalTo:self.libraryListArray[indexPath.row]];
}

#pragma mark Artist Search

- (void)searchArtists {
    [self beginLoading];
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
            [[[ArtistScanPendingOperations sharedOperations] artistRequestsInProgress] setObject:artistSearch forKey:[NSString stringWithFormat:@"Updating %@", artist.name]];
            [[[ArtistScanPendingOperations sharedOperations] artistRequestQueue] addOperation:artistSearch];
        }
        [[ArtistScanPendingOperations sharedOperations] beginOperations];
    } else {
        [self endLoading];
        [self performSegueWithIdentifier:@"exitToArtistList" sender:self];
    }
}

- (void)artistSearchDidFinish:(ArtistSearch *)downloader {
    [[ArtistList sharedList] addArtistToList:downloader.artist];
    [[[ArtistScanPendingOperations sharedOperations] artistRequestsInProgress] removeObjectForKey:[NSString stringWithFormat:@"Updating %@", downloader.artist.name]];
    [[ArtistScanPendingOperations sharedOperations] updateProgress: [NSString stringWithFormat:@"Updating %@", downloader.artist.name]];
    self.loadingBar.progressLabel.text = [NSString stringWithFormat:@"%i%%", (int)[[ArtistScanPendingOperations sharedOperations] currentProgress]];
    
    if ([[[ArtistScanPendingOperations sharedOperations] artistRequestsInProgress] count] == 0) {
        DLog(@"Finished");
        if (![[UserPrefs sharedPrefs] artistListNeedsUpdating]) {
            [[UserPrefs sharedPrefs] setArtistListNeedsUpdating:YES];
        }
        [[ArtistList sharedList] saveChanges];
        [[[ArtistScanPendingOperations sharedOperations] artistRequestQueue] cancelAllOperations];
        [self performSegueWithIdentifier:@"exitToArtistList" sender:self];
    }
}

- (void)toArtistsList:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)topOfPage {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark Loading

- (void)beginLoading {
    if (self.viewState == browse) {
        self.viewState = loading;
        CGRect frame = CGRectMake(0, (self.view.bounds.size.height - self.tabBarController.tabBar.bounds.size.height) - 40, self.view.bounds.size.width, 40);
        frame.origin.y = self.tableView.contentOffset.y + self.tableView.frame.size.height - 40;
        [self.view bringSubviewToFront:self.loadingBar];
        _loadingBar = [[[NSBundle mainBundle] loadNibNamed:@"LoadingView" owner:self options:nil] firstObject];
        _loadingBar.frame = frame;
        [self.view addSubview:self.loadingBar];
    }
}

- (void)endLoading {
    if (self.viewState == loading) {
        self.viewState = browse;
        [self.loadingBar removeFromSuperview];
        self.loadingBar = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
