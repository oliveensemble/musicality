//
//  ArtistViewModel.h
//  Musicality
//
//  Created by Evan Lewis on 6/29/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

@import Foundation;
#import "Artist.h"
#import "ArtistFetch.h"

@protocol ArtistViewModelDelegate;

@interface ArtistViewModel : NSObject <ArtistFetchDelegate>

- (instancetype)initWithDelegate:(id<ArtistViewModelDelegate>)delegate;
- (void)beginWithArtist:(Artist *)artist;

@end

@protocol ArtistViewModelDelegate <NSObject>

- (void)didFinishFetchingArtistAlbums:(NSArray *)albumArray;

@end