//
//  Blacklist.m
//  Musicality
//
//  Created by Elle Lewis on 6/19/15.
//  Copyright (c) 2015 Elle Lewis. All rights reserved.
//

#import "Blacklist.h"
#import "ArtistList.h"
#import "MStore.h"

@interface Blacklist ()

@property (copy, nonatomic) NSString *path;
@property (nonatomic) NSMutableOrderedSet *artistSet;

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
    if ([[artist.name lowercaseString] isEqualToString:[listArtist.name lowercaseString]]) {
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
  [self.artistSet addObject:artist];
  DLog(@"Sucessfully added %@ to the blacklist", artist.name);
}

- (void)removeArtist:(Artist *)artist {
  NSMutableArray *artistToDelete = [NSMutableArray arrayWithCapacity:1];
  for (Artist *listArtist in self.artistSet) {
    if (listArtist.artistID == artist.artistID) {
      [artistToDelete addObject:listArtist];
      break;
    }
  }
  [self.artistSet removeObjectsInArray:artistToDelete];
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
