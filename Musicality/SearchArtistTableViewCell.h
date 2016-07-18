//
//  SearchArtistTableViewCell.h
//  Musicality
//
//  Created by Evan Lewis on 7/18/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

@import UIKit;
#import "Button.h"

@interface SearchArtistTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet Button *viewArtistButton;

@end
