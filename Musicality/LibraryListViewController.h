//
//  LibraryListViewController.h
//  Musicality
//
//  Created by Elle Lewis on 11/27/14.
//  Copyright (c) 2014 Elle Lewis. All rights reserved.
//

@import UIKit;

#import "ArtistSearch.h"

@interface LibraryListViewController : UITableViewController <ArtistSearchDelegate>

@property (nonatomic, strong) NSMutableArray *selectedArtistsArray;

@end
