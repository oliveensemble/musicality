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
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"AutoScan Finished"];
    for (Artist *artist in mStore.artistsFromUserLibrary) {
      if (![[Blacklist sharedList] isInList:artist]) {
        if (![[ArtistList sharedList] isInList:artist]) {
          if (!self.isScanning) {
            self.isScanning = YES;
          }
          ArtistSearch *artistSearch = [[ArtistSearch alloc] initWithArtist:artist delegate:self];
          [self.pendingOperations.requestsInProgress setObject:artistSearch forKey:[NSString stringWithFormat:@"Artist Search for %@", artist.name]];
          [self.pendingOperations.requestQueue addOperation:artistSearch];
        }
      }
    }
  } else {
    DLog(@"A scan is already in progress");
  }
}

- (void)stopScan {
  [self.pendingOperations.requestQueue cancelAllOperations];
  [self.pendingOperations.requestsInProgress removeAllObjects];
  self.isScanning = NO;
}

- (PendingOperations *)pendingOperations {
  if (!_pendingOperations) {
    _pendingOperations = [[PendingOperations alloc] init];
  }
  return _pendingOperations;
}

- (void)artistSearchDidFinish:(ArtistSearch *)downloader {
  [[ArtistList sharedList] addArtistToList:downloader.artist];
  [self.pendingOperations.requestsInProgress removeObjectForKey:[NSString stringWithFormat:@"Artist Search for %@", downloader.artist.name]];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"autoScanUpdate" object:nil userInfo:@{@"artistName": downloader.artist.name}];
  if (self.pendingOperations.requestsInProgress.count == 0) {
    DLog(@"Finished artist search");
    self.isScanning = NO;
    [self.pendingOperations.requestQueue cancelAllOperations];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"autoScanFinished" object:nil userInfo:nil];
    [[ArtistList sharedList] saveChanges];
    [[Blacklist sharedList] saveChanges];
  }
}

@end
