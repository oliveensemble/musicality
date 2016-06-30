//
//  ExplorePendingOperations.m
//  Musicality
//
//  Created by Evan Lewis on 5/25/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

#import "ExplorePendingOperations.h"

@implementation ExplorePendingOperations

+ (instancetype)sharedOperations {
    static ExplorePendingOperations *sharedOperations = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedOperations = [[self alloc] initPrivate];
    });
    
    return sharedOperations;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use sharedOperations instead"
                                 userInfo:nil];
    return nil;
}

- (void)beginOperations {
    self.totalOperations = (int)self.exploreRequestsInProgress.count;
    self.currentProgress = 0.0;
}

- (void)updateProgress:(NSString *)progressText {
    int currentCount = (int)self.totalOperations - (int)self.exploreRequestsInProgress.count;
    if (currentCount == 0) {
        self.currentProgress = 100.0;
    }
    self.currentProgress = ((float)currentCount / (float)self.totalOperations) * 100.0;
    self.currentProgressText = progressText;
}

- (NSMutableDictionary *)exploreRequestsInProgress {
    if (!_exploreRequestsInProgress) {
        _exploreRequestsInProgress = [[NSMutableDictionary alloc] init];
    }
    return _exploreRequestsInProgress;
}

- (NSOperationQueue *)exploreRequestQueue {
    if (!_exploreRequestQueue) {
        _exploreRequestQueue = [[NSOperationQueue alloc] init];
        _exploreRequestQueue.name = @"Explore Request Queue";
    }
    return _exploreRequestQueue;
}

@end
