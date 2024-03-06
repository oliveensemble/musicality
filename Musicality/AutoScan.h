//
//  AutoScan.h
//  Musicality
//
//  Created by Elle Lewis on 6/20/15.
//  Copyright (c) 2015 Later Creative LLC. All rights reserved.
//

@import Foundation;

#import "ArtistSearch.h"

@interface AutoScan : NSObject <ArtistSearchDelegate>

+ (instancetype)sharedScan;

- (void)startScan;
- (void)stopScan;

@property BOOL isScanning;

@end
