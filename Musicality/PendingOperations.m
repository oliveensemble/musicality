//
//  PendingOperations.m
//  Musicality
//
//  Created by Evan Lewis on 5/25/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

#import "PendingOperations.h"

@implementation PendingOperations

+ (instancetype)sharedOperations {
    static PendingOperations *sharedOperations = nil;
    
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
    self.totalOperations = (int)self.requestsInProgress.count;
    self.currentProgress = 0.0;
}

- (void)updateProgress {
    int currentCount = (int)(self.totalOperations - self.requestsInProgress.count);
    self.currentProgress = ((float)currentCount / (float)self.totalOperations) * 100.0;
}

- (NSMutableDictionary *)requestsInProgress {
  if (!_requestsInProgress) {
    _requestsInProgress = [[NSMutableDictionary alloc] init];
  }
  return _requestsInProgress;
}

- (NSOperationQueue *)requestQueue {
  if (!_requestQueue) {
    _requestQueue = [[NSOperationQueue alloc] init];
    _requestQueue.name = @"Artist Search Queue";
    _requestQueue.maxConcurrentOperationCount = 1;
  }
  return _requestQueue;
}

@end
