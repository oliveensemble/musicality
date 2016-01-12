//
//  ArtistsNavigationBar.m
//  Musicality
//
//  Created by Evan Lewis on 10/22/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

#import "ArtistsNavigationBar.h"
#import "UserPrefs.h"

@implementation ArtistsNavigationBar

- (void)awakeFromNib {
  [super awakeFromNib];
  self.artistsLabel.textColor = [UIColor blackColor];
}

- (void)beginLoading {
  self.loadingLabel.alpha = 0;
  self.loadingLabel.hidden = NO;
  [UIView animateWithDuration:0.2 animations:^{
    self.artistsLabel.alpha = 0;
    self.loadingLabel.alpha = 1.0;
  }];
}

- (void)updateLoadingLabelWithString:(NSString*)text  {
  self.loadingLabel.text = text;
}

- (void)endLoading {
  [UIView animateWithDuration:0.5 animations:^{
    self.loadingLabel.alpha = 0;
    self.artistsLabel.alpha = 1.0;
  } completion:^(BOOL finished) {
    self.loadingLabel.hidden = YES;
  }];
}

@end
