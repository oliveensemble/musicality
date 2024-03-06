//
//  ArtistScanPendingOperations.h
//  Musicality
//
//  Created by Elle Lewis on 6/28/16.
//  Copyright (c) 2015 Later Creative LLC. All rights reserved.
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
