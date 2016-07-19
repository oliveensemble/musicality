//
//  SearchFetch.h
//  Musicality
//
//  Created by Evan Lewis on 7/18/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

@import Foundation;

@protocol SearchFetchDelegate;

// Searches for artists and albums the user types in from the search view controller
@interface SearchFetch : NSOperation

@property (weak, nonatomic) id<SearchFetchDelegate> delegate;

- (instancetype)initWithSearchType:(NSUInteger)searchType searchTerm: (NSString *)searchTerm delegate:(id<SearchFetchDelegate>) delegate;

@end

@protocol SearchFetchDelegate <NSObject>

- (void)searchFetchDidFinish:(NSMutableArray *)searchResultsArray;

@end
