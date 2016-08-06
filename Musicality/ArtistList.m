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
#import "Blacklist.h"

@interface ArtistList ()

@property (copy, nonatomic) NSString *path;

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
  if (artist.name != nil && ![artist.name isEqualToString:@""] && artist.artistID != nil) {
    [self.artistSet addObject:artist];
    [self setViewNeedsUpdates:YES];
  }
}

- (void)removeArtist:(Artist*)artist {
  
  for (Artist *libraryArtist in [mStore artistsFromUserLibrary]) {
    // If we are trying to remove an artist that's in the users library, add it to the blacklist
    if ([[artist.name lowercaseString] isEqualToString:[libraryArtist.name lowercaseString]]) {
      [[Blacklist sharedList] addArtistToList:artist];
      break;
    }
  }
  
  // Then remove it
  NSMutableArray *artistToDelete = [NSMutableArray array];
  for (Artist *listArtist in self.artistSet) {
    if ([listArtist.name isEqualToString:artist.name]) {
      [artistToDelete addObject: listArtist];
    }
  }
  
  [self.artistSet removeObjectsInArray: artistToDelete];
  [self setViewNeedsUpdates:YES];
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

- (void)updateLatestRelease:(Album*)album forArtist:(Artist *)artist {
  for (Artist *listArtist in self.artistSet) {
    if (listArtist.artistID == artist.artistID) {
      if (![album.title isEqualToString:artist.latestRelease.title]) {
        listArtist.latestRelease = album;
        DLog(@"%@ has been updated", artist.name);
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

#pragma mark - Helper
- (void)addPopularArtists {
  NSDictionary *popularArtists = @{ @"Drake" : @"271256",
                                    @"Justin Bieber" : @"320569549",
                                    @"Twenty One Pilots" : @"349736311",
                                    @"Rihanna" : @"63346553",
                                    @"Bryson Tiller" : @"642591128",
                                    @"The Chainsmokers" : @"580391756",
                                    @"The Weeknd" : @"479756766",
                                    @"Adele" : @"262836961",
                                    @"Fetty Wap" : @"872900424",
                                    @"Selena Gomez" : @"280215834",
                                    @"Dnce" : @"1040595108",
                                    @"Flo Rida" : @"255303209",
                                    @"Meghan Trainor" : @"348580754",
                                    @"Shawn Mendes" : @"890403665",
                                    @"Ariana Grande" : @"412778295",
                                    @"Kevin Gates" : @"298383551",
                                    @"Mike Posner" : @"333687585",
                                    @"G-eazy" : @"275649746",
                                    @"Beyonce" : @"1419227",
                                    @"Future" : @"128050210",
                                    @"Fifth Harmony" : @"577354628",
                                    @"Charlie Puth" : @"336249253",
                                    @"Alessia Cara" : @"991444375",
                                    @"Thomas Rhett" : @"502541718",
                                    @"Zayn" : @"973181994",
                                    @"Desiigner" : @"1068985672",
                                    @"Jeremih" : @"303296550",
                                    @"James Bay" : @"369659529",
                                    @"Lukas Graham" : @"473219952",
                                    @"Zara Larsson" : @"570372593",
                                    @"Taylor Swift" : @"159260351",
                                    @"Tory Lanez" : @"440458549",
                                    @"Nick Jonas" : @"286541773",
                                    @"Sia" : @"13493906",
                                    @"Luke Bryan" : @"20131064",
                                    @"Florida Georgia Line" : @"399241518",
                                    @"Yo Gotti" : @"62763238",
                                    @"Chris Brown" : @"95705522",
                                    @"Ruth B." : @"1037048423",
                                    @"Daya" : @"1037160430",
                                    @"Dj Snake" : @"125742557",
                                    @"Post Malone" : @"966309175",
                                    @"Calvin Harris" : @"201955086",
                                    @"Major Lazer" : @"315761934",
                                    @"Blake Shelton" : @"189204",
                                    @"Justin Timberlake" : @"398128",
                                    @"P!Nk" : @"4488522",
                                    @"Coldplay" : @"471744",
                                    @"Dierks Bentley" : @"3088872",
                                    @"Ellie Goulding" : @"338264227",
                                    @"Prince" : @"155814",
                                    @"Tim Mcgraw" : @"3496236",
                                    @"Carrie Underwood" : @"63399334",
                                    @"Elle King" : @"395811135",
                                    @"Keith Urban" : @"549836",
                                    @"Travis Scott" : @"549236696",
                                    @"Cole Swindell" : @"354625084",
                                    @"Kent Jones" : @"420441123",
                                    @"O.T. Genasis" : @"811744627",
                                    @"Sam Hunt" : @"214150835",
                                    @"Rachel Platten" : @"431528675",
                                    @"Maren Morris" : @"262260873",
                                    @"Wiz Khalifa" : @"201714418",
                                    @"Fat Joe" : @"150627775",
                                    @"Jason Aldean" : @"63684710",
                                    @"Flume" : @"4275634",
                                    @"Young Thug" : @"81886939",
                                    @"Kanye West" : @"2715720",
                                    @"Troye Sivan" : @"396295677",
                                    @"Disturbed" : @"156807",
                                    @"One Direction" : @"396754057",
                                    @"Dj Khaled" : @"157749142",
                                    @"Old Dominion" : @"495761008",
                                    @"Chris Young" : @"4779205",
                                    @"Robin Schulz" : @"347433400",
                                    @"Lukas Graham" : @"473219952",
                                    @"Demi Lovato" : @"280215821",
                                    @"Kelsea Ballerini" : @"382270241",
                                    @"Brett Eldredge" : @"351352781",
                                    @"Silento" : @"950550278",
                                    @"Jason Derulo" : @"259118085",
                                    @"Madeintyo" : @"1064987464",
                                    @"Zac Brown Band" : @"129045039",
                                    @"Jon Pardi" : @"371085834",
                                    @"J. Cole" : @"73705833",
                                    @"Granger Smith" : @"69285061",
                                    @"Rascal Flatts" : @"3300203",
                                    @"Eric Church" : @"123055194",
                                    @"Gnash" : @"299209053",
                                    @"Dustin Lynch" : @"493220807",
                                    @"Kelly Clarkson" : @"316265",
                                    @"X Ambassadors" : @"622429974",
                                    @"Brothers Osborne" : @"695313023",
                                    @"Onerepublic" : @"260414340",
                                    @"R. City" : @"269180970",
                                    @"Chris Stapleton" : @"1752134",
                                    @"Dreezy" : @"390879803",
                                    @"Jessie J" : @"405360400",
                                    @"Fall Out Boy" : @"28673423",
                                    @"Ghost Town Djs" : @"266863959"
                                    };
  
  for (int i = 0; i < popularArtists.count; i++) {
    NSString *artistName = popularArtists.allKeys[i];
    NSString *artistID = popularArtists.allValues[i];
    Artist *artist = [[Artist alloc] initWithArtistID:artistID andName:artistName];
    [self addArtistToList:artist];
  }
}

@end
