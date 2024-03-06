//
//  ExploreNavigationBar.h
//  Musicality
//
//  Created by Elle Lewis on 10/21/14.
//  Copyright (c) 2014 Later Creative LLC. All rights reserved.
//

@import UIKit;
#import "Button.h"
#import "MNavigationBar.h"

@interface ExploreNavigationBar : MNavigationBar

@property (weak, nonatomic) IBOutlet Button *exploreNewButton;
@property (weak, nonatomic) IBOutlet Button *topChartsButton;
@property (weak, nonatomic) IBOutlet UILabel *exploreLabel;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

@property (weak, nonatomic) IBOutlet UIButton *topOfPageButton;

@end
