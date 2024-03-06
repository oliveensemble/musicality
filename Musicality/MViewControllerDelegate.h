//
//  MViewControllerDelegate.h
//  Musicality
//
//  Created by Elle Lewis on 6/14/16.
//  Copyright © 2016 Elle Lewis. All rights reserved.
//

@import UIKit;

@protocol MViewControllerDelegate;

@interface MViewControllerDelegate : NSObject

@end

@protocol MViewControllerDelegate <NSObject>

// Must add the UIApplicationDidBecomeActiveNotification observer to viewMovedToForeground
- (void)viewMovedToForeground;
- (void)checkForNotification:(UILocalNotification *)localNotification;

@end
