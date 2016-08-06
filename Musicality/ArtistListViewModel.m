//
//  ArtistListViewModel.m
//  Musicality
//
//  Created by Evan Lewis on 6/28/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

#import "ArtistListViewModel.h"
#import "LatestReleaseSearch.h"
#import "ArtistUpdatePendingOperations.h"
#import "AutoScanPendingOperations.h"
#import "ArtistList.h"
#import "MStore.h"
#import "AutoScan.h"
#import "Blacklist.h"

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
  
  NSMutableArray *artistsToDelete = [NSMutableArray array];
  NSMutableArray *artistsToAddToPendingOperations = [NSMutableArray array];
  
  for (Artist *artist in [[ArtistList sharedList] artistSet]) {
    // If artist is a group artist
    if ([artist.name containsString:@"&"] || [artist.name containsString:@"feat."]) {
      for (Artist *otherArtist in [[ArtistList sharedList] artistSet]) {
        // And there's already an artist in the list that isn't a group artist but has the same id
        if ((otherArtist.artistID == artist.artistID) && (![otherArtist.name containsString:@"&"] && ![otherArtist.name containsString:@"feat."])) {
          DLog(@"Found group artist:\n%@ - %@, original artist is:\n%@ - %@", artist.name, artist.artistID, otherArtist.name, otherArtist.artistID);
          DLog(@"Adding %@ to be deleted", artist.name);
          [artistsToDelete addObject:artist];
          break;
        }
      }
    } else {
      [artistsToAddToPendingOperations addObject:artist];
    }
  }
  
  for (Artist *artist in artistsToDelete) {
    [[ArtistList sharedList] removeArtist:artist];
  }
  
  for (Artist *artist in artistsToAddToPendingOperations) {
    [self addArtistToPendingOperations:artist];
  }
  
  if ([[[ArtistUpdatePendingOperations sharedOperations] artistRequestsInProgress] count] == 0) {
    [self didFinishUpdatingList];
    return;
  }
  
  [[ArtistUpdatePendingOperations sharedOperations] beginOperations];
}

- (void)addArtistToPendingOperations:(Artist*)artist {
  if (([mStore thisDate:[NSDate dateWithTimeIntervalSinceNow:-604800] isMoreRecentThan:artist.lastCheckDate]) || artist.lastCheckDate == nil) {
    LatestReleaseSearch *albumSearch = [[LatestReleaseSearch alloc] initWithArtist:artist delegate:self];
    [[[ArtistUpdatePendingOperations sharedOperations] artistRequestsInProgress] setObject:albumSearch forKey:[NSString stringWithFormat:@"Updating %@", artist.name]];
    DLog(@"Updating %@", artist.name);
    [[[ArtistUpdatePendingOperations sharedOperations] artistRequestQueue] addOperation:albumSearch];
  }
}

- (void)latestReleaseSearchDidFinish:(LatestReleaseSearch *)downloader {
  [[ArtistList sharedList] updateLatestRelease:downloader.album forArtist:downloader.artist];
  [[[ArtistUpdatePendingOperations sharedOperations] artistRequestsInProgress] removeObjectForKey:[NSString stringWithFormat:@"Updating %@", downloader.artist.name]];
  [[ArtistUpdatePendingOperations sharedOperations] updateProgress:[NSString stringWithFormat:@"Updating %@", downloader.artist.name]];
  [self didUpdateList:[NSString stringWithFormat:@"Updating %@", downloader.artist.name] atPercentage:[[ArtistUpdatePendingOperations sharedOperations] currentProgress]];
  if ([[[ArtistUpdatePendingOperations sharedOperations] artistRequestsInProgress] count] == 0) {
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
  [self beginUpdates];
  [(NSObject *)self.delegate performSelectorOnMainThread:@selector(didFinishUpdatingList) withObject:nil waitUntilDone:NO];
}

- (void)didUpdateList:(NSString *)updateStatus atPercentage:(int)updateProgress {
  NSDictionary *statusInfo = @{@"updateStatus": updateStatus, @"updateProgress" : [NSNumber numberWithInt:updateProgress]};
  [(NSObject *)self.delegate performSelectorOnMainThread:@selector(didUpdateList:) withObject:statusInfo waitUntilDone:NO];
}

- (void)didFinishUpdatingList {
  [(NSObject *)self.delegate performSelectorOnMainThread:@selector(didFinishUpdatingList) withObject:nil waitUntilDone:NO];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"autoScanUpdate" object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:@"autoScanFinished" object:nil];
}

@end
