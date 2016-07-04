//
//  Album.h
//  Musicality
//
//  Created by Evan Lewis on 9/30/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import Foundation;
@import UIKit;

@interface Album : NSObject <NSCoding>

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *artist;
@property (nonatomic) NSURL *artworkURL;
@property (nonatomic) NSURL *URL;
@property (nonatomic) NSDate *releaseDate;
@property (nonatomic) BOOL isPreOrder;
@property (nonatomic) NSNumber *artistID;
@property (nonatomic) NSNumber *trackCount;

- (instancetype)initWithAlbumTitle:(NSString*)title artist:(NSString*)album artworkURL:(NSString*)artWorkURL albumURL:(NSString*)albumURL releaseDate:(NSString*)releaseDate;

- (void)addArtistId:(NSString*)artistID;

@end
