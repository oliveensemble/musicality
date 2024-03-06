//
//  LatestReleaseSearch.h
//  Musicality
//
//  Created by Elle Lewis on 5/26/15.
//  Copyright (c) 2015 Elle Lewis. All rights reserved.
//

@import Foundation;
#import "Artist.h"
#import "Album.h"

@protocol LatestReleaseSearchDelegate;

//Searches artist by id and fetches latest release date and album art, name (Album object)
@interface LatestReleaseSearch : NSOperation

@property (nonatomic, weak) id<LatestReleaseSearchDelegate> delegate;
@property (nonatomic, readonly, strong) Album *album;
@property (nonatomic, strong) Artist *artist;

- (instancetype)initWithArtist:(Artist*)artist delegate:(id<LatestReleaseSearchDelegate>)delegate;

@end

@protocol LatestReleaseSearchDelegate <NSObject>

- (void)latestReleaseSearchDidFinish:(LatestReleaseSearch *)downloader;

@end
