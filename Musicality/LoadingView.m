//
//  LoadingView.m
//  Musicality
//
//  Created by Elle Lewis on 7/6/15.
//  Copyright (c) 2015 Elle Lewis. All rights reserved.
//

#import "LoadingView.h"
#import "ColorScheme.h"
#import "UserPrefs.h"

@implementation LoadingView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.viewLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
    self.progressLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
    self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
}

@end
