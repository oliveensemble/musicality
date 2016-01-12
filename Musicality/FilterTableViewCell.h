//
//  GenreTableViewCell.h
//  Musicality
//
//  Created by Evan Lewis on 11/6/15.
//  Copyright © 2015 Evan Lewis. All rights reserved.
//

@import UIKit;

@interface FilterTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *filterLabel;
@property (nonatomic) int filterId;

@end
