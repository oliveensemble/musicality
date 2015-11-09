//
//  NotificationListHandler.h
//  Musicality
//
//  Created by Evan Lewis on 11/3/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import Foundation;

#import "NotificationCheck.h"
#import "PendingOperations.h"

@interface NotificationListHandler : NSObject  <NotificationCheckDelegate>

@property (nonatomic, strong) PendingOperations *pendingOperations;

- (void)startRequests;

@end
