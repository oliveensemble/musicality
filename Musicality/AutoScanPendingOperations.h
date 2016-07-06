//
//  ArtistScanPendingOperations.h
//  Musicality
//
//  Created by Evan Lewis on 6/28/16.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

@import Foundation;

@interface AutoScanPendingOperations : NSObject

+ (instancetype)sharedOperations;

@property (nonatomic, strong) NSMutableDictionary *artistRequestsInProgress;

@property (nonatomic, strong) NSOperationQueue *artistRequestQueue;
@property (nonatomic) int totalOperations;
@property (nonatomic) float currentProgress;
@property (copy, nonatomic) NSString *currentProgressText;

- (void)beginOperations;
- (void)updateProgress:(NSString *)progressText;

@end
