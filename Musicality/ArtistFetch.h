//
//  ArtistFetch.h
//  Musicality
//
//  Created by Elle Lewis on 1/11/16.
//  Copyright © 2016 Elle Lewis. All rights reserved.
//
// Fetches an array of albums for the specified artist

@import Foundation;
#import "Artist.h"

@protocol ArtistFetchDelegate;

@interface ArtistFetch : NSOperation

@property (nonatomic, weak) id<ArtistFetchDelegate> delegate;

- (instancetype)initWithDelegate:(id<ArtistFetchDelegate>) delegate;
- (void)fetchAlbumsForArtist:(Artist *)artist;

@end

@protocol ArtistFetchDelegate <NSObject>

- (void)didFinishFetchingArtistAlbums:(NSArray *)albums;

@end
