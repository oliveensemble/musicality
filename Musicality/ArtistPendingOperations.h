//
//  ArtistPendingOperations.h
//  Musicality
//
//  Created by Evan Lewis on 6/29/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//
//  Pending operations for loading albums from an artist
@import Foundation;

@interface ArtistPendingOperations : NSObject

+ (instancetype)sharedOperations;

@property (nonatomic, strong) NSMutableDictionary *artistRequestsInProgress;
@property (nonatomic, strong) NSOperationQueue *artistRequestQueue;

@property (nonatomic) int totalOperations;
@property (nonatomic) float currentProgress;
@property (copy, nonatomic) NSString *currentProgressText;

- (void)beginOperations;
- (void)updateProgress:(NSString *)progressText;

@end

