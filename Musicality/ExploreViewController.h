//
//  ExploreViewController.h
//  Musicality
//
//  Created by Evan Lewis on 10/14/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import UIKit;

#import "ExploreFetch.h"
#import "PendingOperations.h"
#import "MTableViewController.h"

@interface ExploreViewController : MTableViewController

@property (nonatomic, strong) PendingOperations *pendingOperations;

@end
