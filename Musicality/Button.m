//
//  Button.m
//  Musicality
//
//  Created by Elle Lewis on 10/27/14.
//  Copyright (c) 2014 Elle Lewis. All rights reserved.
//

#import "ColorScheme.h"
#import "UserPrefs.h"
#import "MStore.h"
#import "Button.h"

@implementation Button

- (void)awakeFromNib {
  [super awakeFromNib];
  [self configure];
}

- (void)configure {
  [self setTitleColor: [[ColorScheme sharedScheme] secondaryColor] forState:UIControlStateNormal];
  self.layer.borderColor = [[[ColorScheme sharedScheme] secondaryColor] CGColor];
  [self setBackgroundImage: [[ColorScheme sharedScheme] imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
  self.layer.borderWidth = 2.0f;
}

- (void)setHighlighted:(BOOL)highlighted {
  [super setHighlighted: highlighted];
  
  // If the button has the "Highlighted Adjusts Image" property in IB unchecked, don't highlight
  if (self.adjustsImageWhenHighlighted == YES) {
    if (highlighted) {
      [self setTitleColor: [[ColorScheme sharedScheme] primaryColor] forState:UIControlStateNormal];
      [self setBackgroundImage: [[ColorScheme sharedScheme] imageWithColor:[[ColorScheme sharedScheme] secondaryColor]] forState:UIControlStateHighlighted];
      self.layer.borderColor = [[[ColorScheme sharedScheme] secondaryColor] CGColor];
      self.layer.borderWidth = 2.0f;
    } else {
      [self setTitleColor: [[ColorScheme sharedScheme] secondaryColor] forState:UIControlStateNormal];
      [self setBackgroundImage: [[ColorScheme sharedScheme] imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
      self.layer.borderColor = [[[ColorScheme sharedScheme] secondaryColor] CGColor];
      self.layer.borderWidth = 2.0f;
    }
  }
}

- (void)setSelectedStyle {
  [self setTitleColor: [[ColorScheme sharedScheme] primaryColor] forState:UIControlStateNormal];
  self.layer.borderColor = [[[ColorScheme sharedScheme] secondaryColor] CGColor];
  [self setBackgroundImage: [[ColorScheme sharedScheme] imageWithColor:[[ColorScheme sharedScheme] secondaryColor]] forState:UIControlStateNormal];
  self.layer.borderWidth = 2.0f;
}

- (void)setDeselectedStyle {
  [self setTitleColor: [[ColorScheme sharedScheme] secondaryColor] forState:UIControlStateNormal];
  self.layer.borderColor = [[[ColorScheme sharedScheme] secondaryColor] CGColor];
  [self setBackgroundImage: [[ColorScheme sharedScheme] imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
  self.layer.borderWidth = 2.0f;
}

@end
