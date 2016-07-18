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
  
  self.searchLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
  self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
}

@end
