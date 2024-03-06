//
//  ArtistUpdatePendingOperations.h
//  Musicality
//
//  Created by Elle Lewis on 6/28/16.
//  Copyright (c) 2016 Later Creative LLC. All rights reserved.
//

@import Foundation;

@interface ArtistUpdatePendingOperations : NSObject

+ (instancetype)sharedOperations;

@property (nonatomic, strong) NSMutableDictionary *artistRequestsInProgress;

@property (nonatomic, strong) NSOperationQueue *artistRequestQueue;
@property (nonatomic) int totalOperations;
@property (nonatomic) float currentProgress;
@property (copy, nonatomic) NSString *currentProgressText;

- (void)beginOperations;
- (void)updateProgress:(NSString *)progressText;

@end
