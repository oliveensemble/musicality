//
//  ExplorePendingOperations.h
//  Musicality
//
//  Created by Evan Lewis on 5/25/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//
// Pending operations for loading albums for the explore view (single request operations)

@import Foundation;

@interface ExplorePendingOperations : NSObject

+ (instancetype)sharedOperations;

@property (nonatomic, strong) NSMutableDictionary *exploreRequestsInProgress;
@property (nonatomic, strong) NSOperationQueue *exploreRequestQueue;

@property (nonatomic) int totalOperations;
@property (nonatomic) float currentProgress;
@property (nonatomic, strong) NSString *currentProgressText;

- (void)beginOperations;
- (void)updateProgress:(NSString *)progressText;

@end
