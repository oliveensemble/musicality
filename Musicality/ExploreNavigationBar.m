//
//  ExploreNavigationBar.m
//  Musicality
//
//  Created by Evan Lewis on 10/21/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

#import "ExploreNavigationBar.h"
#import "UserPrefs.h"

@implementation ExploreNavigationBar

- (void)awakeFromNib {
  self.layer.shadowOpacity = 0.4;
  self.layer.shadowRadius = 2.0;
  self.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
  self.layer.shadowColor = [UIColor blackColor].CGColor;
  self.layer.backgroundColor = [UIColor whiteColor].CGColor;
  self.exploreLabel.textColor = [UIColor blackColor];
}

@end