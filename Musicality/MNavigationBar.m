//
//  MNavigationBar.m
//  Musicality
//
//  Created by Elle Lewis on 1/11/16.
//  Copyright © 2016 Later Creative LLC. All rights reserved.
//

#import "MNavigationBar.h"

@implementation MNavigationBar

- (void)awakeFromNib {
  [super awakeFromNib];
  self.layer.shadowOpacity = 0.4;
  self.layer.shadowRadius = 2.0;
  self.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
  self.layer.shadowColor = [UIColor blackColor].CGColor;
  self.layer.backgroundColor = [UIColor whiteColor].CGColor;
}

- (void)configureView {
  // Implemented in the subclasses
}

@end
