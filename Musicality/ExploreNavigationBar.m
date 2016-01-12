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
  [super awakeFromNib];
  self.exploreLabel.textColor = [UIColor blackColor];
}

- (void)beginLoading {
  self.loadingLabel.alpha = 0;
  self.loadingLabel.hidden = NO;
  [UIView animateWithDuration:0.4 animations:^{
    self.exploreLabel.alpha = 0;
    self.loadingLabel.alpha = 1.0;
  }];
}

- (void)endLoading {
  [UIView animateWithDuration:1.0 animations:^{
    self.loadingLabel.alpha = 0;
    self.exploreLabel.alpha = 1.0;
  } completion:^(BOOL finished) {
    self.loadingLabel.hidden = YES;
  }];
}

@end
