//
//  PendingOperations.m
//  Musicality
//
//  Created by Evan Lewis on 5/25/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

#import "PendingOperations.h"

@implementation PendingOperations

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
