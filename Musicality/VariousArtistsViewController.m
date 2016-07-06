//
//  VariousArtistsViewController.m
//  Musicality
//
//  Created by Evan Lewis on 8/8/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

@import StoreKit;

#import "Artist.h"
#import "MStore.h"
#import "UserPrefs.h"
#import "ColorScheme.h"
#import "ArtistViewController.h"
#import "VariousArtistsNavigationBar.h"
#import "VariousArtistsViewController.h"

@interface VariousArtistsViewController() <SKStoreProductViewControllerDelegate, UIAlertViewDelegate, MViewControllerDelegate>

@property (nonatomic, weak) VariousArtistsNavigationBar *navigationBar;

@property (nonatomic) UIColor *bwTextColor;
@property (nonatomic) UIColor *bwBackgroundColor;

@property (nonatomic) NSNumber *alertViewActionID;
@property (nonatomic) UIAlertView *alertView;

@property (nonatomic) NSMutableArray *artistArray;

@end

@implementation VariousArtistsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //allows back swipe to work
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.clearsSelectionOnViewWillAppear = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewMovedToForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
    [self addArtistList];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Tab Bar customization
    UIImage *selectedImage = [[UIImage imageNamed:@"explore_selected_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.selectedImage = selectedImage;
    self.tabBarController.tabBar.barTintColor = [[ColorScheme sharedScheme] primaryColor];
    self.tabBarController.tabBar.tintColor = [[ColorScheme sharedScheme] secondaryColor];
    [self.tableView headerViewForSection:0];
    
    self.view.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
    [self.tableView reloadData];
    [self viewMovedToForeground];
}

#pragma mark - MViewController Delegate
- (void)viewMovedToForeground {
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

- (void)addArtistList {
    NSNumber *albumID = [NSNumber numberWithInt:[[mStore formattedAlbumIDFromURL:self.albumLink] intValue]];
    if (!albumID) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@&entity=song", albumID]]];
    if (!data) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    NSError *error;
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingMutableContainers
                                                                 error:&error];
    NSArray *jsonArray = jsonObject[@"results"];
    for (int i = 1; i < [jsonArray count]; i++) {
        NSDictionary *artistListDictionary = [jsonArray objectAtIndex:i];
        NSString *name;
        NSString *artistID;
        
        for (int j = 0; j < [artistListDictionary count]; j++) {
            NSString *nodeTitle = [artistListDictionary allKeys][j];
            id nodeValue = [artistListDictionary allValues][j];
            
            if ([nodeTitle isEqualToString:@"artistName"]) {
                name = nodeValue;
            } else if ([nodeTitle isEqualToString:@"artistId"]) {
                artistID = nodeValue;
            }
        }
        
        Artist *newArtist = [[Artist alloc] initWithArtistID:artistID andName:name];
        if (!self.artistArray) {
            _artistArray = [[NSMutableArray alloc] initWithCapacity:15];
        }
        
        if (![self artistIsInList:newArtist]) {
            [self.artistArray addObject:newArtist];
        }
        
        name = nil;
        artistID = nil;
    }
    
    [self.tableView reloadData];
}

- (BOOL)artistIsInList:(Artist*)artistToCheck {
    
    for (Artist *artist in self.artistArray) {
        if ([artistToCheck.name isEqualToString:artist.name]) {
            return YES;
        }
    }
    return NO;
    
}

#pragma mark Alert View

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

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //Add navigation bar to header
    _navigationBar = [[[NSBundle mainBundle] loadNibNamed:@"VariousArtistsNavigationBar" owner:self options:nil] objectAtIndex:0];
    _navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, self.navigationBar.frame.size.height);
    _navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.navigationBar.bounds].CGPath;
    [_navigationBar.backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *topOfPageButton = (UIButton*)[self.navigationBar viewWithTag:2];
    [topOfPageButton addTarget:self
                        action:@selector(topOfPage)
              forControlEvents:UIControlEventTouchUpInside];
    return _navigationBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 96;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.artistArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArtistNameCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.artistArray[indexPath.row] name];
    cell.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
    cell.textLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self toArtist:self.artistArray[indexPath.row]];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - Navigation

- (void)toArtist:(Artist*)sender {
    NSString *num = sender.artistID.stringValue;
    NSString *name = sender.name;
    if (num && name) {
        Artist *artist = [[Artist alloc] initWithArtistID:num andName:name];
        [self performSegueWithIdentifier:@"toArtist" sender:artist];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toArtist"]) {
        ArtistViewController *artistViewController = segue.destinationViewController;
        artistViewController.artist = sender;
    }
}

- (void)topOfPage {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
