//
//  SearchNavigationBar.m
//  Musicality
//
//  Created by Evan Lewis on 7/18/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

#import "SearchNavigationBar.h"
#import "ColorScheme.h"

@implementation SearchNavigationBar

- (void)awakeFromNib {
  [super awakeFromNib];
  self.layer.shadowOpacity = 0.4;
  self.layer.shadowRadius = 2.0;
  self.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
  self.layer.shadowColor = [UIColor blackColor].CGColor;
  self.layer.backgroundColor = [UIColor whiteColor].CGColor;
  
  self.searchLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
  self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
}

@end
