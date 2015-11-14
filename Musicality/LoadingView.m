//
//  LoadingView.m
//  Musicality
//
//  Created by Evan Lewis on 7/6/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

#import "LoadingView.h"
#import "UserPrefs.h"

@implementation LoadingView

- (void)awakeFromNib {
  self.backgroundColor = [UIColor whiteColor];
  self.viewLabel.textColor = [UIColor blackColor];
}

@end
