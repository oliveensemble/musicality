//
//  LibraryNavigationBar.m
//  Musicality
//
//  Created by Evan Lewis on 11/27/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

#import "LibraryNavigationBar.h"

@implementation LibraryNavigationBar

- (void)beginLoading {
  self.loadingLabel.alpha = 0;
  self.loadingLabel.hidden = NO;
  [UIView animateWithDuration:0.4 animations:^{
    self.libraryArtistsLabel.alpha = 0;
    self.loadingLabel.alpha = 1.0;
  }];
}

- (void)endLoading {
  [UIView animateWithDuration:1.0 animations:^{
    self.loadingLabel.alpha = 0;
    self.libraryArtistsLabel.alpha = 1.0;
  } completion:^(BOOL finished) {
    self.loadingLabel.hidden = YES;
  }];
}

@end
