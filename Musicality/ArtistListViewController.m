//
//  ArtistListViewController.m
//  Musicality
//
//  Created by Elle Lewis on 11/12/14.
//  Copyright (c) 2014 Later Creative LLC. All rights reserved.
//

@import StoreKit;
@import SafariServices;
#import "ArtistListViewController.h"
#import "MViewControllerDelegate.h"
#import "ArtistListViewModel.h"
#import "ArtistsNavigationBar.h"
#import "LoadingView.h"
#import "AutoScan.h"
#import "ColorScheme.h"
#import "MStore.h"
#import "ArtistList.h"
#import "FilterTableViewCell.h"
#import "AlbumTableViewCell.h"
#import "UIImageView+Haneke.h"
#import "ArtistViewController.h"
#import "VariousArtistsViewController.h"
#import "NotificationManager.h"
#import "UserPrefs.h"

typedef NS_OPTIONS(NSUInteger, ViewState) {
    browse = 1 << 0,
    filterSelection = 1 << 1
};

typedef NS_OPTIONS(NSUInteger, FilterType) {
    latestReleases = 1 << 0,
    artists = 1 << 1,
    hidePreOrders = 1 << 2,
};

@interface ArtistListViewController () <SKStoreProductViewControllerDelegate, MViewControllerDelegate, ArtistListViewModelDelegate>

@property (weak, nonatomic) IBOutlet UIRefreshControl *refresh;

@property (nonatomic, weak) ArtistsNavigationBar *navigationBar;
@property (nonatomic) ArtistListViewModel *artistListViewModel;

@property (nonatomic) SKStoreProductViewController *storeViewController;

@property (nonatomic) NSMutableArray *tableViewArray;
@property (nonatomic) NSArray *filters;

@property (copy, nonatomic) NSString *currentFilterTitle;

@property (nonatomic) NSUInteger viewState;
@property (nonatomic) NSUInteger filterType;

@property (nonatomic) LoadingView *loadingBar;
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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishUpdatingList) name:@"autoScanFinished" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewMovedToForeground) name:UIApplicationDidBecomeActiveNotification object:nil];

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

    [[UserPrefs sharedPrefs] setArtistListNeedsUpdating: YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (self.isUpdating || [[AutoScan sharedScan] isScanning]) {
        [self beginLoading];
    }

    //Tab Bar customization
    UIImage *selectedImage = [[UIImage imageNamed:@"mic_selected_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.tabBarItem.selectedImage = selectedImage;
    self.tabBarController.tabBar.barTintColor = [[ColorScheme sharedScheme] primaryColor];
    self.tabBarController.tabBar.tintColor = [[ColorScheme sharedScheme] secondaryColor];
    [self.tableView headerViewForSection:1];

    self.view.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
    if (self.loadingBar) {
        self.loadingBar.viewLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
        self.loadingBar.progressLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
        self.loadingBar.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
    }

    [self.tableView reloadData];
    [self viewMovedToForeground];
}

#pragma mark - MViewController Delegate
- (void)viewMovedToForeground {
    if (self.storeViewController) {
        [self.storeViewController dismissViewControllerAnimated:NO completion:nil];
    }

    if ([[UserPrefs sharedPrefs] artistListNeedsUpdating]) {
        [[UserPrefs sharedPrefs] setArtistListNeedsUpdating:NO];
        _artistListViewModel = [[ArtistListViewModel alloc] initWithDelegate:self];
        [self.artistListViewModel beginUpdates];
    } else if ([[ArtistList sharedList] viewNeedsUpdates]) {
        [[ArtistList sharedList] setViewNeedsUpdates:NO];
        [self populate];
    }

    [self checkForNotification: [[NotificationManager sharedManager] localNotification]];
    self.refresh.tintColor = [[ColorScheme sharedScheme] secondaryColor];
}

- (void)checkForNotification:(UILocalNotification *)localNotification {
    if (localNotification) {
        DLog(@"Local Notification: %@", [[NotificationManager sharedManager] localNotification]);
        // Remove the local notification when we're finished with it so it doesn't get reused
        [[NotificationManager sharedManager] setLocalNotification:nil];
        [self loadStoreProductViewController:localNotification.userInfo];
    }
}

- (void)loadStoreProductViewController:(NSDictionary *)userInfo {
    NSNumber *albumID = userInfo[@"albumID"];
    if (!albumID) {
        return;
    }

    if ([[UserPrefs sharedPrefs] isAppleMusicEnabled]) {
        SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://geo.itunes.apple.com/us/album/id%@?app=music&at=1l3vuBC", albumID]]];
        [self presentViewController:safariVC animated:true completion:^{
            [self dismissViewControllerAnimated:true completion:nil];
        }];
    } else {
        // Initialize Product View Controller
        if ([SKStoreProductViewController class] != nil) {
            // Configure View Controller
            _storeViewController = [[SKStoreProductViewController alloc] init];
            [self.storeViewController setDelegate:self];
            NSDictionary *productParams = @{SKStoreProductParameterITunesItemIdentifier : albumID, SKStoreProductParameterAffiliateToken : mStore.affiliateToken};
            [self.storeViewController loadProductWithParameters:productParams completionBlock:^(BOOL result, NSError *error) {
                if (error) {
                    // handle the error
                    NSLog(@"%@",error.description);
                }
                [self presentViewController:self.storeViewController animated:YES completion:nil];
            }];
        }
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.storeViewController = nil;
}

#pragma mark NSOperation Methods

- (void)didUpdateList:(NSDictionary *)statusInfo {
    self.isUpdating = YES;

    if (self.loadingBar == nil) {
        [self beginLoading];
    }
    CGRect frame = CGRectMake(self.loadingBar.frame.origin.x, self.loadingBar.frame.origin.y, self.loadingBar.frame.size.width, 40);
    self.loadingBar.frame = frame;
    self.loadingBar.viewLabel.text = statusInfo[@"updateStatus"];
    self.loadingBar.progressLabel.text = [NSString stringWithFormat:@"%@%%", statusInfo[@"updateProgress"]];
}

- (void)didFinishUpdatingList {
    [self refresh:self];
    [self populate];
    [self endLoading];
}

- (void)populate {
    if (self.viewState == filterSelection) {
        [self toggleFilterSelection:^(bool finished) {
            nil;
        }];
    }

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
        // Sort by release date
        NSArray *sortedArray;
        sortedArray = [albumsArray sortedArrayUsingComparator:^NSComparisonResult(Album *a, Album *b) {
            return [a.releaseDate compare:b.releaseDate];
        }];
        return [[[sortedArray reverseObjectEnumerator] allObjects] mutableCopy];
    } else if (self.filterType == artists) {
        // Sort alphabetically
        NSArray *sortedArray;
        sortedArray = [albumsArray sortedArrayUsingComparator:^NSComparisonResult(Album *a, Album *b) {
            return [a.artist compare:b.artist];
        }];
        return [sortedArray mutableCopy];
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
    [_navigationBar.topOfPageButton addTarget:self action:@selector(topOfPage) forControlEvents:UIControlEventTouchUpInside];

    return _navigationBar;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 126;
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
        NSDictionary *userInfo = @{@"AlbumURL" : album.URL, @"Artist" : album.artist, @"ArtistID" : album.artistID, @"albumID" : [mStore formattedAlbumIDFromURL:album.URL]};
        albumCell.viewArtistButton.buttonInfo = userInfo;
        albumCell.cellInfo = userInfo;

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
        [self loadStoreProductViewController: albumCell.cellInfo];
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

- (IBAction)refresh:(id)sender {
    // If the user pulls down to refresh, start refreshing
    if ([sender isKindOfClass:[UIRefreshControl class]]) {

        if (self.isUpdating) {
            [self.refresh endRefreshing];
        }

        if (!self.artistListViewModel) {
            _artistListViewModel = [[ArtistListViewModel alloc] initWithDelegate:self];
        }

        [self.artistListViewModel beginUpdates];
    } else {
        // If the VC calls the method, end refreshing
        [self.refresh endRefreshing];
    }
}

- (void)topOfPage {
    if (self.tableViewArray.count > 5) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

#pragma mark Navigation

- (void)beginLoading {
    if (!self.isUpdating || !self.loadingBar) {
        self.isUpdating = YES;
        CGRect frame = CGRectMake(0, (self.view.bounds.size.height - self.tabBarController.tabBar.bounds.size.height) - 40, self.view.bounds.size.width, 40);
        frame.origin.y = ([[UIScreen mainScreen] bounds].size.height - self.tabBarController.tabBar.bounds.size.height) - 40;
        _loadingBar = [[[NSBundle mainBundle] loadNibNamed:@"LoadingView" owner:self options:nil] firstObject];
        _loadingBar.frame = frame;
        [self.view addSubview:self.loadingBar];
        [self.view bringSubviewToFront:self.loadingBar];
    }
}

- (void)endLoading {
    self.isUpdating = NO;
    [self.loadingBar removeFromSuperview];
    self.loadingBar = nil;
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

- (IBAction)didExitLibraryList:(UIStoryboardSegue *)unwindSegue {
    if (!self.artistListViewModel) {
        _artistListViewModel = [[ArtistListViewModel alloc] initWithDelegate: self];
    }

    [self.artistListViewModel beginUpdates];
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect frame = self.loadingBar.frame;
    frame.origin.y = scrollView.contentOffset.y + self.tableView.frame.size.height - self.loadingBar.frame.size.height;
    frame.size.height = 40;
    self.loadingBar.frame = frame;
    [self.view bringSubviewToFront:self.loadingBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.refresh endRefreshing];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"autoScanFinished" object:nil];
}

@end
