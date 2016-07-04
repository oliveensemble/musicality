//
//  MTableViewController.h
//  Musicality
//
//  Created by Evan Lewis on 6/14/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

#import "MTableViewController.h"
#import "UserPrefs.h"
#import "MStore.h"

@interface MTableViewController ()

@end

@implementation MTableViewController

#pragma mark - Lifecycle
- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewMovedToForeground) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self viewMovedToForeground];
}

- (void)viewMovedToForeground {
    DLog(@"Moved to foreground");
    [self checkForNotification: mStore.localNotification];
}

- (void)checkForNotification:(UILocalNotification *)localNotification {
    if (localNotification) {
        DLog(@"Local Notification: %@", mStore.localNotification);
        if([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive) {
            DLog(@"(Background) Local Notification");
        }
        // Remove the local notification when we're finished with it so it doesn't get reused
        [mStore setLocalNotification:nil];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

@end
