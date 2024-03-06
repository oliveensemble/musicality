//
//  MTabBarController.m
//  Musicality
//
//  Created by Elle Lewis on 6/14/16.
//  Copyright © 2016 Elle Lewis. All rights reserved.
//

#import "MTabBarController.h"
#import "UserPrefs.h"

@interface MTabBarController ()

@end

@implementation MTabBarController

- (void)configureView {
  if ([[UserPrefs sharedPrefs] isDarkModeEnabled]) {
    //Tab Bar customization
    self.tabBar.barTintColor = [UIColor blackColor];
    self.tabBar.tintColor = [UIColor blackColor];
    
  } else {
    self.tabBar.barTintColor = [UIColor whiteColor];
    self.tabBar.tintColor = [UIColor whiteColor];
  }
}
@end
