//
//  VariousArtistsNavigationBar.m
//  Musicality
//
//  Created by Evan Lewis on 8/8/15.
//  Copyright (c) 2015 Evan Lewis. All rights reserved.
//

#import "VariousArtistsNavigationBar.h"
#import "ColorScheme.h"
#import "UserPrefs.h"

@implementation VariousArtistsNavigationBar

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.variousArtistsLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
    self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
}

@end
