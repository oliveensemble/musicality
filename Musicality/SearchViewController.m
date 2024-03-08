//
//  SearchViewController.m
//  Musicality
//
//  Created by Elle Lewis on 7/18/16.
//  Copyright © 2016 Later Creative LLC. All rights reserved.
//

@import StoreKit;
@import SafariServices;
#import "SearchViewController.h"
#import "MViewControllerDelegate.h"
#import "MTextField.h"
#import "SearchNavigationBar.h"
#import "ColorScheme.h"
#import "MStore.h"
#import "SearchArtistTableViewCell.h"
#import "Artist.h"
#import "SearchAlbumTableViewCell.h"
//#import "UIImageView+Haneke.h"
#import "ArtistViewController.h"
#import "VariousArtistsViewController.h"
#import "SearchFetch.h"
#import "NotificationManager.h"
#import "UserPrefs.h"

typedef NS_OPTIONS(NSUInteger, SearchType) {
    artists = 1 << 0,
    albums = 1 << 1
};

typedef NS_OPTIONS(NSUInteger, ViewState) {
    loading = 1 << 0,
    browsing = 1 << 1
};

@interface SearchViewController () <MViewControllerDelegate, SearchFetchDelegate, UITextFieldDelegate, SKStoreProductViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSUInteger viewState;
@property (nonatomic) NSUInteger searchType;

@property (weak, nonatomic) IBOutlet MTextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *tableViewArray;

@property (nonatomic, weak) SearchNavigationBar *navigationBar;

@property (nonatomic) SKStoreProductViewController *storeViewController;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SearchViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    //Allows swipe back to functiondidReceiveNotification
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    //Register notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewMovedToForeground) name:UIApplicationDidBecomeActiveNotification object:nil];

    _searchType = artists;

    self.viewState = browsing;
    [self.activityIndicator stopAnimating];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //Tab Bar customization
    self.tabBarController.tabBar.barTintColor = [[ColorScheme sharedScheme] primaryColor];
    self.tabBarController.tabBar.tintColor = [[ColorScheme sharedScheme] secondaryColor];
    [self.tableView headerViewForSection:2];

    self.view.backgroundColor = [[ColorScheme sharedScheme] primaryColor];

    [self.tableView reloadData];
    [self viewMovedToForeground];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.activityIndicator stopAnimating];
}

#pragma mark - MViewController Delegate
- (void)viewMovedToForeground {
    // If there was a store view already open when the user returns to this view, close it
    if (self.storeViewController) {
        [self.storeViewController dismissViewControllerAnimated:NO completion:nil];
    }

    if (!self.navigationBar) {
        _navigationBar = [[[NSBundle mainBundle] loadNibNamed:@"SearchNavigationBar" owner:self options:nil] objectAtIndex:0];
        _navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationBar.frame.size.height);
        _navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.navigationBar.bounds].CGPath;
        [_navigationBar.artistsButton addTarget:self action:@selector(switchToArtistsSearch:) forControlEvents:UIControlEventTouchUpInside];
        [_navigationBar.albumsButton addTarget:self action:@selector(switchToAlbumsSearch:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.navigationBar];
    }

    [self.navigationBar configureView];

    // Create Navigation Bar and set its bounds
    if (self.searchType == artists) {
        [self.navigationBar.artistsButton setSelectedStyle];
        [self.navigationBar.albumsButton setDeselectedStyle];
    } else {
        [self.navigationBar.albumsButton setSelectedStyle];
        [self.navigationBar.artistsButton setDeselectedStyle];
    }

    self.activityIndicator.color = [[ColorScheme sharedScheme] secondaryColor];
    if (self.viewState == loading) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }

    [self.searchTextField setColorButtonClearNormal:[[ColorScheme sharedScheme] secondaryColor]];
    [self.searchTextField setColorButtonClearHighlighted:[[ColorScheme sharedScheme] primaryColor]];
    [self.searchTextField layoutSubviews];
    self.searchTextField.textColor = [[ColorScheme sharedScheme] secondaryColor];
    self.searchTextField.tintColor = [[ColorScheme sharedScheme] secondaryColor];
    [self underlineTextField];

    [self checkForNotification: [[NotificationManager sharedManager] localNotification]];
}

- (void)checkForNotification:(UILocalNotification *)localNotification {
    if (localNotification) {
        DLog(@"Local Notification: %@", [[NotificationManager sharedManager] localNotification]);
        // Remove the local notification when we're finished with it so it doesn't get reused
        [[NotificationManager sharedManager] setLocalNotification:nil];
        DLog(@"Not background, calling toiTunes");
        [self loadStoreProductViewController:localNotification.userInfo];
    }
}

#pragma mark - TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (![textField.text isEqualToString:@""] || ![textField.text isEqualToString:@" "]) {
        DLog(@"Searching");
        [self.activityIndicator startAnimating];
        self.viewState = loading;
        SearchFetch *searchFetch = [[SearchFetch alloc] initWithDelegate:self];
        [searchFetch fetchItemsForSearchTerm:textField.text withType:self.searchType];
    }
    return [textField resignFirstResponder];
}

- (void)underlineTextField {
    CGRect layerFrame = CGRectMake(0, 0, self.searchTextField.frame.size.width, self.searchTextField.frame.size.height + 1);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, layerFrame.size.height);
    CGPathAddLineToPoint(path, NULL, layerFrame.size.width, layerFrame.size.height); // bottom line
    CAShapeLayer * line = [CAShapeLayer layer];
    line.path = path;
    line.lineWidth = 5;
    line.frame = layerFrame;
    line.strokeColor = [[ColorScheme sharedScheme] secondaryColor].CGColor;
    [self.searchTextField.layer addSublayer:line];
}

#pragma mark - SearchViewModelDelegate
- (void)didFinishSearchWithResults:(NSArray *)searchResults {
    DLog(@"Finished search");
    if (!self.tableViewArray) {
        _tableViewArray = [NSMutableArray arrayWithCapacity:50];
    }

    if (searchResults.count > 0) {
        [self.tableView beginUpdates];
        [self.tableViewArray removeAllObjects];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        //Add the items to the table view array
        [self.tableViewArray addObjectsFromArray: searchResults];

        NSMutableArray *indexPaths = [NSMutableArray array];
        //Then add the required number of index paths
        for (int i = 0; i < searchResults.count; i++) {
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:i inSection:0];
            [indexPaths addObject:indexpath];
        }
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }
    [self.tableView reloadData];
    [self.activityIndicator stopAnimating];
    self.viewState = browsing;
}

#pragma mark - SKStoreProductViewControllerDelegate
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
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchType == artists) {
        return 44;
    } else {
        return 80;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.searchType == artists) {
        SearchArtistTableViewCell *searchArtistTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"ArtistCell" forIndexPath:indexPath];
        // Check if the items in the tableview are artist objects
        if ([self.tableViewArray[indexPath.row] isKindOfClass:[Artist class]]) {
            Artist *artist = self.tableViewArray[indexPath.row];
            searchArtistTableViewCell.artistLabel.text = artist.name;
            //Add user info to cell and button
            NSDictionary *userInfo = @{@"Artist" : artist.name, @"ArtistID" : artist.artistID};
            searchArtistTableViewCell.cellInfo = userInfo;
        }
        return searchArtistTableViewCell;
    }

    SearchAlbumTableViewCell *searchAlbumTableViewCell = [tableView dequeueReusableCellWithIdentifier:@"AlbumCell" forIndexPath:indexPath];
    // Check if the items in the tableview are album objects
    if ([self.tableViewArray[indexPath.row] isKindOfClass:[Album class]]) {
        Album *album = self.tableViewArray[indexPath.row];
        searchAlbumTableViewCell.albumLabel.text = album.title;
        searchAlbumTableViewCell.artistLabel.text = album.artist;
//        [searchAlbumTableViewCell.albumImageView hnk_setImageFromURL:album.artworkURL placeholder:[mStore imageWithColor:[UIColor clearColor]]];
        [searchAlbumTableViewCell.viewArtistButton addTarget:self action:@selector(viewArtistButtonTapped:) forControlEvents:UIControlEventTouchUpInside];

        if ([album.artistID isEqual: @0]) {
            [searchAlbumTableViewCell.viewArtistButton setTitle:@"View Artists" forState:UIControlStateNormal];
            [searchAlbumTableViewCell.viewArtistButton setTitle:@"View Artists" forState:UIControlStateHighlighted];
        } else {
            [searchAlbumTableViewCell.viewArtistButton setTitle:@"View Artist" forState:UIControlStateNormal];
            [searchAlbumTableViewCell.viewArtistButton setTitle:@"View Artist" forState:UIControlStateHighlighted];
        }

        //Add user info to cell and button
        NSDictionary *userInfo = @{@"AlbumURL" : album.URL, @"Artist" : album.artist, @"ArtistID" : album.artistID, @"albumID" : [mStore formattedAlbumIDFromURL:album.URL]};
        searchAlbumTableViewCell.viewArtistButton.buttonInfo = userInfo;
        searchAlbumTableViewCell.cellInfo = userInfo;

        //Gesture recognizer
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showActionSheet:)];
        longPress.minimumPressDuration = 0.5;
        [searchAlbumTableViewCell addGestureRecognizer:longPress];
    }
    return searchAlbumTableViewCell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.viewState == loading) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }

    if (self.searchType == artists) {
        SearchArtistTableViewCell *artistCell = [tableView cellForRowAtIndexPath:indexPath];
        [self viewArtistButtonTapped: artistCell.cellInfo];
    } else {
        SearchAlbumTableViewCell *albumCell = [tableView cellForRowAtIndexPath:indexPath];
        [self loadStoreProductViewController: albumCell.cellInfo];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation
- (void)switchToArtistsSearch:(Button *)sender {
    self.searchType = artists;
    [self.navigationBar.artistsButton setSelectedStyle];
    [self.navigationBar.albumsButton setDeselectedStyle];
    [self.tableViewArray removeAllObjects];
    [self.tableView reloadData];
    [self.searchTextField becomeFirstResponder];
}

- (void)switchToAlbumsSearch:(Button *)sender {
    self.searchType = albums;
    [self.navigationBar.albumsButton setSelectedStyle];
    [self.navigationBar.artistsButton setDeselectedStyle];
    [self.tableViewArray removeAllObjects];
    [self.tableView reloadData];
    [self.searchTextField becomeFirstResponder];
}

- (void)viewArtistButtonTapped:(id)sender {
    NSDictionary *userInfo;
    if ([sender isKindOfClass:[Button class]]) {
        Button *button = (Button *)sender;
        userInfo = button.buttonInfo;
    } else if ([sender isKindOfClass:[NSDictionary class]]) {
        NSDictionary *senderInfo = (NSDictionary *)sender;
        userInfo = senderInfo;
    }

    if (![userInfo[@"ArtistID"] isEqual: @0]) {
        Artist *artist = [[Artist alloc] initWithArtistID:userInfo[@"ArtistID"] andName:userInfo[@"Artist"]];
        [self performSegueWithIdentifier:@"toArtist" sender:artist];
    } else if (userInfo[@"AlbumURL"] != nil) {
        [self performSegueWithIdentifier:@"toVariousArtists" sender:userInfo[@"AlbumURL"]];
    }
}

- (void)showActionSheet:(id)sender {
    UILongPressGestureRecognizer *longPress = sender;

    if (longPress.state == UIGestureRecognizerStateBegan) {
        SearchAlbumTableViewCell *albumCell = (SearchAlbumTableViewCell *)longPress.view;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toArtist"]) {
        ArtistViewController *artistVC = segue.destinationViewController;
        artistVC.artist = sender;
    } else if ([segue.identifier isEqualToString:@"toVariousArtists"]) {
        VariousArtistsViewController *variousArtistsVC = segue.destinationViewController;
        variousArtistsVC.albumLink = sender;
    }
}

@end
