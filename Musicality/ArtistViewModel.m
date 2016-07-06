//
//  ArtistViewModel.m
//  Musicality
//
//  Created by Evan Lewis on 6/29/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

#import "ArtistViewModel.h"
#import "ArtistFetch.h"
#import "ArtistPendingOperations.h"

@interface ArtistViewModel()

@property (nonatomic, weak) id<ArtistViewModelDelegate> delegate;
@property (nonatomic) NSArray *albumArray;

@end

@implementation ArtistViewModel

- (instancetype)initWithDelegate:(id<ArtistViewModelDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

- (void)beginWithArtist:(Artist *)artist {
    ArtistFetch *artistFetch = [[ArtistFetch alloc] initWithArtist: artist delegate:self];
    [[[ArtistPendingOperations sharedOperations] artistRequestsInProgress] setObject: artistFetch forKey:@"ArtistFetch"];
    [[[ArtistPendingOperations sharedOperations] artistRequestQueue] addOperation:artistFetch];
    [[ArtistPendingOperations sharedOperations] beginOperations];
}

#pragma mark - Artist Fetch Delegate Methods

- (void)artistFetchDidFinish:(ArtistFetch *)downloader {
    [[[ArtistPendingOperations sharedOperations] artistRequestsInProgress] removeObjectForKey:@"ArtistFetch"];
    [[ArtistPendingOperations sharedOperations] updateProgress:[NSString stringWithFormat:@"ArtistFetch"]];
    self.albumArray = downloader.albumArray;
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(didFinishFetchingArtistAlbums:) withObject: self.albumArray waitUntilDone:NO];
}

@end
