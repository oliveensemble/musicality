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
#import "ArtistViewController.h"
#import "VariousArtistsNavigationBar.h"
#import "VariousArtistsViewController.h"

@interface VariousArtistsViewController() <SKStoreProductViewControllerDelegate, UIAlertViewDelegate>

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"appDidReceiveNotification" object:nil];
    [self addArtistList];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self configureView];
    [self.navigationBar configureView];
    
    //Tab Bar customization
    UIImage *selectedImage = [[UIImage imageNamed:@"explore_selected_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.tabBarItem.selectedImage = selectedImage;
    self.tabBarController.tabBar.barTintColor = [UIColor whiteColor];
    self.tabBarController.tabBar.tintColor = [UIColor blackColor];
    
    [self.tableView headerViewForSection:0];
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    //Add navigation bar to header
    _navigationBar = [[[NSBundle mainBundle] loadNibNamed:@"VariousArtistsNavigationBar" owner:self options:nil] objectAtIndex:0];
    _navigationBar.frame = CGRectMake(0, 0, self.view.frame.size.width, _navigationBar.frame.size.height);
    _navigationBar.backgroundColor = self.bwBackgroundColor;
    _navigationBar.layer.shadowColor = [self.bwTextColor CGColor];
    _navigationBar.layer.shadowOpacity = 0.4;
    _navigationBar.layer.shadowRadius = 2.0;
    _navigationBar.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    _navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:_navigationBar.bounds].CGPath;
    
    _navigationBar.variousArtistsLabel.textColor = self.bwTextColor;
    [_navigationBar.backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    [_navigationBar.backButton addTarget:self
                                  action:@selector(topOfPage)
                        forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *topOfPageButton = (UIButton*)[self.navigationBar viewWithTag:2];
    [topOfPageButton addTarget:self
                        action:@selector(topOfPage)
              forControlEvents:UIControlEventTouchUpInside];
    
    return _navigationBar;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 110;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.artistArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArtistNameCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.artistArray[indexPath.row] name];
    cell.backgroundColor = self.bwBackgroundColor;
    cell.textLabel.textColor = self.bwTextColor;
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"appDidReceiveNotification" object:nil];
}

@end
