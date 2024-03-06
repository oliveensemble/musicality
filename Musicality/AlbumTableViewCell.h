//
//  AlbumTableViewCell.h
//  Musicality
//
//  Created by Elle Lewis on 10/31/15.
//  Copyright © 2015 Later Creative LLC. All rights reserved.
//

@import UIKit;
#import "Button.h"

@interface AlbumTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *albumLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;
@property (weak, nonatomic) IBOutlet Button *viewArtistButton;
@property (weak, nonatomic) IBOutlet UILabel *preOrderLabel;

@property (nonatomic) NSDictionary* cellInfo;

@end
