//
//  LibraryListViewController.h
//  Musicality
//
//  Created by Evan Lewis on 11/27/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import UIKit;

#import "PendingOperations.h"
#import "ArtistSearch.h"

@interface LibraryListViewController : UITableViewController <ArtistSearchDelegate>

@property (nonatomic, strong) PendingOperations *pendingOperations;

@end
