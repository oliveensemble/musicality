//
//  ArtistListViewController.h
//  Musicality
//
//  Created by Evan Lewis on 11/12/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import UIKit;

#import "PendingOperations.h"
#import "LatestReleaseSearch.h"

@interface ArtistListViewController : UITableViewController <LatestReleaseSearchDelegate>

@property (nonatomic, strong) PendingOperations *pendingOperations;

@end
