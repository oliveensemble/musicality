//
//  ArtistNavigationBar.h
//  Musicality
//
//  Created by Elle Lewis on 10/21/14.
//  Copyright (c) 2014 Later Creative LLC. All rights reserved.
//

@import UIKit;
#import "Button.h"
#import "MNavigationBar.h"

@interface ArtistNavigationBar : MNavigationBar

@property (weak, nonatomic) IBOutlet Button *backButton;
@property (weak, nonatomic) IBOutlet Button *addToListButton;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIButton *topOfPageButton;

@end
