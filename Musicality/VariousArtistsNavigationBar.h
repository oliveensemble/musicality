//
//  VariousArtistsNavigationBar.h
//  Musicality
//
//  Created by Elle Lewis on 8/8/15.
//  Copyright (c) 2015 Elle Lewis. All rights reserved.
//

@import UIKit;

#import "Button.h"
#import "MNavigationBar.h"

@interface VariousArtistsNavigationBar : MNavigationBar

@property (weak, nonatomic) IBOutlet UILabel *variousArtistsLabel;
@property (weak, nonatomic) IBOutlet Button *backButton;
@property (weak, nonatomic) IBOutlet UIButton *topOfPageButton;

@end
