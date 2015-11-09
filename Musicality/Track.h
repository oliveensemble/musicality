//
//  Track.h
//  Musicality
//
//  Created by Evan Lewis on 11/21/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import Foundation;

@interface Track : NSObject

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *price;
@property (nonatomic) NSURL *buyURL;
@property (nonatomic) NSURL *previewURL;

- (instancetype)initWithName:(NSString*)trackName price:(NSNumber*)trackPrice buyLink:(NSURL*)trackBuyURL preview:(NSURL*)trackPreviewURL;

@end
