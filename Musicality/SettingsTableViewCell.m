//
//  SettingsTableViewCell.m
//  Musicality
//
//  Created by Elle Lewis on 6/23/16.
//  Copyright © 2016 Elle Lewis. All rights reserved.
//

#import "SettingsTableViewCell.h"
#import "ColorScheme.h"

@implementation SettingsTableViewCell

- (void)awakeFromNib {
  [super awakeFromNib];
  
  self.textLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
  self.detailTextLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
  self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  if (selected) {
    self.textLabel.textColor = [[ColorScheme sharedScheme] primaryColor];
    self.detailTextLabel.textColor = [[ColorScheme sharedScheme] primaryColor];
    self.backgroundColor = [[ColorScheme sharedScheme] secondaryColor];
  } else {
    self.textLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
    self.detailTextLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
    self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
  }
}

@end
