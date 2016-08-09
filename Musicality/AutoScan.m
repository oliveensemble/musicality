//
//  AutoScan.m
//  Musicality
//
//  Created by Evan Lewis on 6/20/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

#import "MStore.h"
#import "Blacklist.h"
#import "AutoScan.h"
#import "UserPrefs.h"
#import "ArtistList.h"
#import "AutoScanPendingOperations.h"

@implementation AutoScan

+ (instancetype)sharedScan {
  static AutoScan *sharedScan = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedScan = [[self alloc] initPrivate];
  });
  return sharedScan;
}

- (instancetype)initPrivate {
  self = [super init];
  if (self) {
    _isScanning = NO;
  }
  return self;
}

- (instancetype)init {
  @throw [NSException exceptionWithName:@"Singleton"
                                 reason:@"Use sharedList instead"
                               userInfo:nil];
  return nil;
}

- (void)startScan {
  if (!self.isScanning) {
    
    if ([[ArtistList sharedList] artistSet].count == 0) {
      [[UserPrefs sharedPrefs] setNoArtists:YES];
    }
    
    DLog(@"Autoscan started");
    for (Artist *artist in mStore.artistsFromUserLibrary) {
      if (![[Blacklist sharedList] isInList:artist]) {
        if (![[ArtistList sharedList] isInList:artist]) {
          if (!self.isScanning) {
            self.isScanning = YES;
          }
          ArtistSearch *artistSearch = [[ArtistSearch alloc] initWithArtist:artist delegate:self];
          artistSearch.queuePriority = NSOperationQueuePriorityLow;
          [[[AutoScanPendingOperations sharedOperations] artistRequestsInProgress] setObject:artistSearch forKey:[NSString stringWithFormat:@"Scanning %@", artist.name]];
          [[[AutoScanPendingOperations sharedOperations] artistRequestQueue] addOperation:artistSearch];
        } 
      } 
    }
    [[AutoScanPendingOperations sharedOperations] beginOperations];
  } else { 
    DLog(@"A scan is already in progress"); 
  }
}

- (void)stopScan {
  [[[AutoScanPendingOperations sharedOperations] artistRequestQueue] cancelAllOperations];
  [[[AutoScanPendingOperations sharedOperations] artistRequestsInProgress] removeAllObjects];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"autoScanFinished" object:nil userInfo:nil];
  self.isScanning = NO;
}

- (void)artistSearchDidFinish:(ArtistSearch *)downloader {
  [[ArtistList sharedList] addArtistToList:downloader.artist];
  [[[AutoScanPendingOperations sharedOperations] artistRequestsInProgress] removeObjectForKey:[NSString stringWithFormat:@"Scanning %@", downloader.artist.name]];
  [[AutoScanPendingOperations sharedOperations] updateProgress:[NSString stringWithFormat:@"Scanning %@", downloader.artist.name]];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"autoScanUpdate" object:nil userInfo:@{@"artistName": downloader.artist.name}];
  if ([[[AutoScanPendingOperations sharedOperations] artistRequestsInProgress] count] == 0) {
    DLog(@"Finished artist search");
    self.isScanning = NO;
    [mStore setLastLibraryScanDate:[NSDate date]];
    [[[AutoScanPendingOperations sharedOperations] artistRequestQueue] cancelAllOperations];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"autoScanFinished" object:nil userInfo:nil];
    [[ArtistList sharedList] saveChanges];
  }
}

@end
