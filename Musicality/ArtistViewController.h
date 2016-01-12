//
//  ArtistViewController.h
//  Musicality
//
//  Created by Evan Lewis on 11/24/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import UIKit;
#import "Artist.h"
#import "ArtistFetch.h"
#import "PendingOperations.h"

@interface ArtistViewController : UITableViewController

@property (nonatomic, strong) Artist *artist;
@property (nonatomic, strong) PendingOperations *pendingOperations;

@end
