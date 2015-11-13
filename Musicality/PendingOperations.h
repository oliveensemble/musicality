//
//  PendingOperations.h
//  Musicality
//
//  Created by Evan Lewis on 5/25/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

@import Foundation;

@interface PendingOperations : NSObject

@property (nonatomic, strong) NSMutableDictionary *requestsInProgress;
@property (nonatomic, strong) NSOperationQueue *requestQueue;

@end
