//
//  ArtistList.m
//  Musicality
//
//  Created by Evan Lewis on 5/25/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

#import "ArtistList.h"
#import "UserPrefs.h"
#import "MStore.h"

@interface ArtistList ()

@property (nonatomic) NSString *path;

@end

@implementation ArtistList

+ (instancetype)sharedList {
  static ArtistList *sharedList = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedList = [[self alloc] initPrivate];
  });
  return sharedList;
}

- (instancetype)initPrivate {
  
  self = [super init];
  if (self) {
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.path = [documentsDirectory stringByAppendingPathComponent:@"LibraryData.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath: self.path]) {
      NSString *bundle = [[NSBundle mainBundle] pathForResource:@"LibraryData" ofType:@"plist"];
      [fileManager copyItemAtPath:bundle toPath: self.path error:&error];
    }
    [self loadData];
  }
  return self;
}

- (instancetype)init {
  @throw [NSException exceptionWithName:@"Singleton"
                                 reason:@"Use sharedList instead"
                               userInfo:nil];
  return nil;
}

- (void)addArtistToList:(Artist*)artist {
  if (artist.artistID) {
    //Check if artist is in the set
    for (Artist *listArtist in self.artistSet) {
      if (listArtist.artistID == artist.artistID) {
        DLog(@"Already added %@", artist.name);
        return;
      }
    }
    [self.artistSet addObject:artist];
    DLog(@"%@ has been added to the artists list", artist.name);
    if (![[UserPrefs sharedPrefs] artistListNeedsUpdating]) {
      [[UserPrefs sharedPrefs] setArtistListNeedsUpdating:YES];
    }
  }
}

- (void)removeArtist:(Artist*)artist {
  for (Artist *listArtist in self.artistSet) {
    if (listArtist.artistID == artist.artistID) {
      [self.artistSet removeObject:listArtist];
      DLog(@"Successfully removed %@ from artist list", artist.name);
      return;
    }
  }
}

- (Artist *)getArtist:(NSString *)artistName {
  for (Artist *artist in self.artistSet) {
    if ([artist.name isEqualToString:artistName]) {
      return artist;
    }
  }
  return nil;
}

- (BOOL)isInList:(Artist *)artist {
  for (Artist *listArtist in self.artistSet) {
    if ([artist.name isEqualToString:listArtist.name]) {
      return YES;
    }
  }
  return NO;
}

- (void)removeAllArtists {
  [self.artistSet removeAllObjects];
  [self saveChanges];
}

- (void)updateLatestRelease:(Album*)album forArtist:(Artist *)artist {
  for (Artist *listArtist in self.artistSet) {
    if (listArtist.artistID == artist.artistID) {
      if (![album.title isEqualToString:artist.latestRelease.title]) {
        listArtist.latestRelease = album;
        DLog(@"%@ has been updated", artist.name);
      } else {
        DLog(@"Update not needed for %@", artist.name);
      }
      listArtist.lastCheckDate = [NSDate date];
      return;
    }
  }
}

#pragma mark Load/Save

- (void)loadData {
  
  NSData *archiveData = [NSData dataWithContentsOfFile:self.path];

  @try {
    _artistSet = [NSKeyedUnarchiver unarchiveObjectWithData:archiveData];
    if (self.artistSet == nil) {
      _artistSet = [NSMutableOrderedSet orderedSet];
    }
  }
  @catch (NSException *exception) {
    DLog(@"No save data found");
    _artistSet = [NSMutableOrderedSet orderedSet];
  }
  
}

- (void)saveChanges {
  DLog(@"Saving artist list");
  NSError *error;
  NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:self.artistSet];
  [archiveData writeToFile:self.path atomically:YES];
  if (error) {
    DLog(@"Error: %@", [error localizedDescription]);
  }
  
}

@end
