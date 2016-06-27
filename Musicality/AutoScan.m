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
                    [[[PendingOperations sharedOperations] requestsInProgress] setObject:artistSearch forKey:[NSString stringWithFormat:@"Artist Search for %@", artist.name]];
                    [[[PendingOperations sharedOperations] requestQueue] addOperation:artistSearch];
                } 
            } 
        }
        [[PendingOperations sharedOperations] beginOperations];
    } else { 
        DLog(@"A scan is already in progress"); 
    }
}

- (void)stopScan {
    [[[PendingOperations sharedOperations] requestQueue] cancelAllOperations];
    [[[PendingOperations sharedOperations] requestsInProgress] removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"autoScanFinished" object:nil userInfo:nil];
    self.isScanning = NO;
}

- (void)artistSearchDidFinish:(ArtistSearch *)downloader {
    [[ArtistList sharedList] addArtistToList:downloader.artist];
    [[[PendingOperations sharedOperations] requestsInProgress] removeObjectForKey:[NSString stringWithFormat:@"Artist Search for %@", downloader.artist.name]];
    [[PendingOperations sharedOperations] updateProgress];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"autoScanUpdate" object:nil userInfo:@{@"artistName": downloader.artist.name}];
    if ([[[PendingOperations sharedOperations] requestsInProgress] count] == 0) {
        DLog(@"Finished artist search");
        self.isScanning = NO;
        [[[PendingOperations sharedOperations] requestQueue] cancelAllOperations];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"autoScanFinished" object:nil userInfo:nil];
        [[ArtistList sharedList] saveChanges];
        [[Blacklist sharedList] saveChanges];
    }
}

@end
