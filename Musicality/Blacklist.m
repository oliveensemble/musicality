//
//  Blacklist.m
//  Musicality
//
//  Created by Evan Lewis on 6/19/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

#import "Blacklist.h"
#import "ArtistList.h"
#import "MStore.h"

@interface Blacklist ()

@property (copy, nonatomic) NSString *path;
@property (nonatomic) NSMutableOrderedSet* artistSet;

@end

@implementation Blacklist

+ (instancetype)sharedList {
  static Blacklist *sharedList = nil;
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
    _path = [documentsDirectory stringByAppendingPathComponent:@"Blacklist.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath: self.path]) {
      NSString *bundle = [[NSBundle mainBundle] pathForResource:@"Blacklist" ofType:@"plist"];
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

- (void)addArtistToList:(Artist *)artist {
  for (Artist *listArtist in self.artistSet) {
    if ([listArtist.name isEqualToString:artist.name]) {
      return;
    }
  }
  [[ArtistList sharedList] removeArtist:artist];
  [self.artistSet addObject:artist];
  DLog(@"Successfully added %@ to blacklist", artist.name);
}

- (void)removeArtist:(Artist *)artist {
  for (Artist *listArtist in self.artistSet) {
    if ([listArtist.name isEqualToString:artist.name]) {
      [self.artistSet removeObject:listArtist];
      DLog(@"Successfully removed %@ from blacklist", artist.name);
      return;
    }
  }
}

- (NSMutableOrderedSet*)loadData {
  
  NSData *archiveData = [NSData dataWithContentsOfFile:self.path];
  self.artistSet = nil;
  @try {
    _artistSet = [NSKeyedUnarchiver unarchiveObjectWithData:archiveData];
  }
  @catch (NSException *exception) {
    DLog(@"No save data found");
    _artistSet = [[NSMutableOrderedSet alloc] init];
  }
  return self.artistSet;
  
}

- (void)saveChanges {
  NSError *error;
  NSData *archiveData = [NSKeyedArchiver archivedDataWithRootObject:self.artistSet];
  [archiveData writeToFile:self.path atomically:YES];
  if (error) {
    DLog(@"Error: %@", [error localizedDescription]);
  }
  
}

@end
