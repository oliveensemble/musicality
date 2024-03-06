//
//  TutorialNotificationViewController.m
//  Musicality
//
//  Created by Elle Lewis on 7/30/16.
//  Copyright © 2016 Elle Lewis. All rights reserved.
//

#import "TutorialNotificationViewController.h"

@interface TutorialNotificationViewController ()

@end

@implementation TutorialNotificationViewController

- (IBAction)notificationButtonTapped:(UIButton *)sender {
  // Ask to allow push notifications
  UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
  UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
  [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
}

@end
