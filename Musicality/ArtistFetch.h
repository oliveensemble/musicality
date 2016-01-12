//
//  ArtistFetch.h
//  Musicality
//
//  Created by Evan Lewis on 1/11/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

@import Foundation;
#import "Artist.h"

@protocol ArtistFetchDelegate;

//Fetches an array of albums for the specified artist
@interface ArtistFetch : NSOperation

@property (nonatomic, weak) id<ArtistFetchDelegate> delegate;
@property (nonatomic) NSURL *url;
@property (nonatomic) NSMutableArray *albumArray;

- (instancetype)initWithArtist:(Artist*)url delegate:(id<ArtistFetchDelegate>) delegate;

@end

@protocol ArtistFetchDelegate <NSObject>

- (void)artistFetchDidFinish:(ArtistFetch*)downloader;

@end
