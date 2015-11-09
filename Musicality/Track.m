//
//  Track.m
//  Musicality
//
//  Created by Evan Lewis on 11/21/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

#import "Track.h"

@implementation Track

- (instancetype)initWithName:(NSString*)trackName price:(NSNumber*)trackPrice buyLink:(NSURL*)trackBuyURL preview:(NSURL*)trackPreviewURL {
  
  self = [super init];
  if (self) {
    _name = trackName;
    
    if (!trackPrice || [trackPrice  isEqual: @-1]) {
      _price  = @"Album Only";
    } else {
      _price = [NSString stringWithFormat:@"$%.2f", [trackPrice floatValue]];
    }
    _buyURL = trackBuyURL;
    _previewURL = trackPreviewURL;
  }
  return self;
  
}

- (NSString *)description {
  return [NSString stringWithFormat:@"Name:%@\nPrice:%@\nBuy:%@\nPreview:%@\n", self.name, self.price, self.buyURL, self.previewURL];
}

@end
