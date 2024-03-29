//
//  ExploreFetch.h
//  Musicality
//
//  Created by Elle Lewis on 11/7/15.
//  Copyright © 2015 Later Creative LLC. All rights reserved.
//


@import Foundation;

@protocol ExploreFetchDelegate;

//Fetches an array of albums for the explore view
@interface ExploreFetch : NSOperation

@property (nonatomic, weak) id<ExploreFetchDelegate> delegate;

- (instancetype)initWithDelegate:(id<ExploreFetchDelegate>)delegate;
- (void)fetchWithGenre:(int)genreID;

@end

@protocol ExploreFetchDelegate <NSObject>

- (void)didFinishFetchingFeed:(NSArray *)albumArray;

@end
