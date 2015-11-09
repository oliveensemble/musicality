//
//  PendingOperations.m
//  Musicality
//
//  Created by Evan Lewis on 5/25/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

#import "PendingOperations.h"

@implementation PendingOperations

- (NSMutableDictionary *)searchesInProgress {
  if (!_searchesInProgress) {
    _searchesInProgress = [[NSMutableDictionary alloc] init];
  }
  return _searchesInProgress;
}

- (NSOperationQueue *)searchQueue {
  if (!_searchQueue) {
    _searchQueue = [[NSOperationQueue alloc] init];
    _searchQueue.name = @"Artist Search Queue";
    _searchQueue.maxConcurrentOperationCount = 1;
  }
  return _searchQueue;
}

@end
