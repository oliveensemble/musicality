//
//  SearchPendingOperations.m
//  Musicality
//
//  Created by Evan Lewis on 7/18/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

#import "SearchPendingOperations.h"

@implementation SearchPendingOperations

+ (instancetype)sharedOperations {
  static SearchPendingOperations *sharedOperations = nil;
  
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
  if (!_searchRequestsInProgress) {
    _searchRequestsInProgress = [[NSMutableDictionary alloc] init];
  }
  return _searchRequestsInProgress;
}

- (NSOperationQueue *)exploreRequestQueue {
  if (!_searchRequestQueue) {
    _searchRequestQueue = [[NSOperationQueue alloc] init];
    _searchRequestQueue.name = @"Explore Request Queue";
  }
  return _searchRequestQueue;
}


@end
