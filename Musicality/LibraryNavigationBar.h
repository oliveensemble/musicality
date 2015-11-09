//
//  LibraryNavigationBar.h
//  Musicality
//
//  Created by Evan Lewis on 11/27/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import UIKit;
#import "Button.h"

@interface LibraryNavigationBar : UIView

@property (weak, nonatomic) IBOutlet Button *addArtistsButton;
@property (weak, nonatomic) IBOutlet Button *cancelButton;

@end
