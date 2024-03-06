//
//  ArtistSearch.h
//  Musicality
//
//  Created by Elle Lewis on 5/25/15.
//  Copyright (c) 2015 Elle Lewis. All rights reserved.
//

@import Foundation;
#import "Artist.h"

@protocol ArtistSearchDelegate;

//Searches (by string) for the artist and performs the requested operation after a new artist object is created. It only checks by string because on init, the initializer takes in an array of artist objects, but all fields are nil besides name
@interface ArtistSearch : NSOperation

@property (nonatomic, weak) id<ArtistSearchDelegate> delegate;
@property (nonatomic, readonly, strong) Artist *artist;

- (instancetype)initWithArtist:(Artist*)artist delegate:(id<ArtistSearchDelegate>) delegate;

@end

@protocol ArtistSearchDelegate <NSObject>

- (void)artistSearchDidFinish:(ArtistSearch *)downloader;

@end
