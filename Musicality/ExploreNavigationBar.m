//
//  ExploreNavigationBar.m
//  Musicality
//
//  Created by Evan Lewis on 10/21/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

#import "ExploreNavigationBar.h"
#import "ColorScheme.h"
#import "UserPrefs.h"
#import "MStore.h"

@implementation ExploreNavigationBar

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.exploreLabel.textColor = [[ColorScheme sharedScheme] secondaryColor];
    self.backgroundColor = [[ColorScheme sharedScheme] primaryColor];
}

@end
