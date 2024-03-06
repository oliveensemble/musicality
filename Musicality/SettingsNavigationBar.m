//
//  SettingsNavigationBar.m
//  Musicality
//
//  Created by Elle Lewis on 10/22/14.
//  Copyright (c) 2014 Elle Lewis. All rights reserved.
//

#import "SettingsNavigationBar.h"
#import "ColorScheme.h"
#import "UserPrefs.h"

@implementation SettingsNavigationBar

- (void)awakeFromNib {
  [super awakeFromNib];
  
  self.settingsLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
  self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
}

@end
