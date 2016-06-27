//
//  PendingOperations.h
//  Musicality
//
//  Created by Evan Lewis on 5/25/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

@import Foundation;

@interface PendingOperations : NSObject

+ (instancetype)sharedOperations;

@property (nonatomic, strong) NSMutableDictionary *requestsInProgress;
@property (nonatomic, strong) NSOperationQueue *requestQueue;
@property (nonatomic) int totalOperations;
@property (nonatomic) float currentProgress;

- (void)beginOperations;
- (void)updateProgress;

@end
