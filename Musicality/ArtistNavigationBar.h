//
//  ArtistNavigationBar.h
//  Musicality
//
//  Created by Evan Lewis on 10/21/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import UIKit;
#import "Button.h"
#import "MNavigationBar.h"

@interface ArtistNavigationBar : MNavigationBar

@property (weak, nonatomic) IBOutlet Button *backButton;
@property (weak, nonatomic) IBOutlet Button *addToListButton;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;

@end
