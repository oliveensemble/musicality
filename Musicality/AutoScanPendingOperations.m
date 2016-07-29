//
//  AutoScanPendingOperations.m
//  Musicality
//
//  Created by Evan Lewis on 6/28/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

#import "AutoScanPendingOperations.h"

@implementation AutoScanPendingOperations

+ (instancetype)sharedOperations {
  static AutoScanPendingOperations *sharedOperations = nil;
  
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
  self.totalOperations = (int)self.artistRequestsInProgress.count;
  self.currentProgress = 0.0;
}

- (void)updateProgress:(NSString *)progressText {
  int currentCount = (int)self.totalOperations - (int)self.artistRequestsInProgress.count;
  if (currentCount == 0) {
    self.currentProgress = 100.0;
  }
  self.currentProgress = ((float)currentCount / (float)self.totalOperations) * 100.0;
  self.currentProgressText = progressText;
}

- (NSMutableDictionary *)artistRequestsInProgress {
  if (!_artistRequestsInProgress) {
    _artistRequestsInProgress = [[NSMutableDictionary alloc] init];
  }
  return _artistRequestsInProgress;
}

- (NSOperationQueue *)artistRequestQueue {
  if (!_artistRequestQueue) {
    _artistRequestQueue = [[NSOperationQueue alloc] init];
    _artistRequestQueue.name = @"Artist Request Queue";
    _artistRequestQueue.maxConcurrentOperationCount = 3;
  }
  return _artistRequestQueue;
}

@end
