//
//  AutoScan.h
//  Musicality
//
//  Created by Evan Lewis on 6/20/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

@import Foundation;

#import "ArtistSearch.h"
#import "PendingOperations.h"

@interface AutoScan : NSObject <ArtistSearchDelegate>

+ (instancetype)sharedScan;

- (void)startScan;
- (void)stopScan;

@property BOOL isScanning;

@end
