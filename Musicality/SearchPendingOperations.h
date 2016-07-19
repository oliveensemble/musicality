//
//  SearchPendingOperations.h
//  Musicality
//
//  Created by Evan Lewis on 7/18/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

@import Foundation;

@interface SearchPendingOperations : NSOperation

+ (instancetype)sharedOperations;

@property (strong, nonatomic) NSMutableDictionary *searchRequestsInProgress;
@property (strong, nonatomic) NSOperationQueue *searchRequestQueue;

@property (nonatomic) int totalOperations;
@property (nonatomic) float currentProgress;
@property (copy, nonatomic) NSString *currentProgressText;

- (void)beginOperations;
- (void)updateProgress:(NSString *)progressText;

@end
