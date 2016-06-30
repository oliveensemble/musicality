//
//  ArtistListViewModel.m
//  Musicality
//
//  Created by Evan Lewis on 6/28/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

#import "ArtistListViewModel.h"
#import "LatestReleaseSearch.h"
#import "ArtistScanPendingOperations.h"
#import "AutoScanPendingOperations.h"
#import "ArtistList.h"
#import "MStore.h"
#import "AutoScan.h"

@interface ArtistListViewModel() <LatestReleaseSearchDelegate>

@property (nonatomic, weak) id<ArtistListViewModelDelegate> delegate;

@end

@implementation ArtistListViewModel

- (instancetype)initWithDelegate:(id<ArtistListViewModelDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoScanUpdate:) name:@"autoScanUpdate" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(autoScanFinished) name:@"autoScanFinished" object:nil];
    }
    return self;
}

- (void)beginUpdates {
    if ([[AutoScan sharedScan] isScanning]) {
        return;
    }
    
    NSOrderedSet *artistSet = [[ArtistList sharedList] artistSet];
    if (artistSet.count == 0) {
        [self didFinishUpdatingList];
        return;
    }
    
    for (Artist* artist in [[ArtistList sharedList] artistSet]) {
        if (([mStore thisDate:[NSDate dateWithTimeIntervalSinceNow:-604800] isMoreRecentThan:artist.lastCheckDate]) || artist.lastCheckDate == nil) {
            LatestReleaseSearch *albumSearch = [[LatestReleaseSearch alloc] initWithArtist:artist delegate:self];
            [[[ArtistScanPendingOperations sharedOperations] artistRequestsInProgress] setObject:albumSearch forKey:[NSString stringWithFormat:@"Updating %@", artist.name]];
            [[[ArtistScanPendingOperations sharedOperations] artistRequestQueue] addOperation:albumSearch];
        }
    }
    
    if ([[[ArtistScanPendingOperations sharedOperations] artistRequestsInProgress] count] == 0) {
        [self didFinishUpdatingList];
        return;
    }
    
    [[ArtistScanPendingOperations sharedOperations] beginOperations];
}

- (void)latestReleaseSearchDidFinish:(LatestReleaseSearch *)downloader {
    [[ArtistList sharedList] updateLatestRelease:downloader.album forArtist:downloader.artist];
    [[[ArtistScanPendingOperations sharedOperations] artistRequestsInProgress] removeObjectForKey:[NSString stringWithFormat:@"Updating %@", downloader.artist.name]];
    [[ArtistScanPendingOperations sharedOperations] updateProgress:[NSString stringWithFormat:@"Updating %@", downloader.artist.name]];
    [self didUpdateList:[NSString stringWithFormat:@"Updating %@", downloader.artist.name] atPercentage:[[ArtistScanPendingOperations sharedOperations] currentProgress]];
    if ([[[ArtistScanPendingOperations sharedOperations] artistRequestsInProgress] count] == 0) {
        [[ArtistList sharedList] saveChanges];
        [self didFinishUpdatingList];
    }
}

- (void)autoScanUpdate:(NSNotification *)notification {
    NSDictionary *dict = [notification userInfo];
    int currentProgress = (int)[[AutoScanPendingOperations sharedOperations] currentProgress];
    [self didUpdateList:[NSString stringWithFormat:@"Scanning: %@", dict[@"artistName"]] atPercentage:currentProgress];
}

- (void)autoScanFinished {
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(didFinishUpdatingList) withObject:nil waitUntilDone:NO];
    [self beginUpdates];
}

- (void)didUpdateList:(NSString *)updateStatus atPercentage:(int)updateProgress {
    NSDictionary *statusInfo = @{@"updateStatus": updateStatus, @"updateProgress" : [NSNumber numberWithInt:updateProgress]};
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(didUpdateList:) withObject:statusInfo waitUntilDone:NO];
}

- (void)didFinishUpdatingList {
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(didFinishUpdatingList) withObject:nil waitUntilDone:NO];
}

@end
